#!/bin/bash

# Basis URL en architectuur
RELEASE_FILES_URL="https://quilibrium-releases.com"
OS_ARCH="linux-amd64"
NODE_DIR="/root/ceremonyclient/node"
QCLIENT_DIR="/root/ceremonyclient/client"
CLUSTER_START_SCRIPT="/usr/local/bin/cluster_start.sh"

# Creëer de downloadmap voor de node-component als deze niet bestaat
mkdir -p "$NODE_DIR"
cd "$NODE_DIR"

# Ophalen en downloaden van de nieuwste versie van de node-component
latest_version=$(curl -s "$RELEASE_FILES_URL/release" | grep -oP 'node-\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=-linux-amd64)' | sort -V | tail -n 1)
echo "Downloaden van node-component versie $latest_version..."
curl -LO "$RELEASE_FILES_URL/node-${latest_version}-${OS_ARCH}"
mv "node-${latest_version}-${OS_ARCH}" "node"
chmod +x "node"
echo "node-component bijgewerkt naar versie $latest_version"

# Update het cluster_start.sh script met de nieuwste versie van node-component
sed -i "s/VERSION=.*/VERSION=$latest_version/" "$CLUSTER_START_SCRIPT"

# Creëer de downloadmap voor qclient als deze niet bestaat
mkdir -p "$QCLIENT_DIR"
cd "$QCLIENT_DIR"

# Ophalen en downloaden van de nieuwste versie van de qclient-component
latest_qclient_version=$(curl -s "$RELEASE_FILES_URL/qclient-release" | grep -oP 'qclient-\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=-linux-amd64)' | sort -V | tail -n 1)
echo "Downloaden van qclient versie $latest_qclient_version..."
curl -LO "$RELEASE_FILES_URL/qclient-${latest_qclient_version}-${OS_ARCH}"
mv "qclient-${latest_qclient_version}-${OS_ARCH}" "qclient"
chmod +x "qclient"
echo "qclient bijgewerkt naar versie $latest_qclient_version"
