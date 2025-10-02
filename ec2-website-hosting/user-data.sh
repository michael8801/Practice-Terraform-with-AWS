#!/bin/bash

EMAIL="michaeel8801@gmail.com"
DOMAIN="solar.pp.ua"

sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y

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