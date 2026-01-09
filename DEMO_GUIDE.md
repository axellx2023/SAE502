# 🎯 Guide de démonstration - SAE502 VPN WireGuard

## Scénario de démo

- **Serveur** : VM Ubuntu sur PC portable
- **Connexion serveur** : Partage 4G (hotspot smartphone)
- **Client** : Smartphone ou PC en 4G (connexion externe)
- **Objectif** : Démontrer l'accès sécurisé à un service interne via VPN

## 📋 Préparation avant la démo

### 1. Configuration de l'inventaire

Éditez `inventory.ini` et remplacez l'IP par celle de votre VM :

```ini
[vpn_servers]
192.168.1.100  # ⬅️ Remplacez par l'IP de votre VM
```

**Comment trouver l'IP de votre VM ?**
```bash
# Depuis la VM Ubuntu
ip addr show
# ou
hostname -I
```

### 2. Configuration des variables (optionnel)

Éditez `group_vars/vpn_servers.yml` si vous voulez personnaliser :
- Ports des services
- Mots de passe (recommandé pour la production)

**Important** : Vous pouvez laisser `wireguard_server_public_ip` vide au début. Le playbook vous aidera à la trouver.

### 3. Test de connexion

```bash
# Tester que vous pouvez vous connecter à la VM
ansible vpn_servers -m ping
```

## 🚀 Déroulement de la démo

### Étape 1 : Déploiement complet

```bash
ansible-playbook deploy.yml
```

**Ce qui se passe :**
- Installation de WireGuard, Docker, et tous les services
- Configuration du firewall
- Déploiement des conteneurs (Nginx, WebUI, Prometheus, Grafana)
- Génération des clés serveur WireGuard

**Durée** : ~5-10 minutes

**À la fin**, le playbook affiche :
- L'IP publique détectée (si disponible)
- Les URLs d'accès aux services

### Étape 2 : Configuration de l'IP publique 4G

**Important** : Pour qu'un client externe se connecte, vous devez configurer l'IP publique 4G.

1. **Trouver votre IP publique 4G** :
   ```bash
   # Depuis la VM Ubuntu
   curl ifconfig.me
   ```

2. **Ajouter l'IP dans group_vars/vpn_servers.yml** :
   ```yaml
   wireguard_server_public_ip: "185.123.45.67"  # Votre IP publique
   ```

3. **Note** : L'IP publique 4G peut changer. Vérifiez-la avant chaque démo.

### Étape 3 : Création d'un utilisateur VPN

```bash
ansible-playbook add_user.yml
```

**Le playbook vous demande interactivement :**
- Nom d'utilisateur (ex: `smartphone`, `laptop`, `demo`)
- IP VPN (ex: `10.8.0.10`, `10.8.0.20`)

**Exemple d'interaction :**
```
Nom d'utilisateur VPN [user1]: smartphone
IP VPN de l'utilisateur (dans le réseau 10.8.0.0/24) [10.8.0.10]: 10.8.0.10
```

**Ce qui est créé :**
- Fichier de configuration `.conf` pour WireGuard
- QR code pour importation mobile
- Ajout du peer au serveur WireGuard

### Étape 4 : Connexion du client

#### Sur smartphone (Android/iOS) :

1. **Installer WireGuard** depuis le Play Store / App Store

2. **Récupérer le QR code** :
   - Option A : Via WebUI : `http://VOTRE_IP:5000`
   - Option B : Copier le fichier depuis la VM : `/opt/wireguard-clients/qr/smartphone.png`

3. **Scanner le QR code** dans l'app WireGuard

4. **Activer la connexion VPN**

#### Sur PC (Windows/Mac/Linux) :

1. **Installer WireGuard** : https://www.wireguard.com/install/

2. **Récupérer le fichier .conf** :
   - Option A : Via WebUI : `http://VOTRE_IP:5000`
   - Option B : Depuis la VM : `/opt/wireguard-clients/smartphone.conf`

3. **Importer le fichier** dans WireGuard

4. **Activer la connexion**

### Étape 5 : Test d'accès au service interne

**Une fois connecté au VPN :**

1. **Vérifier la connexion VPN** :
   - L'app WireGuard doit afficher "Connecté"
   - L'IP VPN doit être visible (ex: 10.8.0.10)

2. **Accéder au service interne Nginx** :
   ```
   http://10.8.0.1:8080
   ```
   ✅ **Doit fonctionner** (vous êtes connecté au VPN)

3. **Tester depuis l'extérieur (sans VPN)** :
   - Désactivez le VPN
   - Essayez d'accéder à `http://VOTRE_IP_PUBLIQUE:8080`
   ❌ **Ne doit PAS fonctionner** (bloqué par le firewall)

### Étape 6 : Démonstration de la supervision

1. **Accéder à Prometheus** :
   ```
   http://VOTRE_IP:9090
   ```
   - Vérifier les métriques WireGuard
   - Rechercher : `wireguard_peers`

2. **Accéder à Grafana** :
   ```
   http://VOTRE_IP:3000
   ```
   - Login : `admin` / `admin`
   - Ajouter Prometheus comme source de données
   - Créer des tableaux de bord pour :
     - Pairs connectés
     - Trafic réseau
     - Dernières connexions

3. **Accéder à WebUI** :
   ```
   http://VOTRE_IP:5000
   ```
   - Voir la liste des utilisateurs
   - Télécharger les configurations
   - Voir les QR codes

## 🔍 Vérifications pendant la démo

### Vérifier l'état du serveur

```bash
ansible-playbook check.yml
```

Affiche :
- État de WireGuard
- Pairs connectés
- État des conteneurs
- Accessibilité des services

### Commandes utiles sur le serveur

```bash
# Voir les pairs WireGuard connectés
sudo wg show

# Voir les logs WireGuard
sudo journalctl -u wg-quick@wg0 -f

# Voir l'état des conteneurs
docker ps

# Voir les logs Nginx
docker logs nginx-internal
```

## ⚠️ Points d'attention pour la démo

1. **IP publique 4G** : Peut changer à chaque connexion. Vérifiez-la avant la démo.

2. **Port forwarding** : Si vous êtes derrière un NAT, le port 51820/udp doit être ouvert.

3. **Firewall du smartphone** : Certains opérateurs bloquent les connexions UDP. Testez avant.

4. **Connexion stable** : Assurez-vous que la connexion 4G est stable pendant la démo.

## 🐛 Dépannage rapide

### Le client ne se connecte pas

1. Vérifiez l'IP publique dans `group_vars/vpn_servers.yml`
2. Vérifiez que le port 51820/udp est ouvert
3. Vérifiez les logs : `sudo journalctl -u wg-quick@wg0`

### Le service interne n'est pas accessible

1. Vérifiez que le client est bien connecté au VPN
2. Vérifiez l'IP VPN du client : doit être dans 10.8.0.0/24
3. Testez : `ping 10.8.0.1` depuis le client

### Les services web ne sont pas accessibles

1. Vérifiez le firewall : `sudo ufw status`
2. Vérifiez les conteneurs : `docker ps`
3. Vérifiez les logs : `docker logs <nom_conteneur>`

## 📊 Checklist de démo

- [ ] VM Ubuntu configurée et accessible
- [ ] `inventory.ini` configuré avec l'IP de la VM
- [ ] `deploy.yml` exécuté avec succès
- [ ] IP publique 4G trouvée et configurée
- [ ] `add_user.yml` exécuté (utilisateur créé)
- [ ] QR code récupéré et testé
- [ ] Client connecté au VPN
- [ ] Service interne accessible via VPN
- [ ] Service interne inaccessible sans VPN
- [ ] Prometheus accessible et fonctionnel
- [ ] Grafana accessible avec tableaux de bord
- [ ] WebUI accessible avec liste des utilisateurs

## 🎓 Points à mettre en avant

1. **Automatisation complète** : Tout est automatisé via Ansible
2. **Sécurité** : Service interne protégé, accessible uniquement via VPN
3. **Supervision** : Métriques en temps réel avec Prometheus/Grafana
4. **Interface web** : Gestion simple des utilisateurs
5. **QR codes** : Configuration mobile en un scan

---

**Bon courage pour votre soutenance ! 🚀**
