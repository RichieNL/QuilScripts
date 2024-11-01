#!/bin/bash

# URL van de download directory
url="https://releases.quilibrium.com/release"

# Lokale directory waar de bestanden worden opgeslagen
local_dir="/root/ceremonyclient/node"

# Pad naar het cluster_start script
cluster_start_script="/usr/local/bin/cluster_start.sh"

# Ophalen van de laatste versie van linux-amd64 bestanden
latest_version=$(curl -s "$url" | grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(?=-linux-amd64)' | sort -V | tail -1)

echo "Laatste versie gedetecteerd: $latest_version"

# Functie om een bestand te downloaden, uitvoerbaar te maken, en de wijzigingsdatum te controleren
check_and_update_file() {
    filename=$1
    remote_file="$url/$filename"
    local_file="$local_dir/$filename"

    # Download header informatie voor de 'Last-Modified' datum van het remote bestand
    remote_date=$(curl -sI "$remote_file" | grep -i "Last-Modified" | sed 's/Last-Modified: //i' | tr -d '\r')

    # Als het bestand niet bestaat lokaal, download het
    if [ ! -f "$local_file" ]; then
        echo "Bestand $filename bestaat niet lokaal. Downloaden..."
        curl -o "$local_file" "$remote_file"
        chmod +x "$local_file"
    else
        # Huidige lokale bestanddatum opvragen
        local_date=$(date -r "$local_file" "+%a, %d %b %Y %H:%M:%S %Z")

        # Vergelijk data
        if [[ "$remote_date" > "$local_date" ]]; then
            echo "Nieuwere versie van $filename gevonden. Bijwerken..."
            curl -o "$local_file" "$remote_file"
            chmod +x "$local_file"
        else
            echo "$filename is al up-to-date."
        fi
    fi
}

# Dynamisch ophalen van bestanden inclusief alle .sig bestanden
bestanden=$(curl -s "$url" | grep -oP "node-${latest_version}-linux-amd64(\.dgst|\.dgst\.sig\.[0-9]+)")

# Controleer elk bestand in de dynamisch gegenereerde lijst
for bestand in $bestanden; do
    check_and_update_file "$bestand"
done

# Versie-upgrade controle en update cluster_start script
current_version=$(grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$cluster_start_script" | sort -V | tail -1)
if [[ "$latest_version" > "$current_version" ]]; then
    echo "Versie in cluster_start.sh updaten naar $latest_version"
    sed -i "s/$current_version/$latest_version/g" "$cluster_start_script"
    echo "Versie-upgrade voltooid in $cluster_start_script"

    # Voer git-commando's uit als de versie is bijgewerkt
    echo "Git-repository bijwerken voor nieuwe versie..."
    cd /root/ceremonyclient || exit
    git remote set-url origin https://github.com/QuilibriumNetwork/ceremonyclient.git
    git checkout main
    git branch -D release
    git pull
    git checkout release
    echo "Git-repository is succesvol bijgewerkt naar de nieuwe versie."
else
    echo "Versie in cluster_start.sh is al up-to-date."
fi
