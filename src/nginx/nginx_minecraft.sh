#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <domain> <minecraft-server-ip> <minecraft-server-port>" 1>&2
  exit 1
fi

DOMAIN=$1
SERVER_IP=$2
SERVER_PORT=$3

echo "Starting setup for Minecraft server reverse proxy."

# Define the Nginx configuration file path
CONF_FILE="/etc/nginx/nginx.conf"

# Add a stream block for Minecraft server in Nginx config
echo "Updating Nginx configuration file at $CONF_FILE..."

if ! grep -q "stream {" "$CONF_FILE"; then
  echo "Adding stream block for TCP/UDP proxying..."
  echo "stream {" >> "$CONF_FILE"
  echo "}" >> "$CONF_FILE"
fi

# Add the server configuration inside the stream block
sed -i "/stream {/a\\
    upstream minecraft_$DOMAIN {\\
        server $SERVER_IP:$SERVER_PORT;\\
    }\\
    server {\\
        listen $SERVER_PORT udp;\\
        listen $SERVER_PORT tcp;\\
        proxy_pass minecraft_$DOMAIN;\\
    }" "$CONF_FILE"

# Test the Nginx configuration
nginx -t
if [ $? -ne 0 ]; then
  echo "Nginx configuration test failed. Please check the configuration file."
  exit 1
fi

# Reload Nginx if the configuration is valid
systemctl reload nginx
echo "Nginx configuration for Minecraft server ($DOMAIN) has been set up and reloaded."

# Configure SSL using Certbot
echo "Checking for Certbot installation..."
if command -v certbot &> /dev/null; then
  echo "Certbot found. Obtaining SSL certificate for $DOMAIN..."
  certbot certonly --standalone -d $DOMAIN

  echo "Enabling SSL in the Nginx configuration..."
  sed -i "/server {\\n\\s*listen $SERVER_PORT tcp;/a\\
        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;\\
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;\\
        ssl_protocols TLSv1.2 TLSv1.3;\\
        ssl_ciphers HIGH:!aNULL:!MD5;" "$CONF_FILE"

  # Reload Nginx to apply SSL changes
  systemctl reload nginx
  echo "SSL certificate has been obtained and applied. Nginx reloaded."
else
  echo "Certbot is not installed. SSL certificate setup skipped."
fi

echo "Minecraft server reverse proxy setup is complete."

