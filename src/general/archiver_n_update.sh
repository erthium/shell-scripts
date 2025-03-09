#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <domain> <new_html_file_path>" 1>&2
  exit 1
fi

DOMAIN=$1
NEW_HTML=$2
ROOT_DIR="/var/www/$DOMAIN"
CURRENT_HTML="$ROOT_DIR/index.html"

# Check if the root directory exists
if [ ! -d "$ROOT_DIR" ]; then
  echo "The directory for the domain does not exist: $ROOT_DIR" 1>&2
  exit 1
fi

# Check if the new HTML file exists
if [ ! -f "$NEW_HTML" ]; then
  echo "The new HTML file does not exist: $NEW_HTML" 1>&2
  exit 1
fi

# Archive the current index.html
if [ -f "$CURRENT_HTML" ]; then
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  ARCHIVED_FILE="$ROOT_DIR/${TIMESTAMP}_index.html"
  echo "Archiving current index.html to $ARCHIVED_FILE..."
  mv "$CURRENT_HTML" "$ARCHIVED_FILE"
else
  echo "No existing index.html file found. Skipping archive step."
fi

# Replace with the new HTML file
echo "Replacing index.html with the new file..."
cp "$NEW_HTML" "$CURRENT_HTML"

# Set proper ownership and permissions
chown www-data:www-data "$CURRENT_HTML"
chmod 644 "$CURRENT_HTML"

echo "The new index.html has been deployed for $DOMAIN."

