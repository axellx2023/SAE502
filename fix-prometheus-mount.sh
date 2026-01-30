#!/bin/bash
# Script de correction pour le problème de montage Prometheus
# À exécuter sur le serveur cible si le problème persiste

echo "🔧 Correction du problème de montage Prometheus..."

# Supprimer le répertoire prometheus.yml s'il existe
if [ -d "/opt/vpn_stack/prometheus/prometheus.yml" ]; then
    echo "❌ Détection d'un répertoire au lieu d'un fichier : /opt/vpn_stack/prometheus/prometheus.yml"
    echo "🗑️  Suppression du répertoire..."
    sudo rm -rf /opt/vpn_stack/prometheus/prometheus.yml
    echo "✅ Répertoire supprimé"
fi

# Arrêter et supprimer le conteneur Prometheus s'il existe
if docker ps -a | grep -q prometheus; then
    echo "🛑 Arrêt du conteneur Prometheus..."
    sudo docker stop prometheus 2>/dev/null || true
    sudo docker rm prometheus 2>/dev/null || true
    echo "✅ Conteneur supprimé"
fi

# S'assurer que le répertoire parent existe
sudo mkdir -p /opt/vpn_stack/prometheus
sudo chmod 755 /opt/vpn_stack/prometheus

echo "✅ Correction terminée. Vous pouvez maintenant relancer le playbook."
