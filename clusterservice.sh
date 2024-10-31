#!/bin/bash

# Path to the cluster service file
SERVICE_FILE="/etc/systemd/system/cluster.service"

# Desired configuration without the ExecStart line to handle specific cases
read -r -d '' DESIRED_CONFIG << EOL
[Unit]
Description=Cluster Start Script Monitoring All Worker Processes
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
ExecStop=/bin/kill -s SIGINT
KillSignal=SIGINT
RestartKillSignal=SIGINT
FinalKillSignal=SIGKILL
TimeoutStopSec=30s
User=root

[Install]
WantedBy=multi-user.target
EOL

# Desired ExecStart command
DESIRED_EXECSTART="ExecStart=/usr/local/bin/cluster_start.sh worker 257 1"

# Check if the service file exists
if [ -f "$SERVICE_FILE" ]; then
    echo "Service file $SERVICE_FILE already exists. Checking for differences..."

    # Check if ExecStart line contains 'master'
    if grep -q "ExecStart=.*master" "$SERVICE_FILE"; then
        echo "Skipping ExecStart update (contains 'master')."
        CURRENT_EXECSTART=$(grep "^ExecStart=" "$SERVICE_FILE")
    else
        echo "Updating ExecStart to worker mode..."
        CURRENT_EXECSTART="$DESIRED_EXECSTART"
    fi

    # Write the updated configuration, including the correct ExecStart line
    sudo tee "$SERVICE_FILE" > /dev/null << EOL
$DESIRED_CONFIG
$CURRENT_EXECSTART
EOL

    echo "Service file updated to match the desired configuration."
else
    echo "Service file $SERVICE_FILE does not exist. Creating it..."

    # Create the service file with the specified configuration
    sudo tee "$SERVICE_FILE" > /dev/null << EOL
$DESIRED_CONFIG
$DESIRED_EXECSTART
EOL

    echo "Service file created successfully at $SERVICE_FILE."
fi

# Reload the systemd manager configuration to recognize any changes
sudo systemctl daemon-reload

# Enable the service to start on boot but do not start it immediately
sudo systemctl enable cluster.service

echo "Cluster service configuration completed and enabled, but not started."
