#!/bin/bash
# Script pour corriger les IPs invalides dans wg0.conf
# À exécuter sur le serveur Ubuntu

echo "🔧 Correction des IPs invalides dans wg0.conf..."

CONFIG_FILE="/etc/wireguard/wg0.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Fichier $CONFIG_FILE introuvable"
    exit 1
fi

# Sauvegarder le fichier
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Corriger les IPs invalides (10.8.0.0.X → 10.8.0.X)
sed -i 's/10\.8\.0\.0\.\([0-9]\+\)/10.8.0.\1/g' "$CONFIG_FILE"

# Supprimer les blocs [Peer] avec des IPs invalides restantes
awk '
    /^\[Peer\]/ { in_peer=1; peer_lines=""; skip_peer=0 }
    in_peer { 
        peer_lines=peer_lines $0 "\n"
        if (/10\.8\.0\.0\.[0-9]+/) skip_peer=1
    }
    /^$/ && in_peer { 
        if (!skip_peer) printf "%s", peer_lines
        in_peer=0; peer_lines=""; skip_peer=0
    }
    !in_peer && !/^\[Peer\]/ { print }
    END { if (in_peer && !skip_peer) printf "%s", peer_lines }
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

# Valider la configuration
if wg-quick strip "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "✅ Configuration validée avec succès"
    echo "🔄 Redémarrage de WireGuard..."
    sudo systemctl restart wg-quick@wg0
    if [ $? -eq 0 ]; then
        echo "✅ WireGuard redémarré avec succès"
    else
        echo "❌ Erreur lors du redémarrage de WireGuard"
        echo "Vérifiez les logs : sudo journalctl -xeu wg-quick@wg0.service"
    fi
else
    echo "❌ La configuration est toujours invalide"
    echo "Vérifiez le fichier : $CONFIG_FILE"
    exit 1
fi

echo "✅ Correction terminée"
