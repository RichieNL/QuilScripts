#!/bin/bash

# Variabelen
REMOTE_USER="gebruikersnaam"    # De gebruikersnaam voor de remote servers
REMOTE_PORT="jouw_poort"        # De SSH-poort (niet 22)
SERVICE_NAME="jouw_service"     # Naam van de service om te starten
SSH_KEY="~/.ssh/authorized_keys" # Pad naar de SSH-sleutel die in authorized_keys staat

# Lijst van IP-adressen voor de 16 servers  
IP_ADDRESSES=(
    "ip_adres_1"
    "ip_adres_2"
    "ip_adres_3"
    "ip_adres_4"
    "ip_adres_5"
    "ip_adres_6"
    "ip_adres_7"
    "ip_adres_8"
    "ip_adres_9"
    "ip_adres_10"
    "ip_adres_11"
    "ip_adres_12"
    "ip_adres_13"
    "ip_adres_14"
    "ip_adres_15"
    "ip_adres_16"
)

# Functie om de service op een enkele server te starten
start_service_on_server() {
    local IP="$1"
    echo "Service $SERVICE_NAME starten op $IP..."
    
    ssh -i "$SSH_KEY" -p "$REMOTE_PORT" "$REMOTE_USER@$IP" "sudo systemctl start $SERVICE_NAME"
    
    if [ $? -eq 0 ]; then
        echo "Service $SERVICE_NAME succesvol gestart op $IP."
    else
        echo "Er is een fout opgetreden bij het starten van de service $SERVICE_NAME op $IP."
    fi
}

# Start de service op elke server in de lijst
for IP in "${IP_ADDRESSES[@]}"; do
    start_service_on_server "$IP"
done
