# 🔒 Correction des droits d'accès par rôle utilisateur

## Problème identifié

Les règles UFW générales pour tout le réseau VPN (10.8.0.0/24) permettaient à tous les utilisateurs, même "restricted", d'accéder aux services internes.

## Corrections appliquées

### 1. **Suppression des règles générales pour le réseau VPN**

Les règles générales `ufw allow from 10.8.0.0/24` ont été supprimées. Seules les règles individuelles par IP sont maintenant utilisées.

### 2. **Règles individuelles par rôle**

Les règles sont maintenant ajoutées individuellement selon le rôle :

- **restricted** : Aucune règle → VPN uniquement, aucun service
- **allowed** : Règles pour Nginx (8080) et Grafana (3000)
- **admin** : Règles pour Nginx (8080), Grafana (3000) et Prometheus (9090)

### 3. **Vérification des règles existantes**

Le playbook vérifie maintenant s'il existe des règles générales pour le réseau VPN et avertit si c'est le cas.

## Actions à effectuer

### 1. Supprimer les règles générales existantes (si présentes)

```bash
# Sur le serveur
sudo ufw status numbered

# Supprimer les règles qui autorisent 10.8.0.0/24 vers les ports 8080, 3000, 9090
# Exemple : sudo ufw delete [NUMERO]
```

### 2. Redéployer le firewall

```bash
ansible-playbook -i inventory.ini deploy.yml --tags firewall -K
```

### 3. Recréer les utilisateurs pour appliquer les bonnes règles

Pour chaque utilisateur existant, vous pouvez soit :

**Option A : Supprimer et recréer**
```bash
# Supprimer les règles existantes pour un utilisateur
sudo ufw status numbered | grep "10.8.0.X"
sudo ufw delete [NUMERO_DE_LA_REGLE]

# Recréer l'utilisateur avec le bon rôle
ansible-playbook add_user.yml
```

**Option B : Ajouter manuellement les règles selon le rôle**

Pour un utilisateur "restricted" (10.8.0.2) :
```bash
# Aucune règle à ajouter - VPN uniquement
```

Pour un utilisateur "allowed" (10.8.0.3) :
```bash
sudo ufw allow from 10.8.0.3 to any port 8080 proto tcp
sudo ufw allow from 10.8.0.3 to any port 3000 proto tcp
```

Pour un utilisateur "admin" (10.8.0.4) :
```bash
sudo ufw allow from 10.8.0.4 to any port 8080 proto tcp
sudo ufw allow from 10.8.0.4 to any port 3000 proto tcp
sudo ufw allow from 10.8.0.4 to any port 9090 proto tcp
```

## Vérification

### Vérifier les règles UFW

```bash
# Sur le serveur
sudo ufw status numbered | grep -E "8080|3000|9090"
```

Vous devriez voir uniquement des règles individuelles par IP, pas de règles pour `10.8.0.0/24`.

### Tester les accès selon le rôle

**Utilisateur "restricted" (10.8.0.2)** :
- ❌ http://10.8.0.1:8080 → doit être bloqué
- ❌ http://10.8.0.1:3000 → doit être bloqué
- ❌ http://10.8.0.1:9090 → doit être bloqué

**Utilisateur "allowed" (10.8.0.3)** :
- ✅ http://10.8.0.1:8080 → doit fonctionner
- ✅ http://10.8.0.1:3000 → doit fonctionner
- ❌ http://10.8.0.1:9090 → doit être bloqué

**Utilisateur "admin" (10.8.0.4)** :
- ✅ http://10.8.0.1:8080 → doit fonctionner
- ✅ http://10.8.0.1:3000 → doit fonctionner
- ✅ http://10.8.0.1:9090 → doit fonctionner

## Résultat attendu

✅ **restricted** : VPN uniquement, aucun service interne accessible
✅ **allowed** : VPN + Nginx (8080) + Grafana (3000)
✅ **admin** : VPN + tous les services (8080, 3000, 9090)
