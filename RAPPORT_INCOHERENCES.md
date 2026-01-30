# Rapport d'analyse des incohérences - Projet SAE502

## 🔍 Résumé exécutif

Ce rapport identifie les incohérences trouvées dans le projet Ansible SAE502. Plusieurs problèmes ont été détectés qui peuvent causer des erreurs lors de l'exécution des playbooks.

---

## ❌ Incohérences critiques

### 1. **Duplication de structure du projet**

**Problème** : Il existe un dossier `SAE502/` à l'intérieur du répertoire de travail `SAE502/`, créant une duplication complète du projet.

**Impact** : Confusion sur quel ensemble de fichiers utiliser, risque d'utiliser les mauvais fichiers.

**Fichiers concernés** :
- Toute la structure du projet est dupliquée

**Recommandation** : Supprimer le sous-dossier `SAE502/` ou clarifier quelle version est la version active.

---

### 2. **Incohérence entre playbook.yml et deploy.yml**

**Problème** : 
- `playbook.yml` (racine) cible le groupe `webservers` et installe une stack LAMP (Apache, PHP, MariaDB)
- `deploy.yml` cible le groupe `vpn_servers` et installe WireGuard
- L'`inventory.ini` (racine) définit `[vpn_servers]` mais pas `[webservers]`
- Le README décrit un projet WireGuard, pas LAMP

**Impact** : `playbook.yml` ne peut pas s'exécuter car le groupe `webservers` n'existe pas dans l'inventaire.

**Fichiers concernés** :
- `playbook.yml` (ligne 5 : `hosts: webservers`)
- `inventory.ini` (définit `[vpn_servers]` mais pas `[webservers]`)
- `README.md` (décrit WireGuard, pas LAMP)

**Recommandation** : 
- Supprimer `playbook.yml` s'il n'est plus utilisé
- OU créer le groupe `[webservers]` dans `inventory.ini` si LAMP est requis
- OU renommer `playbook.yml` en `playbook-lamp.yml` pour clarifier son usage

---

### 3. **Incohérence du réseau VPN (10.8.0.0/24 vs 10.10.10.0/24)**

**Problème** : 
- `group_vars/vpn_servers.yml` (racine) utilise `10.10.10.0/24` (ligne 16)
- `SAE502/group_vars/vpn_servers.yml` utilise `10.8.0.0/24` (ligne 16)
- Le README mentionne `10.8.0.0/24` comme réseau par défaut
- `add_user.yml` utilise `10.10.10.0/24` dans le code (lignes 80, 89, 116)

**Impact** : Les configurations générées peuvent utiliser le mauvais réseau, causant des erreurs de connexion VPN.

**Fichiers concernés** :
- `group_vars/vpn_servers.yml` (ligne 16 : `wireguard_network: "10.10.10.0/24"`)
- `add_user.yml` (lignes 80, 89, 116 : références à `10.10.10.0/24`)
- `README.md` (mentionne `10.8.0.0/24`)
- Plusieurs autres fichiers de documentation

**Recommandation** : 
- Standardiser sur `10.8.0.0/24` (comme dans le README)
- Mettre à jour `group_vars/vpn_servers.yml` (racine) pour utiliser `10.8.0.0/24`
- Mettre à jour `add_user.yml` pour utiliser la variable `wireguard_network` au lieu de valeurs codées en dur

---

### 4. **Incohérence des ports WebUI**

**Problème** :
- `deploy.yml` (ligne 60) mentionne WebUI sur le port 80
- `group_vars/vpn_servers.yml` définit `webui_port: 5000`
- `add_user.yml` (ligne 150) référence `{{ webui_port }}` (correct)

**Impact** : Confusion sur le port réel d'accès au WebUI.

**Fichiers concernés** :
- `deploy.yml` (ligne 60 : `http://{{ ansible_default_ipv4.address }}:80`)
- `group_vars/vpn_servers.yml` (ligne 52 : `webui_port: 5000`)

**Recommandation** : 
- Corriger `deploy.yml` ligne 60 pour utiliser `{{ webui_port }}` au lieu de `80`
- OU vérifier si Nginx fait un reverse proxy vers WebUI sur le port 80

---

### 5. **Incohérence du port Nginx**

**Problème** :
- `group_vars/vpn_servers.yml` (racine) définit `nginx_port: 80` (ligne 47)
- `SAE502/group_vars/vpn_servers.yml` définit `nginx_port: 8080` (ligne 42)
- `deploy.yml` (ligne 65) mentionne le port 8080
- `add_user.yml` (ligne 161) mentionne `{{ nginx_port }}` (correct)

**Impact** : Confusion sur le port réel du service Nginx interne.

**Fichiers concernés** :
- `group_vars/vpn_servers.yml` (racine, ligne 47 : `nginx_port: 80`)
- `SAE502/group_vars/vpn_servers.yml` (ligne 42 : `nginx_port: 8080`)

**Recommandation** : 
- Standardiser sur `nginx_port: 8080` (comme dans le sous-dossier et la documentation)
- Mettre à jour `group_vars/vpn_servers.yml` (racine)

---

### 6. **Incohérence des chemins de stockage WireGuard**

**Problème** :
- `group_vars/vpn_servers.yml` (racine) définit :
  - `wireguard_clients_path: "/etc/wireguard/clients"` (ligne 106)
  - `wireguard_qr_path: "/etc/wireguard/clients/qr"` (ligne 107)
- `SAE502/group_vars/vpn_servers.yml` définit :
  - `wireguard_clients_path: "/opt/wireguard-clients"` (ligne 101)
  - `wireguard_qr_path: "/opt/wireguard-clients/qr"` (ligne 102)

**Impact** : Les fichiers peuvent être créés dans le mauvais répertoire selon la version utilisée.

**Fichiers concernés** :
- `group_vars/vpn_servers.yml` (racine, lignes 106-107)
- `SAE502/group_vars/vpn_servers.yml` (lignes 101-102)

**Recommandation** : 
- Standardiser sur `/opt/wireguard-clients` (plus approprié pour les fichiers clients)
- Mettre à jour `group_vars/vpn_servers.yml` (racine)

---

### 7. **Rôles inutilisés (Apache, PHP, MariaDB, Deploy)**

**Problème** : 
- Les rôles `apache`, `php`, `mariadb`, et `deploy` sont présents dans le projet
- Ils sont utilisés uniquement dans `playbook.yml` (qui cible un groupe inexistant)
- Le projet principal (WireGuard) n'utilise pas ces rôles

**Impact** : Confusion, code mort, maintenance inutile.

**Fichiers concernés** :
- `roles/apache/`
- `roles/php/`
- `roles/mariadb/`
- `roles/deploy/`
- `playbook.yml`

**Recommandation** : 
- Si ces rôles ne sont plus nécessaires, les supprimer
- OU les déplacer dans un sous-dossier `roles-legacy/`
- OU créer un playbook séparé pour LAMP si c'est un projet distinct

---

## ⚠️ Incohérences mineures

### 8. **Références obsolètes dans la documentation**

**Problème** : Le README mentionne encore l'ancien format de commande avec `-e username=john -e user_ip=10.8.0.2`, alors que `add_user.yml` est maintenant interactif.

**Fichiers concernés** :
- `README.md` (ligne 112)

**Recommandation** : Mettre à jour la documentation pour refléter le mode interactif.

---

## 📋 Plan d'action recommandé

### Priorité 1 (Critique - à corriger immédiatement)
1. ✅ Résoudre la duplication de structure (supprimer `SAE502/` ou clarifier)
2. ✅ Corriger l'incohérence du réseau VPN (standardiser sur `10.8.0.0/24`)
3. ✅ Corriger `playbook.yml` ou le supprimer
4. ✅ Standardiser les ports (WebUI et Nginx)

### Priorité 2 (Important - à corriger rapidement)
5. ✅ Standardiser les chemins de stockage WireGuard
6. ✅ Nettoyer les rôles inutilisés

### Priorité 3 (Amélioration - peut attendre)
7. ✅ Mettre à jour la documentation

---

## ✅ Fichiers cohérents

Les fichiers suivants semblent cohérents :
- `deploy.yml` : Structure correcte, utilise les bonnes variables
- `check.yml` : Structure correcte
- `clean_users.yml` : Structure correcte
- `ansible.cfg` : Configuration correcte
- Rôles WireGuard, Docker, Nginx, WebUI, Prometheus, Grafana : Structure cohérente

---

**Date d'analyse** : $(date)
**Version du projet analysée** : Structure actuelle du répertoire SAE502
