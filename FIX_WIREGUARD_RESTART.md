# 🔧 Fix du redémarrage WireGuard

## Problème

WireGuard ne redémarre pas après modification de `wg0.conf` à cause des règles iptables.

## Solution immédiate

### 1. Vérifier les logs WireGuard

```bash
# Sur le serveur
sudo journalctl -xeu wg-quick@wg0.service -n 50
```

### 2. Vérifier le fichier wg0.conf

```bash
# Sur le serveur
sudo cat /etc/wireguard/wg0.conf
```

Recherchez les lignes `PostUp` et `PostDown` - elles ne doivent pas contenir de backslashes (`\`) ni de retours à la ligne.

### 3. Corriger manuellement si nécessaire

Si le fichier contient des backslashes, corrigez-le :

```bash
# Sur le serveur
sudo nano /etc/wireguard/wg0.conf
```

Les lignes PostUp/PostDown doivent être sur une seule ligne, sans backslashes :

```ini
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

### 4. Redémarrer WireGuard

```bash
sudo systemctl restart wg-quick@wg0
sudo systemctl status wg-quick@wg0
```

## Corrections appliquées dans le playbook

1. ✅ Simplification des règles iptables (suppression des backslashes)
2. ✅ Ajout de règle UFW pour autoriser le trafic depuis l'interface WireGuard
3. ✅ Configuration Nginx en mode host pour accès depuis VPN

## Redéploiement

Après correction manuelle, relancez le playbook :

```bash
ansible-playbook -i inventory.ini deploy.yml -K
```

Le playbook devrait maintenant fonctionner correctement.
