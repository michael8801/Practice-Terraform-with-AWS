#!/bin/bash

EMAIL="michaeel8801@gmail.com"
DOMAIN="solar.pp.ua"

APP_DIR=/app/ghostfolio
CONTAINER_NAME=gf-postgres
STAMP="$(date +%F_%H%M%S)"
DUMP_OUT="pg-$${STAMP}.dump.gz"
S3_BUCKET="pg-dumps-from-ec2-pg-tf"
BACKUP_SCRIPT="/home/ubuntu/backup_postgres.sh"
ENV_FILE="/app/ghostfolio/.env"
COMPOSE_FILE="docker/docker-compose.yml"

sudo apt update
sudo apt install nginx certbot python3-certbot-nginx unzip -y

# aws cli installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


# CW Agent installation 
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# docker installation
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
  

mkdir app && cd app
git clone https://github.com/ghostfolio/ghostfolio.git
cd ghostfolio
cp .env.example .env

# Setup Redis connection
sed -i "s|^REDIS_HOST=.*|REDIS_HOST=${redis_endpoint}|" $ENV_FILE
sed -i '/^REDIS_PASSWORD=/d' $ENV_FILE

sed -i '/^\s\{6\}redis:/,+1d' $COMPOSE_FILE
sed -i '/^\s\{2\}redis:/,/^\s*volumes:$/ { /^\s*volumes:$/!d }' $COMPOSE_FILE

sudo docker compose -f $COMPOSE_FILE up -d

sudo systemctl start nginx
cat << 'EOF' > /etc/nginx/sites-available/"$DOMAIN"
server {
    listen 80;
    server_name solar.pp.ua;
    
    location / {
        proxy_pass http://127.0.0.1:3333;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
}
EOF

sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
sudo systemctl restart nginx
sudo systemctl enable nginx

sudo certbot --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive
sudo systemctl restart nginx

sudo usermod -aG docker ubuntu


# Nginx logs transfering 
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/bin/cloudwatch-config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "NginxLogGroup",
            "log_stream_name": "{instance_id}/access.log",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "NginxLogGroup",
            "log_stream_name": "{instance_id}/error.log",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/cloudwatch-config.json


# PostgreSQL dumps from EC2 to S3
cat > "$BACKUP_SCRIPT" <<'EOF'

APP_DIR=/app/ghostfolio
CONTAINER_NAME=gf-postgres
STAMP="$(date +%F_%H%M%S)"
DUMP_OUT="pg-$${STAMP}.dump.gz"
S3_BUCKET="pg-dumps-from-ec2-pg-tf"

export $(grep -v '^#' $${APP_DIR}/.env | grep -E '^POSTGRES' | xargs)

/usr/bin/sudo /usr/bin/docker exec -i $CONTAINER_NAME pg_dump -U $POSTGRES_USER -d $POSTGRES_DB -F c | gzip | aws s3 cp - s3://$${S3_BUCKET}/$${DUMP_OUT}
EOF

chmod +x "$BACKUP_SCRIPT"
sudo touch /var/log/pg-backup.log

cat << 'EOF' > /etc/cron.d/backup_postgres
0 3 * * * root /home/ubuntu/backup_postgres.sh >> /var/log/pg-backup.log 2>&1
EOF

sudo systemctl restart cron
