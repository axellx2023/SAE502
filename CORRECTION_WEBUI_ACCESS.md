# 🔧 Correction de l'accès au WebUI depuis le LAN

## Problème identifié

Le WebUI (port 5000) n'est plus accessible depuis le LAN car il était configuré pour écouter uniquement sur `127.0.0.1:5000`.

## Corrections appliquées

### 1. **Configuration Docker - WebUI accessible depuis le LAN**

**Avant** :
```yaml
ports:
  - "127.0.0.1:5000:5000"  # Accessible uniquement depuis localhost
```

**Après** :
```yaml
ports:
  - "5000:5000"  # Accessible depuis le LAN
```

### 2. **Règles UFW**

- ✅ Port 5000 ouvert sur le LAN
- ✅ Port 80 ouvert pour Nginx reverse-proxy (avec Basic Auth)

## Actions à effectuer

### Redéployer Docker

```bash
ansible-playbook -i inventory.ini deploy.yml --tags docker -K
```

OU redéployer tout :

```bash
ansible-playbook -i inventory.ini deploy.yml -K
```

### Vérifier après redéploiement

Depuis votre machine sur le LAN :

1. **Accès direct au WebUI** :
   - http://192.168.1.62:5000 → doit fonctionner

2. **Accès via Nginx (avec Basic Auth)** :
   - http://192.168.1.62:80 → doit demander admin/admin

## Résultat attendu

✅ **Sans VPN** :
- http://192.168.1.62:5000 → WebUI accessible (sans auth)
- http://192.168.1.62:80 → WebUI accessible (avec Basic Auth: admin/admin)

✅ **Avec VPN** :
- http://10.8.0.1:8080 → Nginx interne
- http://10.8.0.1:3000 → Grafana
- http://10.8.0.1:9090 → Prometheus (si rôle admin)
