# Étapes d'installation – Déploiement complet SAE502

Guide pour déployer le serveur VPN WireGuard en entier.

---

## Prérequis

- **Machine cible** : Ubuntu (serveur ou VM).
- **Machine où vous lancez Ansible** : Windows, Linux ou macOS, avec Ansible installé.
- Accès SSH (avec sudo) à la machine cible.

---

## Étape 1 : Cloner ou copier le projet

```bash
cd c:\Users\axell\SAE ANSBLE\SAE502
# (ou le chemin de votre projet)
```

---

## Étape 2 : Installer Ansible et les collections

Sur la machine **où vous exécutez les playbooks** (votre PC) :

```bash
# Installer Ansible si besoin (ex. sur Windows : pip install ansible)
pip install ansible

# Installer les collections requises
ansible-galaxy collection install -r requirements-ansible.yml
```

---

## Étape 3 : Configurer l'inventaire

Éditez **`inventory.ini`** et mettez l’IP ou le hostname de votre serveur Ubuntu :

```ini
[vpn_servers]
192.168.101.137

[vpn_servers:vars]
ansible_user=ubuntu
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```

- Remplacez `192.168.101.137` par l’IP de votre serveur.
- Remplacez `ubuntu` par l’utilisateur SSH si différent.
- Pour tester en local sur la même machine : `localhost ansible_connection=local`

---

## Étape 4 : Tester la connexion

```bash
ansible vpn_servers -m ping
```

Vous devez voir `pong` pour chaque serveur. Si ça échoue, vérifiez SSH (utilisateur, clé, firewall).

---

## Étape 5 : Déployer en entier (un seul playbook)

```bash
ansible-playbook deploy.yml
```

Si sudo demande un mot de passe :

```bash
ansible-playbook deploy.yml --ask-become-pass
```

**Ce playbook fait tout :**

| Rôle      | Rôle Ansible | Effet |
|-----------|--------------|--------|
| system    | system       | Préparation système (paquets de base, timezone, etc.) |
| firewall  | firewall     | UFW : SSH, WireGuard 51820/udp, règles VPN, etc. |
| wireguard | wireguard    | Installation WireGuard, wg0, détection IP publique, **mise à jour Endpoint de tous les clients** + QR |
| docker    | docker       | Docker + Docker Compose, stack unifiée (webapp, nginx, prometheus, grafana, wireguard-exporter) |
| nginx     | nginx        | Nginx (reverse proxy, config, intégration) |

À la fin, un résumé s’affiche (URLs, ports, prochaines étapes).

---

## Étape 6 : Créer au moins un utilisateur VPN

```bash
ansible-playbook add_user.yml
```

Le playbook demande :

- **Nom du client** (ex. `admin` ou `user1`)
- **Rôle** : `restricted`, `allowed` ou `admin`

Il génère la config client, le QR code et ajoute le peer dans WireGuard. Les configs et QR sont dans `/etc/wireguard/clients/` sur le serveur.

---

## Étape 7 (optionnel) : Vérifier l’état

```bash
ansible-playbook check.yml
```

Affiche l’état des services et conteneurs.

---

## Récapitulatif des playbooks à lancer

| Ordre | Playbook            | Obligatoire | Rôle |
|-------|---------------------|------------|------|
| 1     | `deploy.yml`        | Oui        | Déploiement complet (system, firewall, wireguard, docker, nginx) |
| 2     | `add_user.yml`      | Oui        | Créer au moins un client VPN pour se connecter |
| 3     | `check.yml`         | Non        | Vérifier que tout tourne |

**En résumé :**

1. `ansible-galaxy collection install -r requirements-ansible.yml`
2. Éditer `inventory.ini` (IP du serveur, user SSH).
3. `ansible vpn_servers -m ping`
4. `ansible-playbook deploy.yml` (et `--ask-become-pass` si besoin).
5. `ansible-playbook add_user.yml` (créer un client VPN).

Après ça, vous pouvez récupérer le `.conf` ou le QR du client (WebUI ou depuis le serveur) et vous connecter au VPN (y compris en 4G, l’Endpoint est mis à jour automatiquement à chaque deploy).
