#!/bin/bash

# Specify the path and filename for the .sh file
SH_FILE="/root/quilbuild.sh"

# Desired content for the .sh file
read -r -d '' SH_FILE_CONTENT << 'EOL'
#!/bin/bash

# Function to display the menu
display_menu() {
    echo "Choose an option:"
    echo "1. Firewall configureren voor Cluster Richard"
    echo "2. Firewall configureren voor Cluster Kevin"
    echo "3. Cluster Service voor Worker aanmaken/controleren"
    echo "4. Cluster Service status bekijken"
    echo "5. Token saldo Bekijken"
    echo "6. Exit"
}

# Main loop to keep the menu running
while true; do
    display_menu

    # Read user choice
    read -p "Enter your choice [1-6]: " choice

    # Handle the user choice
    case $choice in
        1)
            echo "Downloading Cluster Package..."
            # Replace the URL with the actual link you want to download
            wget -O /root/cluster-package.tar.gz http://example.com/cluster-package.tar.gz
            echo "Download completed and saved to /root/cluster-package.tar.gz"
            
            # Ask if the user wants to return to the menu
            read -p "Do you want to return to the menu? (y/n): " return_choice
            if [[ "$return_choice" != "y" && "$return_choice" != "Y" ]]; then
                echo "Exiting..."
                exit 0
            fi
            ;;
        2)
            echo "Configuring Firewall for Cluster Kevin..."
            # Place your firewall configuration commands here for Cluster Kevin
            ;;
        3)
            echo "Creating/Checking Cluster Service for Worker..."
            # Place your service creation/check commands here for Worker
            ;;
        4)
            echo "Viewing Cluster Service Status..."
            # Place your cluster service status check commands here
            ;;
        5)
            echo "Viewing Token Balance..."
            # Place your token balance view commands here
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a number between 1 and 6."
            ;;
    esac
done
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
