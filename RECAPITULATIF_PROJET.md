# 📋 Récapitulatif du projet SAE502

## 🎯 Objectif principal

Le projet **SAE502** est un système automatisé de déploiement d'un **serveur VPN WireGuard complet** avec supervision et interface de gestion. Il permet de créer rapidement une infrastructure VPN sécurisée avec des services internes protégés et un système de monitoring.

---

## 🏗️ Architecture globale

Le projet déploie une infrastructure complète sur une VM Ubuntu comprenant :

### Composants principaux

1. **WireGuard VPN** (installé nativement)
   - Serveur VPN installé directement sur la VM
   - Gestion automatique des clés serveur
   - Configuration réseau VPN (par défaut : 10.8.0.0/24)
   - Port d'écoute : 51820/udp

2. **Docker + Docker Compose**
   - Environnement de conteneurisation pour les services
   - Gestion unifiée des services via Docker Compose

3. **Nginx** (conteneurisé)
   - Service web interne accessible **uniquement via VPN**
   - Port : 8080 (accessible depuis le réseau VPN uniquement)
   - Démonstration d'un service protégé

4. **WebUI** (Flask - conteneurisé)
   - Interface web pour télécharger les configurations VPN
   - Génération et affichage des QR codes
   - Port : 5000 (accessible depuis l'extérieur)
   - Reverse proxy Nginx sur port 80

5. **Prometheus** (conteneurisé)
   - Collecte de métriques système et WireGuard
   - Port : 9090 (accessible depuis l'extérieur pour la démo)

6. **WireGuard Exporter** (conteneurisé)
   - Exporte les métriques WireGuard vers Prometheus
   - Port interne : 9586

7. **Grafana** (conteneurisé)
   - Visualisation des métriques et tableaux de bord
   - Dashboard WireGuard auto-provisionné
   - Port : 3000 (accessible depuis l'extérieur pour la démo)

8. **Firewall UFW**
   - Configuration automatique des règles
   - Protection des services internes

---

## 🔐 Système de rôles utilisateurs

Le projet implémente un système de **3 niveaux d'accès** pour les utilisateurs VPN :

1. **`restricted`** : Accès VPN uniquement (aucun service interne)
2. **`allowed`** : VPN + accès aux services internes (Nginx, Grafana)
3. **`admin`** : Accès complet (tous les services incluant Prometheus)

Les règles d'accès sont gérées via des règles iptables configurées automatiquement.

---

## 📦 Fonctionnalités principales

### 1. Déploiement automatisé (`deploy.yml`)

**Ce que fait le playbook :**
- ✅ Vérifie que le système est Ubuntu
- ✅ Met à jour les paquets système
- ✅ Installe et configure WireGuard (génération des clés serveur)
- ✅ Installe Docker et Docker Compose
- ✅ Déploie tous les conteneurs (Nginx, WebUI, Prometheus, Grafana, WireGuard Exporter)
- ✅ Configure le firewall UFW
- ✅ Configure les règles iptables pour les rôles utilisateurs
- ✅ Active le forwarding IP
- ✅ Sécurise le système

**Durée** : ~5-10 minutes

### 2. Gestion des utilisateurs VPN (`add_user.yml`)

**Mode interactif** - Le playbook demande :
- Nom du client (ex: `smartphone`, `laptop`)
- Rôle (`restricted`, `allowed`, ou `admin`)

**Ce que fait le playbook :**
- ✅ Trouve automatiquement une IP disponible dans le réseau VPN
- ✅ Génère les clés privée/publique du client
- ✅ Crée le fichier de configuration `.conf`
- ✅ Génère le QR code pour importation mobile
- ✅ Ajoute le peer au serveur WireGuard
- ✅ Configure les règles d'accès selon le rôle
- ✅ Rend les fichiers accessibles via WebUI

**Fichiers créés :**
- `/opt/wireguard-clients/<nom>.conf` : Configuration WireGuard
- `/opt/wireguard-clients/qr/<nom>.png` : QR code

### 3. Vérification du système (`check.yml`)

**Ce que fait le playbook :**
- ✅ Vérifie l'état du service WireGuard
- ✅ Affiche les pairs connectés
- ✅ Vérifie l'état des conteneurs Docker
- ✅ Teste l'accessibilité des services (Prometheus, Grafana, WebUI)
- ✅ Affiche les métriques du WireGuard Exporter

### 4. Nettoyage (`clean_users.yml`)

**Ce que fait le playbook :**
- ✅ Supprime tous les fichiers de configuration client
- ✅ Supprime tous les QR codes
- ✅ Nettoie `wg0.conf` (garde uniquement la section `[Interface]`)
- ✅ Supprime le fichier de rôles
- ✅ Recharge WireGuard

**Utilité** : Remet l'infrastructure dans un état "propre" (serveur uniquement)

---

## 🌐 Accès aux services

### Services accessibles depuis l'extérieur (LAN/Internet)

| Service | URL | Description |
|---------|-----|-------------|
| **WebUI** | `http://IP:80` | Interface de gestion (Basic Auth: admin/admin) |
| **Prometheus** | `http://IP:9090` | Métriques et requêtes |
| **Grafana** | `http://IP:3000` | Tableaux de bord (admin/admin) |

### Services internes (accessibles uniquement via VPN)

| Service | URL | Rôle requis |
|---------|-----|-------------|
| **Nginx interne** | `http://10.8.0.1:8080` | `allowed` ou `admin` |
| **Grafana** | `http://10.8.0.1:3000` | `allowed` ou `admin` |
| **Prometheus** | `http://10.8.0.1:9090` | `admin` uniquement |

### Services locaux (localhost uniquement)

| Service | URL | Description |
|---------|-----|-------------|
| **Prometheus** | `http://localhost:9090` | Supervision locale |
| **Grafana** | `http://localhost:3000` | Supervision locale |
| **WireGuard Exporter** | `http://localhost:9586/metrics` | Métriques Prometheus |

---

## 🔄 Flux de travail typique

### Scénario de démonstration

1. **Préparation**
   - VM Ubuntu sur PC portable
   - Partage 4G (hotspot smartphone)
   - Client externe (smartphone ou PC en 4G)

2. **Déploiement**
   ```bash
   ansible-playbook deploy.yml
   ```

3. **Configuration IP publique**
   - Trouver l'IP publique 4G : `curl ifconfig.me` (depuis la VM)
   - Ajouter dans `group_vars/vpn_servers.yml` : `wireguard_server_public_ip: "185.123.45.67"`

4. **Création d'un utilisateur**
   ```bash
   ansible-playbook add_user.yml
   # Demande : nom du client, rôle
   ```

5. **Connexion du client**
   - Télécharger le QR code via WebUI ou copier le fichier `.conf`
   - Importer dans l'app WireGuard
   - Activer la connexion VPN

6. **Test d'accès**
   - ✅ Service interne accessible via VPN : `http://10.8.0.1:8080`
   - ❌ Service interne inaccessible sans VPN

---

## 🛠️ Technologies utilisées

- **Ansible** : Automatisation et orchestration
- **WireGuard** : VPN moderne et performant
- **Docker** : Conteneurisation des services
- **Docker Compose** : Orchestration des conteneurs
- **Nginx** : Service web interne + reverse proxy
- **Flask** : Interface web de gestion
- **Prometheus** : Collecte de métriques
- **Grafana** : Visualisation et dashboards
- **UFW** : Firewall
- **iptables** : Règles de routage et filtrage

---

## 📁 Structure du projet

```
SAE502/
├── ansible.cfg              # Configuration Ansible
├── inventory.ini             # Inventaire des serveurs
├── deploy.yml                # Playbook de déploiement complet
├── add_user.yml              # Playbook d'ajout d'utilisateur (interactif)
├── check.yml                 # Playbook de vérification
├── clean_users.yml           # Playbook de nettoyage
├── group_vars/
│   └── vpn_servers.yml       # Variables globales
├── roles/
│   ├── wireguard/            # Installation et configuration WireGuard
│   ├── docker/               # Installation Docker + déploiement conteneurs
│   ├── nginx/                # Service web interne
│   ├── webui/                # Interface Flask de gestion
│   ├── prometheus/           # Collecte de métriques
│   ├── grafana/              # Visualisation
│   ├── adduser/              # Gestion des utilisateurs VPN
│   ├── firewall/             # Configuration UFW
│   ├── system/               # Configuration système
│   └── check/                # Vérifications
└── README.md
```

---

## 🔒 Sécurité

### Mesures de sécurité implémentées

- ✅ Firewall UFW configuré strictement
- ✅ Services internes accessibles uniquement via VPN
- ✅ Système de rôles pour contrôler l'accès
- ✅ Permissions restrictives sur les fichiers de configuration
- ✅ Mots de passe masqués dans les logs Ansible
- ✅ Support d'ansible-vault pour les secrets

### Recommandations

- 🔐 Changer tous les mots de passe par défaut
- 🔐 Utiliser ansible-vault pour les secrets en production
- 🔐 Limiter l'accès SSH (utiliser des clés SSH)
- 🔐 Surveiller les logs régulièrement
- 🔐 Mettre à jour le système régulièrement

---

## 📊 Supervision et monitoring

### Métriques collectées

- **WireGuard** : Pairs connectés, trafic réseau (octets reçus/transmis)
- **Système** : CPU, mémoire, disque
- **Services** : État des conteneurs Docker

### Dashboards Grafana

- Dashboard WireGuard auto-provisionné
- Visualisation des pairs actifs
- Graphiques de trafic réseau
- Historique des connexions

---

## 🎓 Cas d'usage

1. **Démonstration académique** : Montrer l'automatisation d'infrastructure avec Ansible
2. **VPN personnel** : Créer un VPN pour accéder à distance à des services
3. **Sécurité réseau** : Protéger des services internes derrière un VPN
4. **Apprentissage** : Comprendre WireGuard, Docker, Prometheus, Grafana

---

## ⚙️ Configuration principale

Les variables principales sont dans `group_vars/vpn_servers.yml` :

- `wireguard_network` : Réseau VPN (défaut: 10.8.0.0/24)
- `wireguard_port` : Port WireGuard (défaut: 51820)
- `wireguard_server_public_ip` : IP publique du serveur (4G)
- `webui_port` : Port WebUI (défaut: 5000)
- `nginx_port` : Port Nginx interne (défaut: 8080)
- `prometheus_port` : Port Prometheus (défaut: 9090)
- `grafana_port` : Port Grafana (défaut: 3000)

---

## 🚀 Points forts du projet

1. **Automatisation complète** : Tout est automatisé via Ansible
2. **Idempotence** : Les playbooks peuvent être exécutés plusieurs fois sans risque
3. **Sécurité** : Services internes protégés, système de rôles
4. **Supervision** : Monitoring en temps réel avec Prometheus/Grafana
5. **Interface web** : Gestion simple des utilisateurs via WebUI
6. **QR codes** : Configuration mobile en un scan
7. **Documentation** : Guides complets (README, QUICKSTART, DEMO_GUIDE)

---

## 📝 Commandes essentielles

```bash
# Déploiement complet
ansible-playbook deploy.yml

# Ajouter un utilisateur (interactif)
ansible-playbook add_user.yml

# Vérifier l'état
ansible-playbook check.yml

# Nettoyer tous les utilisateurs
ansible-playbook clean_users.yml

# Voir les pairs connectés
ansible vpn_servers -m shell -a "wg show" --become
```

---

**En résumé** : Le projet SAE502 est une solution complète et automatisée pour déployer un serveur VPN WireGuard avec services internes protégés, interface de gestion, et système de supervision. Tout est configuré via Ansible pour une installation rapide et reproductible.
