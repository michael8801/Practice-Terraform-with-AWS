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

# nginx and certbot installation
apt update
apt install nginx certbot python3-certbot-nginx unzip -y

# aws cli installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# CW Agent installation 
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# docker installation
apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
  
# App deploy
mkdir app && cd app
git clone https://github.com/ghostfolio/ghostfolio.git
cd ghostfolio
cp .env.example .env

# Remove Postgres and Redis from docker compose 
sed -i '/^\s\{4\}depends_on:/,+4d' $COMPOSE_FILE
sed -i '/^\s\{2\}postgres:/,/^\s*$/d' $COMPOSE_FILE
sed -i '/^\s\{0\}volumes:/,+1d' $COMPOSE_FILE
sed -i '/^\s\{2\}redis:/,/^\s*volumes:$/ { /^\s*volumes:$/!d }' $COMPOSE_FILE

# Fill .env with RDS values
sed -i "s|^POSTGRES_DB=.*|POSTGRES_DB=${db_name}|" $ENV_FILE
sed -i "s|^POSTGRES_USER=.*|POSTGRES_USER=${db_user}|" $ENV_FILE
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${db_password}|" $ENV_FILE
sed -i "/^DATABASE_URL=/ s|@postgres:5432|@${db_host_address}:5432|" $ENV_FILE

# Data migration from postgres container to RDS instance is done manually
#sudo docker exec -i $CONTAINER_NAME pg_dump -U $POSTGRES_USER -d $POSTGRES_DB -F c > ~/user_data_migration_backup.sql
#pg_restore "host=${db_host_address} port=5432 user=${db_user} dbname=${db_name} sslmode=require" -f ~/user_data_migration_backup.sql

# Fill .env with ElastiCache Redis values
sed -i "s|^REDIS_HOST=.*|REDIS_HOST=${redis_endpoint}|" $ENV_FILE
sed -i '/^REDIS_PASSWORD=/d' $ENV_FILE

# Deploy docker compose with just app
sudo docker compose -f $COMPOSE_FILE up -d

# Configure Nginx 
systemctl start nginx
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

ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
systemctl restart nginx
systemctl enable nginx

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Nginx logs transfering from local to CloudWatch logs
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

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/cloudwatch-config.json
