#!/bin/bash

# Basis-URL voor de Quilibrium releases
RELEASE_FILES_URL="https://releases.quilibrium.com/release"
OS_ARCH="linux-amd64"

# Lokale directory waar de bestanden worden opgeslagen
DOWNLOAD_DIR="/root/ceremonyclient/node"

# Pad naar het cluster_start script
CLUSTER_START_SCRIPT="/usr/local/bin/cluster_start.sh"

echo "=== Start van het update-script ==="

# Controleer of de downloadmap bestaat en ga naar de downloadmap
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit

# Haal de nieuwste versie op van de releasepagina
latest_version=$(curl -s "$RELEASE_FILES_URL" | grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=-linux-amd64)' | sort -V | tail -1)
echo "Laatste versie gedetecteerd: $latest_version"

# Haal de lijst met bestanden op van de releasepagina voor de gedetecteerde versie
RELEASE_FILES=$(curl -s "$RELEASE_FILES_URL" | grep -oE "node-${latest_version}-${OS_ARCH}(\.dgst|\.dgst\.sig\.[0-9]+)?")

# Download elk bestand in de lijst
for file in $RELEASE_FILES; do
    echo "Bezig met downloaden van $file..."
    file_url="$RELEASE_FILES_URL/$file"  # Bouw de volledige URL voor het bestand
    if curl -L -o "$file" "$file_url" --fail --silent; then
        echo "Succesvol gedownload: $file"
        # Controleer of het bestand de hoofd-binary is (zonder .dgst of .sig suffix)
        if [[ $file =~ ^node-${latest_version}-${OS_ARCH}$ ]]; then
            if chmod +x "$file"; then
                echo "Bestand uitvoerbaar gemaakt: $file"
            else
                echo "❌ Fout bij het uitvoerbaar maken van $file"
            fi
        fi
    else
        echo "❌ Fout bij het downloaden van $file van $file_url"
    fi
done

# Versiecontrole en update van cluster_start script
echo "Controleer of $CLUSTER_START_SCRIPT moet worden bijgewerkt..."
current_version=$(grep -oE 'node-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' "$CLUSTER_START_SCRIPT" | sort -V | tail -1)

if [[ "$latest_version" > "$current_version" ]]; then
    echo "Nieuwere versie gedetecteerd in $CLUSTER_START_SCRIPT, bijwerken naar $latest_version"
    sed -i "s/$current_version/$latest_version/g" "$CLUSTER_START_SCRIPT"
    echo "$CLUSTER_START_SCRIPT bijgewerkt naar versie $latest_version"

    # Controleer of het een geldige Git-repository is en werk bij
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
    echo "$CLUSTER_START_SCRIPT is al up-to-date met de laatste versie."
fi

echo "=== Update-script voltooid ==="
