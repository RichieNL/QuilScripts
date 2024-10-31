#!/bin/bash

# Specificeer het pad en de bestandsnaam voor het .sh-bestand
SH_FILE="/root/quilbuild.sh"

# Gewenste inhoud voor het .sh-bestand
read -r -d '' SH_FILE_CONTENT << 'EOL'
#!/bin/bash

# Functie om het menu weer te geven
display_menu() {
    echo "Kies een optie:"
    echo "1. Firewall configureren voor Cluster Richard"
    echo "2. Firewall configureren voor Cluster Kevin"
    echo "3. Cluster Service voor Worker aanmaken/controleren"
    echo "4. Cluster Service status bekijken"
    echo "5. Token saldo bekijken"
    echo "6. Afsluiten"
}

# Hoofdloop om het menu actief te houden
while true; do
    display_menu

    # Lees de keuze van de gebruiker
    read -p "Voer je keuze in [1-6]: " choice

    # Behandel de keuze van de gebruiker
    case $choice in
        1)
            echo "Firewall configureren voor Cluster Richard..."
            wget --no-cache -O - https://raw.githubusercontent.com/RichieNL/QuilScripts/refs/heads/main/FWConfigure.sh?token=GHSAT0AAAAAACZWFSUZNIBGOYXZDNFRBVGCZZDSA7A | bash
            ;;
        2)
            echo "Firewall configureren voor Cluster Kevin..."
            wget --no-cache -O - https://raw.githubusercontent.com/RichieNL/QuilScripts/refs/heads/main/FWConfigureKevin.sh?token=GHSAT0AAAAAACZWFSUZCVFV6IZMIDHP6JB6ZZDSBVQ | bash
            ;;
        3)
            echo "Cluster Service voor Worker aanmaken/controleren..."
            wget --no-cache -O - https://raw.githubusercontent.com/RichieNL/QuilScripts/refs/heads/main/clusterservice.sh?token=GHSAT0AAAAAACZWFSUYT7S4SUUWZBG644GMZZDSCGA | bash
            ;;
        4)
            echo "Cluster Service status bekijken..."
            sudo journalctl -u cluster.service -f --no-hostname -o cat
            ;;
        5)
            echo "Token saldo bekijken..."
            cd /root/ceremonyclient/node || { echo "Fout bij het wijzigen van directory."; exit 1; }
            # Voer het commando uit en geef de output weer
            ./node-2.0.2.3-linux-amd64 --node-info
            ;;
        6)
            echo "Afsluiten..."
            exit 0
            ;;
        *)
            echo "Ongeldige keuze. Kies een nummer tussen 1 en 6."
            ;;
    esac

    # Vraag de gebruiker of hij terug naar het menu wil, behalve bij keuze 6
    read -p "Wil je terug naar het menu? (y/n): " return_choice
    if [[ "$return_choice" != "y" && "$return_choice" != "Y" ]]; then
        echo "Afsluiten..."
        exit 0
    fi
done
EOL

# Maak het .sh-bestand met de gespecificeerde inhoud
if [ ! -f "$SH_FILE" ]; then
    echo "Het bestand $SH_FILE wordt aangemaakt..."
    echo "$SH_FILE_CONTENT" | sudo tee "$SH_FILE" > /dev/null
    # Maak het script uitvoerbaar
    sudo chmod +x "$SH_FILE"
    echo "$SH_FILE is aangemaakt en uitvoerbaar gemaakt."
else
    echo "$SH_FILE bestaat al."
fi
