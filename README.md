# SAE502 - Déploiement automatisé d'un serveur VPN WireGuard avec Ansible

Ce projet Ansible permet de déployer automatiquement un serveur VPN WireGuard complet sur Ubuntu avec supervision (Prometheus + Grafana) et interface web de gestion.

## 📋 Table des matières

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Structure du projet](#structure-du-projet)
- [Configuration](#configuration)
- [Sécurité](#sécurité)
- [Dépannage](#dépannage)

## 🏗️ Architecture

Le projet déploie une infrastructure complète comprenant :

- **WireGuard** : Serveur VPN installé directement sur la VM
- **Docker + Docker Compose** : Pour les services conteneurisés
- **Nginx** : Service interne accessible uniquement via VPN
- **WebUI (Flask)** : Interface web pour télécharger les configurations et QR codes
- **Prometheus** : Collecte de métriques
- **WireGuard Exporter** : Export des métriques WireGuard vers Prometheus
- **Grafana** : Visualisation des métriques et supervision

## 📦 Prérequis

### Sur la machine de contrôle (où vous exécutez Ansible)

- Ansible 2.9 ou supérieur
- Python 3
- Accès SSH à la VM Ubuntu cible

### Sur la VM Ubuntu cible

- Ubuntu 20.04 LTS ou supérieur
- Accès SSH avec privilèges sudo
- Connexion Internet

## 🚀 Installation

### 1. Cloner ou télécharger le projet

```bash
cd SAE502
```

### 2. Configurer l'inventaire

Éditez le fichier `inventory.ini` :

```ini
[vpn_servers]
192.168.1.100  # Remplacez par l'IP de votre serveur

[vpn_servers:vars]
ansible_user=axel
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### 3. Configurer les variables

Éditez `group_vars/vpn_servers.yml` pour personnaliser :

- Ports des services
- Mots de passe (utilisez `ansible-vault` pour les secrets)
- Chemins de stockage
- Configuration réseau WireGuard

### 4. Chiffrer les secrets (recommandé)

```bash
# Créer un fichier vault pour les secrets
ansible-vault create group_vars/vpn_servers_vault.yml

# Ajoutez-y :
# wireguard_server_private_key: "votre_clé_privée"
# webui_secret_key: "votre_secret_flask"
# grafana_admin_password: "votre_mot_de_passe_grafana"
```

### 5. Tester la connexion

```bash
ansible vpn_servers -m ping
```

## 📖 Utilisation

### Déploiement complet

Pour installer et configurer toute l'infrastructure :

```bash
ansible-playbook deploy.yml
```

Ce playbook va :
- Installer WireGuard et générer les clés serveur
- Installer Docker et Docker Compose
- Déployer tous les conteneurs (Nginx, WebUI, Prometheus, Grafana)
- Configurer le firewall
- Sécuriser le système

### Ajouter un utilisateur VPN

Pour ajouter un nouvel utilisateur VPN :

```bash
ansible-playbook add_user.yml -e username=john -e user_ip=10.8.0.2
```

**Important** : Chaque utilisateur doit avoir une IP unique dans le réseau VPN (par défaut 10.8.0.0/24).

Le playbook va :
- Générer les clés privée/publique du client
- Créer le fichier de configuration `.conf`
- Générer le QR code
- Ajouter le peer au serveur WireGuard
- Rendre les fichiers accessibles via l'interface WebUI

### Vérifier l'état du système

Pour vérifier l'état de tous les services :

```bash
ansible-playbook check.yml
```

Ce playbook affiche :
- État du service WireGuard
- Nombre de pairs connectés
- État des conteneurs Docker
- Accessibilité des services (Prometheus, Grafana, WebUI)
- Métriques du WireGuard Exporter

## 📁 Structure du projet

```
SAE502/
├── ansible.cfg                 # Configuration Ansible
├── inventory.ini               # Inventaire des serveurs
├── deploy.yml                  # Playbook de déploiement complet
├── add_user.yml                # Playbook d'ajout d'utilisateur
├── check.yml                   # Playbook de vérification
├── group_vars/
│   └── vpn_servers.yml         # Variables globales
├── roles/
│   ├── wireguard/              # Rôle WireGuard
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/wg0.conf.j2
│   │   └── vars/main.yml
│   ├── docker/                 # Rôle Docker
│   ├── nginx/                   # Rôle Nginx (service interne)
│   ├── webui/                   # Rôle WebUI (interface Flask)
│   ├── prometheus/              # Rôle Prometheus
│   ├── grafana/                 # Rôle Grafana
│   ├── adduser/                 # Rôle d'ajout d'utilisateur
│   │   └── scripts/generate_qr.sh
│   └── check/                   # Rôle de vérification
└── README.md
```

## ⚙️ Configuration

### Variables principales

Dans `group_vars/vpn_servers.yml` :

- `wireguard_port` : Port d'écoute WireGuard (défaut: 51820)
- `wireguard_network` : Réseau VPN (défaut: 10.8.0.0/24)
- `webui_port` : Port de l'interface web (défaut: 5000)
- `prometheus_port` : Port Prometheus (défaut: 9090)
- `grafana_port` : Port Grafana (défaut: 3000)

### Configuration du firewall

Le firewall UFW est configuré automatiquement pour :
- Autoriser SSH
- Autoriser le port WireGuard
- Bloquer tout le reste

### Configuration réseau

Assurez-vous que :
- Le port WireGuard est ouvert sur votre routeur/firewall
- Le forwarding IP est activé (fait automatiquement)
- Les règles iptables sont configurées (fait automatiquement)

## 🔒 Sécurité

### Bonnes pratiques appliquées

- Mots de passe masqués dans les logs (`no_log: true`)
- Permissions restrictives sur les fichiers de configuration
- Firewall configuré en mode strict
- Service interne accessible uniquement via VPN
- Utilisation d'ansible-vault recommandée pour les secrets

### Recommandations

1. **Changez tous les mots de passe par défaut**
2. **Utilisez ansible-vault pour les secrets** :
   ```bash
   ansible-vault encrypt_string 'votre_mot_de_passe' --name 'grafana_admin_password'
   ```
3. **Limitez l'accès SSH** (utilisez des clés SSH)
4. **Surveillez les logs** régulièrement
5. **Mettez à jour le système** régulièrement

## 🌐 Accès aux services

Après le déploiement, les services sont accessibles sur :

- **WebUI** : `http://VOTRE_IP:5000` - Interface de gestion des utilisateurs
- **Prometheus** : `http://VOTRE_IP:9090` - Métriques et requêtes
- **Grafana** : `http://VOTRE_IP:3000` - Tableaux de bord (admin/admin par défaut)
- **Service interne Nginx** : `http://10.8.0.1:8080` (uniquement via VPN)

## 🐛 Dépannage

### WireGuard ne démarre pas

```bash
# Vérifier les logs
sudo journalctl -u wg-quick@wg0 -n 50

# Vérifier la configuration
sudo wg show
```

### Les conteneurs Docker ne démarrent pas

```bash
# Vérifier les logs
docker logs <nom_conteneur>

# Vérifier l'état
docker ps -a
```

### Problème de connexion VPN

1. Vérifiez que le port WireGuard est ouvert
2. Vérifiez la configuration client
3. Vérifiez les logs WireGuard : `sudo wg show`

### Erreur de permissions

Assurez-vous que l'utilisateur Ansible a les droits sudo sans mot de passe ou utilisez `--ask-become-pass`.

## 📊 Supervision

### Grafana

1. Connectez-vous à Grafana (port 3000)
2. Ajoutez Prometheus comme source de données :
   - URL : `http://prometheus:9090`
3. Importez ou créez des tableaux de bord pour :
   - Pairs WireGuard actifs
   - Trafic réseau
   - Dernières connexions
   - État du serveur

### Métriques disponibles

Le WireGuard Exporter expose des métriques Prometheus :
- `wireguard_receive_bytes_total` : Octets reçus
- `wireguard_transmit_bytes_total` : Octets transmis
- `wireguard_peers` : Nombre de pairs
- Et plus...

## 📝 Tags disponibles

Vous pouvez exécuter des parties spécifiques avec les tags :

```bash
# Déployer uniquement WireGuard
ansible-playbook deploy.yml --tags wireguard

# Déployer uniquement Docker
ansible-playbook deploy.yml --tags docker

# Ajouter un utilisateur uniquement
ansible-playbook add_user.yml --tags adduser
```

## 🔄 Idempotence

Tous les playbooks sont idempotents. Vous pouvez les exécuter plusieurs fois sans risque. Ansible détectera les changements et n'appliquera que les modifications nécessaires.

## 📚 Ressources

- [Documentation Ansible](https://docs.ansible.com/)
- [Documentation WireGuard](https://www.wireguard.com/)
- [Documentation Prometheus](https://prometheus.io/docs/)
- [Documentation Grafana](https://grafana.com/docs/)

## 👤 Auteur

Projet réalisé dans le cadre de la SAE502.

## 📄 Licence

Ce projet est fourni à des fins éducatives.

---

**Note** : Ce projet est conçu pour un environnement de test/développement. Pour la production, renforcez la sécurité et utilisez ansible-vault pour tous les secrets.
