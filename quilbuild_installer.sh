#!/bin/bash

# Specificeer het pad en de bestandsnaam voor het .sh-bestand
SH_FILE="/root/quilbuild.sh"

# Gewenste inhoud voor het .sh-bestand
read -r -d '' SH_FILE_CONTENT << 'EOL'
#!/bin/bash

# Definiëren van kleuren
RED='\033[0;31m'    # Rood
YELLOW='\033[1;33m' # Geel
NC='\033[0m'        # Geen kleur (reset)

# Functie om het menu weer te geven
display_menu() {
    echo "${YELLOW}Speciaal voor Kevin het cluster config voor dummies${NC}"
    echo "${RED}voor zowel Kevin Als Richard ga ik er vanuit dat de huidige HM01 de Master is${NC}"
    echo "${RED}het configureren van de master moet handmatig.${NC}"
    echo "${RED}na het configureren moet handmatig nog het config.yml en keys.yml bestand op elke server geplaatst worden${NC}"
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
    clear
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
            cd /root/ceremonyclient/client || { echo "Fout bij het wijzigen van directory."; exit 1; }
            # Voer het commando uit en geef de output weer
            ./qclient-2.0.2.3-linux-amd64 token balance --config /root/ceremonyclient/node/.config
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

# Controleer of het bestand al bestaat en of de inhoud overeenkomt
if [ -f "$SH_FILE" ]; then
    echo "$SH_FILE bestaat al. Controleren op overeenkomsten..."
    # Vergelijk de huidige inhoud met de gewenste inhoud
    if ! diff <(echo "$SH_FILE_CONTENT") "$SH_FILE" &> /dev/null; then
        echo "Inhoud komt niet overeen. Het bestand wordt bijgewerkt..."
        echo "$SH_FILE_CONTENT" | sudo tee "$SH_FILE" > /dev/null
        sudo chmod +x "$SH_FILE"
        echo "$SH_FILE is bijgewerkt en uitvoerbaar gemaakt."
    else
        echo "$SH_FILE is al up-to-date."
    fi
else
    echo "Het bestand $SH_FILE wordt aangemaakt..."
    echo "$SH_FILE_CONTENT" | sudo tee "$SH_FILE" > /dev/null
    sudo chmod +x "$SH_FILE"
    echo "$SH_FILE is aangemaakt en uitvoerbaar gemaakt."
fi
