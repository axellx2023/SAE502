# 🔧 Correction du problème d'IP invalide

## Problème identifié

L'IP générée était `10.8.0.0.2` au lieu de `10.8.0.2` à cause d'une mauvaise extraction du préfixe réseau.

## Corrections appliquées

### 1. **Extraction du préfixe réseau corrigée**

Le préfixe est maintenant correctement extrait :
- Avant : `10.8.0.0/24` → `10.8.0.0` (incorrect)
- Après : `10.8.0.0/24` → `10.8.0` (correct)

### 2. **Validation de l'IP avant ajout**

Une vérification est maintenant effectuée pour s'assurer que l'IP est valide avant de l'ajouter au fichier de configuration.

### 3. **Nettoyage automatique des IPs invalides**

Le playbook nettoie automatiquement les IPs invalides qui pourraient déjà exister dans `wg0.conf` :
- Détecte les IPs au format `10.8.0.0.X`
- Les corrige en `10.8.0.X`
- Supprime les blocs [Peer] avec des IPs invalides

### 4. **Handler amélioré**

Le handler de redémarrage WireGuard :
- Valide la configuration avant redémarrage
- Corrige automatiquement les problèmes détectés
- Affiche des messages d'erreur clairs
- N'essaie pas de redémarrer si la configuration est invalide

## Actions à effectuer

### Option 1 : Relancer le playbook (recommandé)

Le playbook devrait maintenant corriger automatiquement le problème :

```bash
ansible-playbook add_user.yml
```

### Option 2 : Nettoyer manuellement le fichier wg0.conf

Si le problème persiste, nettoyez manuellement le fichier :

```bash
# Sur le serveur
sudo sed -i 's/10\.8\.0\.0\./10.8.0./g' /etc/wireguard/wg0.conf
sudo systemctl restart wg-quick@wg0
```

### Option 3 : Supprimer le client problématique

Si vous voulez repartir de zéro :

```bash
# Supprimer le fichier de configuration client
sudo rm /opt/wireguard-clients/admin.conf
sudo rm /opt/wireguard-clients/qr/admin.png

# Nettoyer wg0.conf (supprimer le bloc [Peer] avec l'IP invalide)
sudo nano /etc/wireguard/wg0.conf
# Supprimez le bloc [Peer] contenant "10.8.0.0.2"

# Redémarrer WireGuard
sudo systemctl restart wg-quick@wg0

# Relancer le playbook
ansible-playbook add_user.yml
```

## Vérification

Après correction, vérifiez que l'IP est correcte :

```bash
# Vérifier la configuration
sudo cat /etc/wireguard/wg0.conf | grep -A 3 "admin"

# Vérifier que WireGuard fonctionne
sudo systemctl status wg-quick@wg0
sudo wg show
```

L'IP devrait être `10.8.0.2` et non `10.8.0.0.2`.
