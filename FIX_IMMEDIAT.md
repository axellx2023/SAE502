# 🔧 Fix Immédiat - IP Invalide dans wg0.conf

## Problème identifié

WireGuard refuse de démarrer car l'IP générée est invalide : `10.8.0.0.2` au lieu de `10.8.0.2`.

## Fix immédiat sur le serveur

### 1. Corriger wg0.conf

```bash
# Sur le serveur Ubuntu
sudo sed -i 's/AllowedIPs = 10\.8\.0\.0\.\([0-9]\+\)\/32/AllowedIPs = 10.8.0.\1\/32/g' /etc/wireguard/wg0.conf
```

### 2. Redémarrer WireGuard

```bash
sudo systemctl restart wg-quick@wg0
sudo systemctl status wg-quick@wg0 --no-pager
```

### 3. Vérifier

```bash
sudo wg show
sudo grep -n "AllowedIPs" /etc/wireguard/wg0.conf | tail -n 10
```

## Nettoyer les fichiers clients invalides

```bash
# Trouver les fichiers avec IPs invalides
sudo grep -R "10.8.0.0\." /opt/wireguard-clients /etc/wireguard/clients 2>/dev/null

# Supprimer les clients problématiques
sudo rm -f /opt/wireguard-clients/admin*.conf
sudo rm -f /opt/wireguard-clients/qr/admin*.png
```

## Correction du playbook

Le playbook a été corrigé pour :
- ✅ Extraire le préfixe depuis `wireguard_server_ip` (10.8.0.1) au lieu de `wireguard_network` (10.8.0.0/24)
- ✅ Utiliser `regex_replace('\\.[0-9]+$', '')` pour extraire les 3 premiers octets
- ✅ Valider l'IP générée avant de l'ajouter

Après le fix immédiat, relancez le playbook :

```bash
ansible-playbook add_user.yml
```

L'IP devrait maintenant être correcte : `10.8.0.2`, `10.8.0.3`, etc.
