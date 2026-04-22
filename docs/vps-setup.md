# VPS Setup (DigitalOcean)

Steps to provision and configure the server hosting tomprince.dev from scratch.

## 1. Create the Droplet

- Image: Ubuntu 24.04 LTS
- Size: Basic, $6/mo (1 vCPU, 1 GB RAM)
- Enable IPv6
- Add SSH public key (`~/.ssh/id_ed25519.pub`) during creation
- Note the IPv4 and IPv6 addresses

## 2. Point DNS

At your domain registrar, add four records:

| Type   | Name  | Value            |
|--------|-------|------------------|
| `A`    | `@`   | Droplet IPv4     |
| `A`    | `www` | Droplet IPv4     |
| `AAAA` | `@`   | Droplet IPv6     |
| `AAAA` | `www` | Droplet IPv6     |

## 3. Initial server setup

SSH in as root:

```sh
ssh root@<droplet-ip>
```

Create the deploy user:

```sh
useradd -m -s /bin/bash deploy
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

Create the web root:

```sh
mkdir -p /var/www/tomprince.dev
chown deploy:deploy /var/www/tomprince.dev
```

## 4. Install Caddy

```sh
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update && apt install caddy
```

## 5. Install the Caddyfile

From your local machine:

```sh
scp Caddyfile root@<droplet-ip>:/etc/caddy/Caddyfile
```

Then on the server:

```sh
systemctl reload caddy
```

Caddy will provision a Let's Encrypt TLS cert automatically on the first request once DNS has propagated.

## 6. Verify deploy user SSH access

From your local machine:

```sh
ssh deploy@tomprince.dev echo ok
```

This must succeed before `scripts/deploy` will work.

## 7. First deploy

From your local repo root:

```sh
scripts/deploy
```

## 8. Security hardening

### Create a sudo user and disable root login

On the server as root:

```sh
adduser tom
usermod -aG sudo tom
mkdir -p /home/tom/.ssh
cp /root/.ssh/authorized_keys /home/tom/.ssh/authorized_keys
chown -R tom:tom /home/tom/.ssh
```

Verify you can SSH in as `tom` before proceeding:

```sh
ssh tom@tomprince.dev
```

Then disable root SSH login. In `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
```

Restart SSH:

```sh
systemctl restart ssh
```

### Firewall

```sh
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
```

### Automatic security updates

```sh
apt install unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

## Verify

- `https://tomprince.dev` loads over HTTPS
- `https://www.tomprince.dev` redirects to apex
- `https://tomprince.dev/index.xml` served as `application/rss+xml`
- TLS cert is Let's Encrypt, valid for `tomprince.dev`
