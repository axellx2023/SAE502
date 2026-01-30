# 🚀 Guide de démarrage rapide - SAE502 VPN WireGuard

## Installation en 5 minutes

### 1. Prérequis

```bash
# Installer les collections Ansible nécessaires
ansible-galaxy collection install -r requirements-ansible.yml
```

### 2. Configuration de l'inventaire

Éditez `inventory.ini` et ajoutez l'IP de votre serveur Ubuntu :

```ini
[vpn_servers]
192.168.1.100  # Votre IP ici
```

### 3. Configuration des secrets (optionnel mais recommandé)

```bash
# Créer un fichier vault pour les secrets
ansible-vault create group_vars/vpn_servers_vault.yml

# Ajoutez-y vos secrets (voir vault.example.yml)
```

### 4. Déploiement complet

```bash
# Tester la connexion
ansible vpn_servers -m ping

# Déployer tout le système
ansible-playbook deploy.yml
```

### 5. Ajouter un utilisateur VPN

```bash
ansible-playbook add_user.yml -e username=john -e user_ip=10.8.0.2
```

### 6. Vérifier l'état

```bash
ansible-playbook check.yml
```

## Accès aux services

- **WebUI** : http://VOTRE_IP:5000
- **Prometheus** : http://VOTRE_IP:9090
- **Grafana** : http://VOTRE_IP:3000 (admin/admin par défaut)
- **Service interne** : http://10.8.0.1:8080 (uniquement via VPN)

## Commandes utiles

```bash
# Voir les pairs WireGuard connectés
ansible vpn_servers -m shell -a "wg show"

# Redémarrer WireGuard
ansible vpn_servers -m systemd -a "name=wg-quick@wg0 state=restarted" --become

# Voir les logs
ansible vpn_servers -m shell -a "journalctl -u wg-quick@wg0 -n 50" --become
```

## Dépannage rapide

**Problème de connexion SSH ?**
- Vérifiez que l'utilisateur a les droits sudo
- Testez avec `ansible vpn_servers -m ping`

**WireGuard ne démarre pas ?**
- Vérifiez les logs : `sudo journalctl -u wg-quick@wg0`
- Vérifiez la configuration : `sudo cat /etc/wireguard/wg0.conf`

**Les conteneurs ne démarrent pas ?**
- Vérifiez Docker : `docker ps -a`
- Vérifiez les logs : `docker logs <nom_conteneur>`

### VPN en 4G (téléphone sur un autre réseau)

L’**IP publique** utilisée comme Endpoint dans les configs client est **détectée automatiquement** par le serveur VPN (via api.ipify.org). Aucune configuration manuelle n’est nécessaire : déploiement et `add_user.yml` remplissent déjà la bonne IP pour la 4G.

**Si la connexion 4G échoue quand même :**  
- Vérifier que le serveur a bien accès à Internet (la détection doit pouvoir joindre api.ipify.org).  
- Si le serveur est derrière une box (NAT), rediriger le port **UDP 51820** vers le serveur VPN.  
- Pour forcer une IP précise (ex. IP 4G qui change), définir `wireguard_server_public_ip` dans `group_vars/vpn_servers.yml`, puis régénérer la config client :  
  `ansible-playbook regenerate_client_endpoint.yml -e "client_name=mon-client"`

## Prochaines étapes

1. Changez tous les mots de passe par défaut
2. Configurez Grafana avec Prometheus comme source de données
3. Créez des tableaux de bord de supervision
4. Ajoutez vos utilisateurs VPN

Pour plus de détails, consultez le [README.md](README.md).
