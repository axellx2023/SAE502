# 🚀 Déploiement Automatisé - SAE502

## ✅ Automatisation Complète

Le playbook `deploy.yml` est maintenant **entièrement automatisé** et corrige automatiquement tous les problèmes courants sans intervention manuelle.

## 🔧 Corrections Automatiques Intégrées

### 1. **Problème de montage Prometheus (répertoire au lieu de fichier)**

Le playbook détecte et corrige automatiquement :
- ✅ Arrête la stack Docker si elle tourne
- ✅ Arrête et supprime le conteneur Prometheus problématique
- ✅ Détecte si `prometheus.yml` est un répertoire
- ✅ Supprime le répertoire automatiquement
- ✅ Recrée le fichier correctement
- ✅ Vérifie que le fichier est bien créé

### 2. **Gestion des conteneurs Docker**

- ✅ Arrêt automatique des conteneurs avant correction
- ✅ Suppression des conteneurs problématiques
- ✅ Redémarrage automatique après correction

### 3. **Vérifications de sécurité**

- ✅ Vérification du type de fichier avant montage
- ✅ Messages d'erreur explicites en cas d'échec
- ✅ Tentative de correction automatique en cas d'échec

## 📋 Utilisation

### Déploiement simple (tout automatique)

```bash
ansible-playbook -i inventory.ini deploy.yml -K
```

**C'est tout !** Le playbook :
1. Vérifie et corrige automatiquement tous les problèmes
2. Déploie tous les services
3. Vérifie que tout fonctionne

### Déploiement avec tags (pour des parties spécifiques)

```bash
# Corriger uniquement les problèmes de montage
ansible-playbook -i inventory.ini deploy.yml -K --tags fix

# Déployer uniquement Docker
ansible-playbook -i inventory.ini deploy.yml -K --tags docker

# Déployer uniquement WireGuard
ansible-playbook -i inventory.ini deploy.yml -K --tags wireguard
```

## 🔄 Idempotence

Le playbook est **idempotent** :
- ✅ Peut être exécuté plusieurs fois sans problème
- ✅ Détecte les changements et ne modifie que ce qui est nécessaire
- ✅ Corrige automatiquement les problèmes détectés

## 🛠️ Ce qui est automatisé

### Avant le déploiement
- ✅ Vérification du système (Ubuntu)
- ✅ Mise à jour des paquets
- ✅ Arrêt des conteneurs problématiques
- ✅ Correction des fichiers de configuration

### Pendant le déploiement
- ✅ Installation de WireGuard
- ✅ Installation de Docker et Docker Compose
- ✅ Création des fichiers de configuration
- ✅ Déploiement des conteneurs

### Après le déploiement
- ✅ Vérification de l'état des services
- ✅ Vérification de l'accessibilité des services
- ✅ Affichage d'un résumé complet

## ⚠️ Cas d'erreur gérés automatiquement

1. **Répertoire au lieu de fichier** → Supprimé et recréé automatiquement
2. **Conteneur bloqué** → Arrêté et supprimé automatiquement
3. **Fichier de configuration corrompu** → Recréé automatiquement
4. **Problème de permissions** → Corrigé automatiquement

## 📊 Résultat attendu

Après l'exécution du playbook, vous devriez voir :

```
PLAY RECAP
localhost  : ok=XX   changed=XX   unreachable=0    failed=0
```

**Aucune erreur** - Tout est automatisé et fonctionne !

## 🎯 Prochaines étapes après déploiement

1. **Créer un utilisateur VPN** :
   ```bash
   ansible-playbook -i inventory.ini add_user.yml
   ```

2. **Vérifier l'état** :
   ```bash
   ansible-playbook -i inventory.ini check.yml
   ```

3. **Accéder aux services** :
   - WebUI : `http://VOTRE_IP:5000`
   - Grafana : `http://VOTRE_IP:3000`
   - Prometheus : `http://VOTRE_IP:9090`

---

**Le déploiement est maintenant 100% automatisé ! 🎉**
