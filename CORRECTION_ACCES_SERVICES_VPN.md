# 🔧 Correction de l'accès aux services internes via VPN

## Problème identifié

Quand un client est connecté au VPN depuis le même LAN que le serveur, il ne peut pas accéder aux services internes via les IPs VPN (10.8.0.1:8080, 10.8.0.1:3000, etc.).

## Corrections appliquées

### 1. **Configuration Docker - Nginx en mode host**

Nginx utilise maintenant `network_mode: host` au lieu d'un réseau Docker séparé, ce qui permet l'accès depuis l'interface WireGuard (10.8.0.1).

**Avant** :
```yaml
nginx:
  ports:
    - "8080:80"
  networks:
    - vpn_network
```

**Après** :
```yaml
nginx:
  network_mode: host
```

### 2. **Règles UFW pour le réseau VPN**

Ajout de règles UFW pour autoriser l'accès depuis tout le réseau VPN (10.8.0.0/24) vers les services internes :

- Port 8080 (Nginx) : accessible depuis 10.8.0.0/24
- Port 3000 (Grafana) : accessible depuis 10.8.0.0/24
- Port 9090 (Prometheus) : accessible uniquement pour les clients avec rôle "admin" (règles individuelles)

### 3. **Règles iptables dans WireGuard**

Ajout de règles iptables dans `wg0.conf` pour permettre le routage depuis l'interface WireGuard vers les services :

```bash
iptables -I INPUT -i wg0 -j ACCEPT
iptables -I INPUT -s 10.8.0.0/24 -d 10.8.0.1 -j ACCEPT
```

### 4. **WebUI accessible depuis le LAN**

Le WebUI (port 5000) reste accessible depuis le LAN pour télécharger les configs avant de se connecter au VPN.

## Actions à effectuer

### 1. Redéployer la configuration

```bash
# Redéployer le firewall avec les nouvelles règles
ansible-playbook deploy.yml --tags firewall

# Redéployer Docker avec la nouvelle configuration Nginx
ansible-playbook deploy.yml --tags docker

# Redémarrer WireGuard pour appliquer les nouvelles règles iptables
ansible-playbook deploy.yml --tags wireguard
```

OU redéployer tout :

```bash
ansible-playbook deploy.yml
```

### 2. Vérifier les règles UFW

```bash
# Sur le serveur
sudo ufw status numbered | grep -E "8080|3000|9090|10.8.0"
```

Vous devriez voir :
- `8080/tcp ALLOW 10.8.0.0/24`
- `3000/tcp ALLOW 10.8.0.0/24`
- Règles individuelles pour chaque client selon son rôle

### 3. Vérifier les règles iptables

```bash
# Sur le serveur
sudo iptables -L INPUT -n -v | grep wg0
sudo iptables -L INPUT -n -v | grep "10.8.0"
```

### 4. Tester l'accès

Depuis votre téléphone connecté au VPN :

1. **Vérifier la connexion VPN** :
   ```bash
   # Depuis le téléphone (via app WireGuard)
   # L'IP VPN doit être visible (ex: 10.8.0.2)
   ```

2. **Tester l'accès aux services** :
   - http://10.8.0.1:8080 (Nginx) → doit fonctionner
   - http://10.8.0.1:3000 (Grafana) → doit fonctionner
   - http://10.8.0.1:9090 (Prometheus) → doit fonctionner si rôle "admin"

3. **Tester depuis le LAN (sans VPN)** :
   - http://192.168.1.62:5000 (WebUI) → doit fonctionner pour télécharger les configs

## Résultat attendu

✅ **Sans VPN** : Accès au WebUI sur http://192.168.1.62:5000 pour télécharger les configs

✅ **Avec VPN** : Accès aux services internes via :
- http://10.8.0.1:8080 (Nginx)
- http://10.8.0.1:3000 (Grafana)
- http://10.8.0.1:9090 (Prometheus, si rôle admin)

## Dépannage

Si ça ne fonctionne toujours pas :

1. **Vérifier que WireGuard est actif** :
   ```bash
   sudo wg show
   sudo systemctl status wg-quick@wg0
   ```

2. **Vérifier les logs Nginx** :
   ```bash
   sudo docker logs nginx-internal
   ```

3. **Vérifier les règles UFW** :
   ```bash
   sudo ufw status verbose
   ```

4. **Tester depuis le serveur** :
   ```bash
   curl http://10.8.0.1:8080
   curl http://10.8.0.1:3000
   ```

5. **Vérifier le routage** :
   ```bash
   ip route show
   # Doit montrer une route vers 10.8.0.0/24 via wg0
   ```
