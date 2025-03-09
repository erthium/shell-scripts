#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <domain> <html_file_path>" 1>&2
  exit 1
fi

DOMAIN=$1
HTML_FILE=$2

# Check if the specified HTML file exists
if [ ! -f "$HTML_FILE" ]; then
  echo "The specified HTML file does not exist: $HTML_FILE" 1>&2
  exit 1
fi

# Define the root directory and copy the HTML file there
ROOT_DIR="/var/www/$DOMAIN"
mkdir -p "$ROOT_DIR"
cp "$HTML_FILE" "$ROOT_DIR/index.html"

echo "Starting."

# Define the Nginx configuration file path
CONF_FILE="/etc/nginx/sites-available/$DOMAIN"

# Create the Nginx configuration file
echo "Creating Nginx configuration file at $CONF_FILE..."
cat <<EOF > "$CONF_FILE"
server {
  server_name $DOMAIN;

  root $ROOT_DIR;
  index index.html;

  location / {
    try_files \$uri \$uri/ =404;
  }
}
EOF

# Create a symbolic link to enable the site
ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/

# Test the Nginx configuration
nginx -t

if [ $? -eq 0 ]; then
  # Reload Nginx if the configuration is valid
  systemctl reload nginx
  echo "Nginx configuration for $DOMAIN has been set up and reloaded."
else
  echo "Nginx configuration test failed. Please check the configuration file."
fi

# 
# Obtain and install the SSL certificate if Certbot is installed
echo "Checking for Certbot installation..."
if command -v certbot &> /dev/null; then
  echo "Certbot found. Obtaining SSL certificate for $DOMAIN..."
  sudo certbot --nginx -d $DOMAIN

  # Reload Nginx to apply SSL changes
  systemctl reload nginx

  echo "SSL certificate has been obtained and Nginx reloaded."
else
  echo "Certbot is not installed. SSL certificate setup skipped."
fi

