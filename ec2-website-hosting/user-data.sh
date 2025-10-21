#!/bin/bash

EMAIL="michaeel8801@gmail.com"
DOMAIN="solar.pp.ua"

APP_DIR=/app/ghostfolio
CONTAINER_NAME=gf-postgres
STAMP="$(date +%F_%H%M%S)"
DUMP_OUT="pg-${STAMP}.dump.gz"
S3_BUCKET="pg-dumps-from-ec2-pg-tf"
BACKUP_SCRIPT="/home/ubuntu/backup_postgres.sh"


sudo apt update
sudo apt install nginx certbot python3-certbot-nginx unzip -y

# aws cli installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

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
sudo docker compose -f docker/docker-compose.yml up -d

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

# PostgreSQL dumps from EC2 to S3
cat > "$BACKUP_SCRIPT" <<'EOF'

APP_DIR=/app/ghostfolio
CONTAINER_NAME=gf-postgres
STAMP="$(date +%F_%H%M%S)"
DUMP_OUT="pg-${STAMP}.dump.gz"
S3_BUCKET="pg-dumps-from-ec2-pg-tf"

export $(grep -v '^#' ${APP_DIR}/.env | grep -E '^POSTGRES' | xargs)

/usr/bin/sudo /usr/bin/docker exec -i $CONTAINER_NAME pg_dump -U $POSTGRES_USER -d $POSTGRES_DB -F c | gzip | aws s3 cp - s3://${S3_BUCKET}/${DUMP_OUT}
EOF

chmod +x "$BACKUP_SCRIPT"
sudo touch /var/log/pg-backup.log

cat << 'EOF' > /etc/cron.d/backup_postgres
0 3 * * * root /home/ubuntu/backup_postgres.sh >> /var/log/pg-backup.log 2>&1
EOF

sudo systemctl restart cron