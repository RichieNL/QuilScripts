#!/bin/bash

# Target directory and file
target_dir="/root/QuilScripts"
target_file="${target_dir}/ConfigureFW.sh"

# Ensure the target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Directory $target_dir does not exist. Creating it..."
    sudo mkdir -p "$target_dir"
    sudo chmod 700 "$target_dir"  # Restrict permissions if necessary
else
    echo "Directory $target_dir already exists."
fi

# Prompt the user to input the SSH port
read -p "Enter the SSH port you wish to allow (default is 22): " ssh_port
ssh_port=${ssh_port:-22}  # Default to 22 if no input is provided

# Define the UFW configuration script content with dynamic SSH port
script_content='#!/bin/bash

# Script to check, clean up, and configure UFW rules with specified ports and IP restrictions

# Enable UFW if not already active
if ! sudo ufw status | grep -q "Status: active"; then
    echo "UFW is not active. Enabling UFW..."
    sudo ufw enable
fi

# Function to display current UFW rules
display_rules() {
    echo "Current UFW Rules:"
    sudo ufw status numbered
    echo
}

# Backup existing rules
backup_path="/etc/ufw/ufw.rules.bak"
echo "Backing up current UFW rules to $backup_path..."
sudo ufw status > $backup_path

# Prompt for IP address to allow specific access
read -p "Enter the IPv4 address you wish to allow for the port range 40000:40256: " ip_address

# Validate IP address format
if [[ ! $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid IP address format. Exiting script."
    exit 1
fi

# Clean up any existing rules that do not match the specified criteria
echo "Cleaning up UFW rules..."
rule_count=$(sudo ufw status numbered | grep -c "ALLOW")
for ((i=rule_count; i>=1; i--)); do
    echo "Deleting rule $i..."
    yes | sudo ufw delete $i
done

# Define the ports to open for both TCP and UDP, including dynamic SSH port
declare -a ports=("8336" "8316" "8317" "'${ssh_port}'")

# Open specified ports for both TCP and UDP for IPv4 only
for port in "${ports[@]}"; do
    echo "Allowing TCP and UDP on port $port for IPv4 only..."
    sudo ufw allow $port/tcp comment "Allow TCP on IPv4 only"
    sudo ufw allow $port/udp comment "Allow UDP on IPv4 only"
done

# Open port range 40000:40256 for the specified IPv4 address on both TCP and UDP
echo "Allowing port range 40000:40256 for IPv4 address $ip_address on TCP and UDP..."
sudo ufw allow from $ip_address to any port 40000:40256 proto tcp
sudo ufw allow from $ip_address to any port 40000:40256 proto udp

# Reload UFW to apply changes
echo "Reloading UFW..."
sudo ufw reload

# Display updated rules after cleanup and configuration
echo "Displaying UFW rules after cleanup and configuration..."
display_rules

echo "UFW configuration complete."
'

# Check if the file exists and if it matches the desired content
if [ -f "$target_file" ]; then
    existing_content=$(cat "$target_file")
    if [ "$existing_content" != "$script_content" ]; then
        echo "Updating existing $target_file with new content..."
        echo "$script_content" | sudo tee "$target_file" > /dev/null
    else
        echo "$target_file already exists and is up-to-date."
    fi
else
    echo "Creating $target_file with the specified content..."
    echo "$script_content" | sudo tee "$target_file" > /dev/null
fi

# Make the script executable
sudo chmod +x "$target_file"
echo "Configuration complete. You can run the script with sudo $target_file"
