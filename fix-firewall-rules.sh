#!/bin/bash
# Script pour supprimer les règles UFW générales pour le réseau VPN
# et ne garder que les règles individuelles par IP

set -e

echo "🔍 Recherche des règles UFW générales pour le réseau VPN (10.8.0.0/24)..."
echo ""

# Afficher les règles existantes
echo "Règles UFW actuelles concernant le réseau VPN :"
sudo ufw status numbered | grep -E "10\.8\.0\.0/24.*(8080|3000|9090)" || echo "Aucune règle générale trouvée."

echo ""
echo "⚠️  Si des règles générales existent, elles doivent être supprimées."
echo "Les règles doivent être individuelles par IP selon le rôle de l'utilisateur."
echo ""
echo "Pour supprimer une règle, utilisez :"
echo "  sudo ufw status numbered"
echo "  sudo ufw delete [NUMERO_DE_LA_REGLE]"
echo ""
echo "Exemple de règles individuelles correctes :"
echo "  - 10.8.0.2 → Port 8080 (allowed)"
echo "  - 10.8.0.2 → Port 3000 (allowed)"
echo "  - 10.8.0.3 → Port 8080 (admin)"
echo "  - 10.8.0.3 → Port 3000 (admin)"
echo "  - 10.8.0.3 → Port 9090 (admin)"
echo ""
echo "❌ Règles générales à supprimer (si présentes) :"
echo "  - 10.8.0.0/24 → Port 8080"
echo "  - 10.8.0.0/24 → Port 3000"
echo "  - 10.8.0.0/24 → Port 9090"
