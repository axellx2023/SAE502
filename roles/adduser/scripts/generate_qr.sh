#!/bin/bash
# Script de génération de QR code pour configuration WireGuard
# Usage: generate_qr.sh <config_file> <qr_output_file>

CONFIG_FILE="${CONFIG_FILE:-$1}"
QR_FILE="${QR_FILE:-$2}"

if [ -z "$CONFIG_FILE" ] || [ -z "$QR_FILE" ]; then
    echo "Usage: CONFIG_FILE=config.conf QR_FILE=output.png $0"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur: Le fichier de configuration $CONFIG_FILE n'existe pas"
    exit 1
fi

# Vérifier que qrencode est installé
if ! command -v qrencode &> /dev/null; then
    echo "Erreur: qrencode n'est pas installé"
    exit 1
fi

# Générer le QR code
qrencode -t PNG -o "$QR_FILE" < "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "QR code généré avec succès: $QR_FILE"
else
    echo "Erreur lors de la génération du QR code"
    exit 1
fi
