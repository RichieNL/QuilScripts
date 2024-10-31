#!/bin/bash

# Script to check, clean up, and configure UFW rules with specified ports and IP restrictions

# Enable UFW if not already active
if ! sudo ufw status | grep -q "Status: active"; then
    echo "UFW is not active. Enabling UFW..."
    sudo ufw enable
fi

# Prompt for IP address input
read -p "Enter the IP address to allow access to ports 40000-40256: " ip_address

# Validate the IP address format
if [[ ! $ip_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Invalid IP address format. Please enter a valid IP."
    exit 1
fi

# Function to display current UFW rules
display_rules() {
    echo "Current UFW Rules:"
    sudo ufw status numbered
    echo
}

# Backup existing rules
echo "Backing up current UFW rules to /etc/ufw/ufw.rules.bak..."
sudo ufw status > /etc/ufw/ufw.rules.bak

# Clean up any existing rules that do not match the specified criteria
echo "Cleaning up UFW rules..."
rule_count=$(sudo ufw status numbered | grep -c "ALLOW")
for ((i=rule_count; i>=1; i--)); do
    sudo ufw delete $i
done

# Define the ports to open for both TCP and UDP
declare -a ports=("8336" "8316" "8317" "1419")

# Open specified ports for both TCP and UDP
for port in "${ports[@]}"; do
    echo "Allowing TCP and UDP on port $port..."
    sudo ufw allow $port/tcp
    sudo ufw allow $port/udp
done

# Open port range 40000:40256 for the specified IP on both TCP and UDP
echo "Allowing port range 40000:40256 for IP $ip_address on TCP and UDP..."
sudo ufw allow from $ip_address to any port 40000:40256 proto tcp
sudo ufw allow from $ip_address to any port 40000:40256 proto udp

# Reload UFW to apply changes
echo "Reloading UFW..."
sudo ufw reload

# Display updated rules after cleanup and configuration
echo "Displaying UFW rules after cleanup and configuration..."
display_rules

echo "UFW configuration complete."
