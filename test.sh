  GNU nano 6.2                                    ./serviceversion.sh                                             
#!/bin/bash

# Pad naar het .service bestand
SERVICE_FILE="/lib/systemd/system/ceremonyclient.service"

# Controleer of het bestand bestaat
if [[ -f "$SERVICE_FILE" ]]; then
    # Kijk welke versie momenteel in het bestand staat
    if grep -q "1.4.21.1" "$SERVICE_FILE"; then
        echo "De huidige versie is 1.4.21.1."
        read -p "Wil je dit veranderen naar 2.0.2.3? (ja/nee): " antwoord
        if [[ "$antwoord" == "ja" ]]; then
            sed -i 's/1.4.21.1/2.0.2.3/g' "$SERVICE_FILE"
            echo "Versie bijgewerkt naar 2.0.2.3."
            systemctl daemon-reload
            echo "Systemd daemon herladen."
        else
            echo "Geen wijzigingen aangebracht."
        fi
    elif grep -q "2.0.2.3" "$SERVICE_FILE"; then
        echo "De huidige versie is 2.0.2.3."
        read -p "Wil je dit veranderen naar 1.4.21.1? (ja/nee): " antwoord
        if [[ "$antwoord" == "ja" ]]; then
            sed -i 's/2.0.2.3/1.4.21.1/g' "$SERVICE_FILE"
            echo "Versie bijgewerkt naar 1.4.21.1."
            systemctl daemon-reload
            echo "Systemd daemon herladen."
        else
            echo "Geen wijzigingen aangebracht."
        fi
    else
        echo "Geen bekende versie gevonden in $SERVICE_FILE."
    fi
else
    echo "Bestand $SERVICE_FILE niet gevonden."
fi





