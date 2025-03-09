#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <service-name> <minecraft-server-path> [java-args]" 1>&2
  echo "Example: $0 minecraft-server /home/user/minecraft '-Xmx4G -Xms4G -jar server.jar nogui'"
  exit 1
fi

SERVICE_NAME=$1
SERVER_PATH=$2
JAVA_ARGS=${3:--Xmx2G -Xms2G -jar server.jar nogui} # Default Java arguments

echo "Creating systemd service for Minecraft server..."

# Define the service file path
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Create the systemd service file
echo "Writing service file to $SERVICE_FILE..."
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Minecraft Server: $SERVICE_NAME
After=network.target

[Service]
WorkingDirectory=$SERVER_PATH
ExecStart=/usr/bin/java $JAVA_ARGS
Restart=always
User=$(logname)
Group=$(logname)
UMask=0027
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
echo "Reloading systemd..."
systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling $SERVICE_NAME service to start on boot..."
systemctl enable "$SERVICE_NAME"

# Start the service
echo "Starting $SERVICE_NAME service..."
systemctl start "$SERVICE_NAME"

# Check the service status
echo "Checking the service status..."
systemctl status "$SERVICE_NAME" --no-pager

echo "Minecraft server service has been successfully created and started."

