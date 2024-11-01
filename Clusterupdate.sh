#!/bin/bash

# URL van de download directory
url="https://releases.quilibrium.com/release"

# Lokale directory waar de bestanden worden opgeslagen
local_dir="/root/ceremonyclient/node"

# Pad naar het cluster_start script
cluster_start_script="/usr/local/bin/cluster_start.sh"

echo "=== Start van het update-script ==="

# Ophalen van de laatste versie van linux-amd64 bestanden
echo "Ophalen van de laatste versie van linux-amd64 bestanden..."
latest_version=$(curl -s "$url" | grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(?=-linux-amd64)' | sort -V | tail -1)
echo "Laatste versie gedetecteerd: $latest_version"

# Oude bestanden opruimen
echo "Verwijderen van oude bestanden in $local_dir..."
rm -f "$local_dir"/node-*-linux-amd64*
echo "Oude bestanden zijn verwijderd."

# Functie om een bestand te downloaden en uitvoerbaar te maken
download_and_make_executable() {
    filename=$1
    remote_file="$url/$filename"
    local_file="$local_dir/$filename"

    # Download bestand en maak het uitvoerbaar
    echo "Bezig met downloaden van $filename..."
    curl -o "$local_file" "$remote_file"
    if [ -f "$local_file" ]; then
        chmod +x "$local_file"
        echo "$filename is gedownload en uitvoerbaar gemaakt."
    else
        echo "Fout bij het downloaden van $filename. Bestand niet gevonden."
    fi
}

# Dynamisch ophalen van alle bestanden inclusief .sig bestanden met de juiste versie
echo "Ophalen van de lijst met bestanden voor versie $latest_version..."
bestanden=$(curl -s "$url" | grep -oP "node-${latest_version}-linux-amd64(\.dgst|\.dgst\.sig\.[0-9]+)")
echo "Te downloaden bestanden: $bestanden"

# Controleer en download elk bestand in de lijst
echo "Begin met downloaden van bestanden..."
IFS=$'\n' # Zorgt ervoor dat elk bestand op een nieuwe regel wordt gelezen
for bestand in $bestanden; do
    echo "Verwerken van bestand: $bestand"
    download_and_make_executable "$bestand"
done
echo "Alle bestanden zijn gedownload en uitvoerbaar gemaakt."

# Versie-upgrade controle en update cluster_start script
echo "Controleer of cluster_start.sh moet worden bijgewerkt..."
current_version=$(grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$cluster_start_script" | sort -V | tail -1)
if [[ "$latest_version" > "$current_version" ]]; then
    echo "Nieuwere versie gedetecteerd in cluster_start.sh, bijwerken naar $latest_version"
    sed -i "s/$current_version/$latest_version/g" "$cluster_start_script"
    echo "cluster_start.sh is bijgewerkt naar versie $latest_version"

    # Controleer of het een geldige Git-repository is
    if [ -d "/root/ceremonyclient/.git" ]; then
        echo "Git-repository bijwerken voor de nieuwe versie..."
        cd /root/ceremonyclient || exit
        git remote set-url origin https://github.com/QuilibriumNetwork/ceremonyclient.git
        git checkout main
        git branch -D release
        git pull
        git checkout release
        echo "Git-repository is succesvol bijgewerkt naar de nieuwe versie."
    else
        echo "Fout: /root/ceremonyclient is geen geldige Git-repository."
    fi
else
    echo "cluster_start.sh is al up-to-date met de laatste versie."
fi

echo "=== Update-script voltooid ==="
    
