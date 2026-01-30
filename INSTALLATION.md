# Étapes d'installation (déploiement en entier)

## 1. Préparer la machine où vous lancez Ansible

```bash
cd c:\Users\axell\SAE ANSBLE\SAE502
pip install ansible
ansible-galaxy collection install -r requirements-ansible.yml
```

## 2. Configurer l'inventaire

Ouvrir **`inventory.ini`** et mettre l'IP (ou le hostname) du serveur Ubuntu :

```ini
[vpn_servers]
192.168.101.137

[vpn_servers:vars]
ansible_user=axel
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```

## 3. Tester la connexion

```bash
ansible vpn_servers -m ping
```

## 4. Déployer en entier (un seul playbook)

```bash
ansible-playbook deploy.yml
```

Si sudo demande un mot de passe :

```bash
ansible-playbook deploy.yml --ask-become-pass
```

**deploy.yml** fait tout : système, firewall, WireGuard, Docker (stack complète), Nginx.

## 5. Créer un utilisateur VPN

```bash
ansible-playbook add_user.yml
```

Indiquer le nom du client (ex. **admin**) et le rôle (**restricted** / **allowed** / **admin**). Le playbook génère la config et le QR code.

## 6. (Optionnel) Vérifier

```bash
ansible-playbook check.yml
```

---

## En résumé : quels playbooks lancer et dans quel ordre

| Étape | Commande | Rôle |
|-------|----------|------|
| 1 | `ansible-galaxy collection install -r requirements-ansible.yml` | Installer les collections Ansible |
| 2 | Éditer `inventory.ini` | Cibler le bon serveur |
| 3 | `ansible vpn_servers -m ping` | Vérifier la connexion |
| 4 | **`ansible-playbook deploy.yml`** | Déploiement complet (tout le serveur) |
| 5 | **`ansible-playbook add_user.yml`** | Créer au moins un client VPN |
| 6 | `ansible-playbook check.yml` | (Optionnel) Vérifier l'état |

Pour déployer en entier, il suffit de lancer **deploy.yml** puis **add_user.yml**. Le détail est dans ce fichier **INSTALLATION.md**.
