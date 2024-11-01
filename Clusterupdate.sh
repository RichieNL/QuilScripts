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

# Functie om een bestand te downloaden en uitvoerbaar te maken
download_and_make_executable() {
    filename=$1
    remote_file="$url/$filename"
    local_file="$local_dir/$filename"

    # Download bestand en maak het uitvoerbaar
    echo "Bestand $filename downloaden..."
    curl -o "$local_file" "$remote_file"
    chmod +x "$local_file"
    echo "$filename is gedownload en uitvoerbaar gemaakt."
}

# Dynamisch ophalen van alle bestanden inclusief .sig bestanden met de juiste versie
bestanden=$(curl -s "$url" | grep -oP "node-${latest_version}-linux-amd64(\.dgst|\.dgst\.sig\.[0-9]+)")

# Controleer en download elk bestand in de lijst
for bestand in $bestanden; do
    download_and_make_executable "$bestand"
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
