#!/bin/bash

# Path to the cluster service file
SERVICE_FILE="/etc/systemd/system/cluster.service"
# Path to the cluster start script
START_SCRIPT="/usr/local/bin/cluster_start.sh"

# Desired configuration for cluster.service
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
ExecStart=PLACEHOLDER_EXECSTART

[Install]
WantedBy=multi-user.target
EOL

# Desired ExecStart command
DESIRED_EXECSTART="ExecStart=$START_SCRIPT worker 257 1"

# Check if the service file exists
if [ -f "$SERVICE_FILE" ]; then
    echo "Service file $SERVICE_FILE already exists. Checking for differences..."

    # Check if ExecStart contains 'master', skip updating if it does
    if grep -q "ExecStart=.*master" "$SERVICE_FILE"; then
        echo "Skipping ExecStart update (contains 'master')."
        CURRENT_EXECSTART=$(grep "^ExecStart=" "$SERVICE_FILE")
    else
        CURRENT_EXECSTART="$DESIRED_EXECSTART"
        echo "Updating ExecStart to worker mode."
    fi

    # Replace the placeholder with the correct ExecStart command
    UPDATED_CONFIG="${DESIRED_CONFIG/PLACEHOLDER_EXECSTART/$CURRENT_EXECSTART}"

    # Write the updated configuration to the service file
    echo "$UPDATED_CONFIG" | sudo tee "$SERVICE_FILE" > /dev/null
    echo "Service file updated to match the desired configuration."
else
    echo "Service file $SERVICE_FILE does not exist. Creating it..."

    # Replace the placeholder with the desired ExecStart command and write the file
    UPDATED_CONFIG="${DESIRED_CONFIG/PLACEHOLDER_EXECSTART/$DESIRED_EXECSTART}"
    echo "$UPDATED_CONFIG" | sudo tee "$SERVICE_FILE" > /dev/null

    echo "Service file created successfully at $SERVICE_FILE."
fi

# Reload systemd manager configuration to recognize any changes
sudo systemctl daemon-reload

# Enable the service to start on boot but do not start it immediately
sudo systemctl enable cluster.service

echo "Cluster service configuration completed and enabled, but not started."

# Desired content for the cluster_start.sh script
read -r -d '' START_SCRIPT_CONTENT << 'EOL'
#!/bin/bash

# Set the working directory to /root/ceremonyclient/node/
cd /root/ceremonyclient/node/

# Capture the parent process ID (PPID) inside the script
parent_process_id=$PPID

# Get the role (master
