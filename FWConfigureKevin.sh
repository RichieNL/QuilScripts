#!/bin/bash

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
echo "Backing up current UFW rules to /etc/ufw/ufw.rules.bak..."
sudo ufw status > /etc/ufw/ufw.rules.bak

# Clean up any existing rules that do not match the specified criteria
echo "Cleaning up UFW rules..."
rule_count=$(sudo ufw status numbered | grep -c "ALLOW")
for ((i=rule_count; i>=1; i--)); do
    echo "Deleting rule $i..."
    yes | sudo ufw delete $i
done

# Define the ports to open for both TCP and UDP
declare -a ports=("8336" "8316" "8317" "1419")

# Open specified ports for both TCP and UDP for IPv4 only
for port in "${ports[@]}"; do
    echo "Allowing TCP and UDP on port $port for IPv4 only..."
    sudo ufw allow $port/tcp comment 'Allow TCP on IPv4 only'
    sudo ufw allow $port/udp comment 'Allow UDP on IPv4 only'
done

# Open port range 40000:40256 for a specific IPv4 address on both TCP and UDP
ip_address="193.39.187.65"
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