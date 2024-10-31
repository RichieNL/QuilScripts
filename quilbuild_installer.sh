#!/bin/bash

# Specify the path and filename for the .sh file
SH_FILE="/root/quilbuild.sh"

# Desired content for the .sh file
read -r -d '' SH_FILE_CONTENT << 'EOL'
#!/bin/bash

# Display the menu
echo "Choose an option:"
echo "1. Firewall configureren voor Cluster Richard"
echo "2. Firewall configureren voor Cluster Kevin"
echo "3. Cluster Service voor Worker aanmaken/controleren"
echo "4. Cluster Service voor Master aanmaken/controleren"
echo "5. Cluster Service status bekijken"
echo "6. Token saldo Bekijken" 
echo "6. Exit"

# Read user choice
read -p "Enter your choice [1-5]: " choice

# Handle the user choice
case $choice in
    1)
        echo "Downloading Cluster Package..."
        # Replace the URL with the actual link you want to download
        wget -O /root/cluster-package.tar.gz http://example.com/cluster-package.tar.gz
        echo "Download completed and saved to /root/cluster-package.tar.gz"
        ;;
    2)
        echo "Stopping Cluster..."
        # Place your stop cluster commands here
        ;;
    3)
        echo "Checking Cluster Status..."
        # Place your check status commands here
        ;;
    4)
        echo "Updating Cluster Configuration..."
        # Place your update configuration commands here
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
     6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a number between 1 and 5."
        ;;
esac
EOL

# Create the .sh file with the specified content
if [ ! -f "$SH_FILE" ]; then
    echo "Creating $SH_FILE..."
    echo "$SH_FILE_CONTENT" | sudo tee "$SH_FILE" > /dev/null
    # Make the script executable
    sudo chmod +x "$SH_FILE"
    echo "$SH_FILE has been created and made executable."
else
    echo "$SH_FILE already exists."
fi
