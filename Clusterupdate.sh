#!/bin/bash

# Basis-URL voor de Quilibrium releases zonder /release/
RELEASE_FILES_URL="https://releases.quilibrium.com"
OS_ARCH="linux-amd64"
# Qclient map
QCLIENT_DIR="/root/ceremonyclient/client"

# Lokale directory waar de bestanden worden opgeslagen
DOWNLOAD_DIR="/root/ceremonyclient/node"

# Pad naar het cluster_start script
CLUSTER_START_SCRIPT="/usr/local/bin/cluster_start.sh"

echo "=== Start van het update-script ==="

# Creëer de downloadmap voor qclient als deze niet bestaat
mkdir -p "$QCLIENT_DIR"
cd "$QCLIENT_DIR" || exit

# Haal de nieuwste versie op van de releasepagina
latest_version=$(curl -s "$RELEASE_FILES_URL/qclient-release" | grep -oP 'qclient-\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=-linux-amd64)' | sort -V | tail -1)
echo "Laatste versie gedetecteerd: $latest_version"

# Controleer of de versie correct is opgehaald
if [ -z "$latest_version" ]; then
    echo "❌ Kon de laatste versie niet ophalen van $RELEASE_FILES_URL/qclient-release"
    exit 1
fi

# Controleer of de nieuwste versie al gedownload is
if ls qclient-${latest_version}-${OS_ARCH}* 1> /dev/null 2>&1; then
    echo "Bestanden voor versie $latest_version zijn al aanwezig. Download wordt overgeslagen."
else
    # Haal de lijst met bestanden op van de releasepagina voor de gedetecteerde versie
    mapfile -t RELEASE_FILES < <(curl -s "$RELEASE_FILES_URL/qclient-release" | grep -oE "qclient-${latest_version}-${OS_ARCH}(\.dgst|\.dgst\.sig\.[0-9]+)?")

    # Controleer of er bestanden zijn gedetecteerd
    if [ ${#RELEASE_FILES[@]} -eq 0 ]; then
        echo "❌ Geen bestanden gevonden voor versie $latest_version op $RELEASE_FILES_URL/release"
        exit 1
    fi

    # Download elk bestand in de lijst zonder /release/ in de download-URL
    for file in "${RELEASE_FILES[@]}"; do
        echo "Bezig met downloaden van $file..."
        file_url="${RELEASE_FILES_URL}/${file}"  # Bouw de volledige URL voor het bestand zonder /release/
        echo "Download URL: $file_url"  # Log de volledige URL voor controle

        if curl -L -o "$file" "$file_url" --fail --silent; then
            echo "Succesvol gedownload: $file"
            # Controleer of het bestand de hoofd-binary is (zonder .dgst of .sig suffix)
            if [[ $file =~ ^qclient-${latest_version}-${OS_ARCH}$ ]]; then
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
fi

# Controleer of de downloadmap bestaat en ga naar de downloadmap
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit

# Haal de nieuwste versie op van de releasepagina
latest_version=$(curl -s "$RELEASE_FILES_URL/release" | grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=-linux-amd64)' | sort -V | tail -1)
echo "Laatste versie gedetecteerd: $latest_version"

# Controleer of de versie correct is opgehaald
if [ -z "$latest_version" ]; then
    echo "❌ Kon de laatste versie niet ophalen van $RELEASE_FILES_URL/release"
    exit 1
fi

# Controleer of de nieuwste versie al gedownload is
if ls node-${latest_version}-${OS_ARCH}* 1> /dev/null 2>&1; then
    echo "Bestanden voor versie $latest_version zijn al aanwezig. Download wordt overgeslagen."
else
    # Haal de lijst met bestanden op van de releasepagina voor de gedetecteerde versie
    mapfile -t RELEASE_FILES < <(curl -s "$RELEASE_FILES_URL/release" | grep -oE "node-${latest_version}-${OS_ARCH}(\.dgst|\.dgst\.sig\.[0-9]+)?")

    # Controleer of er bestanden zijn gedetecteerd
    if [ ${#RELEASE_FILES[@]} -eq 0 ]; then
        echo "❌ Geen bestanden gevonden voor versie $latest_version op $RELEASE_FILES_URL/release"
        exit 1
    fi

    # Download elk bestand in de lijst zonder /release/ in de download-URL
    for file in "${RELEASE_FILES[@]}"; do
        echo "Bezig met downloaden van $file..."
        file_url="${RELEASE_FILES_URL}/${file}"  # Bouw de volledige URL voor het bestand zonder /release/
        echo "Download URL: $file_url"  # Log de volledige URL voor controle

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
fi

# Versiecontrole en update van cluster_start script, onafhankelijk van de node map
echo "Controleer of $CLUSTER_START_SCRIPT moet worden bijgewerkt..."

# Debugging: toon bestaande versiepatronen in cluster_start.sh
echo "Huidige versie-inhoud in $CLUSTER_START_SCRIPT:"
grep -oE "node-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?-${OS_ARCH}" "$CLUSTER_START_SCRIPT"

# Vervang alle bestaande versienummers in cluster_start.sh door het volledige nieuwste versiepatroon
sed -i "s/node-[0-9]\+\.[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?-${OS_ARCH}/node-${latest_version}-${OS_ARCH}/g" "$CLUSTER_START_SCRIPT"

# Debugging: Controleer of de vervanging correct is uitgevoerd
echo "Bijgewerkte versie-inhoud in $CLUSTER_START_SCRIPT:"
grep -oE "node-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?-${OS_ARCH}" "$CLUSTER_START_SCRIPT"

# Controleer of /root/ceremonyclient een geldige Git-repository is
cd /root/ceremonyclient || exit
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Git-repository bijwerken voor de nieuwe versie..."
    git pull
    echo "Git-repository is succesvol bijgewerkt naar de nieuwe versie."
else
    echo "Fout: /root/ceremonyclient is geen geldige Git-repository. Probeer opnieuw te initialiseren..."

    # Herstel de repository
    rm -rf .git  # Verwijder eventuele corrupte Git-gegevens
    git init
    git remote add origin https://github.com/QuilibriumNetwork/ceremonyclient.git
    git fetch origin release
    git checkout release
    echo "Git-repository opnieuw geïnitialiseerd en bijgewerkt naar de laatste release."
fi

echo "=== Update-script voltooid ==="
