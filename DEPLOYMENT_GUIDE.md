# Deployment Guide – Quality Control Application

This guide explains how to deploy the Flask-based *Quality Control Application* to a Linux cloud VPS (Ubuntu 22.04 LTS). The same steps apply to other distributions with minor path changes.

> **Estimated time:** 15–20 minutes (excluding DNS / SSL certificate propagation)

---

## 1. Prerequisites

1. **Cloud VPS** – e.g., DigitalOcean, Linode, AWS EC2, etc. (`$5–10/month` plan is sufficient for small installations)
2. **Public IP address** – or a DNS record pointing to your server.
3. **SSH client** –
   - **Windows**: [PuTTY](https://www.putty.org/) or Windows Terminal/OpenSSH
   - **macOS/Linux**: built-in `ssh` command
4. **Domain (optional)** – e.g., `qc.example.com` for HTTPS.

## 2. Initial Server Setup

1. **Connect via SSH**
   ```bash
   # Windows: open PuTTY ➜ Host Name (or IP) ➜ Open
   ssh root@<YOUR_SERVER_IP>
   ```
2. **Create non-root user** (replace `qcuser`)
   ```bash
   adduser qcuser
   usermod -aG sudo qcuser  # grant sudo
   ````
3. **Harden SSH** (optional but recommended)
   ```bash
   nano /etc/ssh/sshd_config
   # Change: PermitRootLogin no
   # Change: PasswordAuthentication no   (if using key auth)
   systemctl restart sshd
   ```
4. **Update system**
   ```bash
   apt update && apt upgrade -y
   ```

## 3. Install Dependencies

```bash
sudo apt install -y python3 python3-venv python3-pip git nginx
```

*Optional:* Install [fail2ban](https://www.fail2ban.org/) for brute-force protection.

## 4. Clone Project & Virtual Env

```bash
sudo -i -u qcuser       # switch to app user
cd ~
# Clone repository (HTTPS or SSH)
git clone https://github.com/your-org/quality_control_app.git
cd quality_control_app

# Create isolated Python env
python3 -m venv venv
source venv/bin/activate

# Install requirements
pip install --upgrade pip
pip install -r requirements.txt
```

## 5. Environment Configuration

Create `.env` in the project root:

```bash
touch .env
nano .env
```
Add variables (replace values!):

```bash
SECRET_KEY=$(python - << 'PY'
import secrets, os; print(secrets.token_hex(32))
PY)
ADMIN_PASSWORD=Your_Super_Strong_Admin_Password
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=8000
```

Load env vars when activating venv (optional):
```bash
echo 'export $(grep -v "^#" .env | xargs)' >> venv/bin/activate
```

## 6. Database Initialization

```bash
source venv/bin/activate
python app.py  # first run creates SQLite DB & admin account
# Ctrl+C after "Running on http://0.0.0.0:8000" appears.
```

## 7. Gunicorn + Systemd Service

1. **Create service file** `/etc/systemd/system/quality-control.service`:
   ```ini
   [Unit]
   Description=Quality Control Flask App
   After=network.target

   [Service]
   User=qcuser
   Group=www-data
   WorkingDirectory=/home/qcuser/quality_control_app
   EnvironmentFile=/home/qcuser/quality_control_app/.env
   ExecStart=/home/qcuser/quality_control_app/venv/bin/gunicorn \
            --workers 3 \
            --bind 127.0.0.1:8000 \
            --timeout 120 \
            -m 007 \
            wsgi:app
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
2. **Enable & start**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable quality-control
   sudo systemctl start quality-control
   sudo systemctl status quality-control -n 20  # view logs
   ```

## 8. Nginx Reverse Proxy

1. **Create site config** `/etc/nginx/sites-available/quality-control`:
   ```nginx
   server {
       listen 80;
       server_name qc.example.com;

       client_max_body_size 20M;

       location /static/ {
           alias /home/qcuser/quality_control_app/static/;
           access_log off;
           expires 30d;
       }

       location / {
           proxy_pass         http://127.0.0.1:8000;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Proto $scheme;
       }
   }
   ```
2. **Enable site & restart**
   ```bash
   sudo ln -s /etc/nginx/sites-available/quality-control /etc/nginx/sites-enabled/
   sudo nginx -t  # syntax check
   sudo systemctl restart nginx
   ```

### HTTPS (Let’s Encrypt)
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d qc.example.com
# Auto-renew test
sudo certbot renew --dry-run
```

## 9. Firewall Rules (UFW example)

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'   # 80 & 443
sudo ufw enable
sudo ufw status
```

## 10. Updating the Application

```bash
sudo -i -u qcuser
cd ~/quality_control_app
git pull
source venv/bin/activate
pip install -r requirements.txt --upgrade
# Run migrations (if any) by restarting service
sudo systemctl restart quality-control
```

## 11. Backups

1. **SQLite DB** – nightly cron job copy:
   ```bash
   crontab -e
   # m h dom mon dow command
   0 2 * * *  cp /home/qcuser/quality_control_app/quality_control.db /home/qcuser/backups/quality_control-$(date +\%F).db
   ```
2. **Drawings & Exports** – include `static/drawings` in backups.

## 12. Maintenance Scripts

* **reset_data.py** – wipe data & drawings.
* **vacuum** – monthly optimization:
  ```bash
  sqlite3 /home/qcuser/quality_control_app/quality_control.db "VACUUM;"
  ```

## 13. Common Management Commands

| Purpose | Command |
|---------|---------|
| View logs | `journalctl -u quality-control -n 50 -f` |
| Restart app | `sudo systemctl restart quality-control` |
| Nginx logs | `tail -f /var/log/nginx/access.log /var/log/nginx/error.log` |
| Disk usage | `df -h` |
| Available memory | `free -h` |

## 14. Uninstalling

```bash
sudo systemctl stop quality-control
sudo systemctl disable quality-control
sudo rm /etc/systemd/system/quality-control.service
sudo systemctl daemon-reload
sudo rm -rf /home/qcuser/quality_control_app
sudo rm /etc/nginx/sites-enabled/quality-control
sudo systemctl restart nginx
```

---

**Congratulations!** Your Quality Control Application is now live at `https://qc.example.com`.

For support or questions, create an issue in the repository or contact the project maintainer. 