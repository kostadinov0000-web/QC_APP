# Safe Server Update Guide

## 🚀 How to Update Your Quality Control App Without Losing Data

This guide shows you how to safely deploy your latest changes to your Linux VPS while preserving all your measurements, products, molds, and uploaded files.

---

## 📋 Quick Update Process

### Step 1: Commit and Push Your Changes

On your **Windows development machine**:

```bash
# Add all changes
git add .

# Commit with descriptive message
git commit -m "Add mobile navigation, search functionality, timezone fixes, tolerance tables, and robust measurement system"

# Push to GitHub
git push origin main
```

### Step 2: Update Your VPS Server

SSH into your **Linux VPS server**:

```bash
ssh your-username@your-server-ip
cd ~/quality_control_app
```

Run the safe update script:

```bash
# Make script executable (first time only)
chmod +x update_server.sh

# Run the safe update
./update_server.sh
```

---

## 🛡️ What the Update Script Does

### ✅ **Data Protection:**
1. **Creates timestamped backup** of database and files
2. **Backs up configuration** (.env file)
3. **Preserves all measurements** and products
4. **Saves uploaded drawings** and tolerance tables

### ✅ **Safe Update Process:**
1. **Stops application** gracefully
2. **Pulls latest code** from GitHub
3. **Updates dependencies** (Python packages, CSS)
4. **Runs database migrations** automatically
5. **Restarts application** service

### ✅ **Verification:**
1. **Checks service status** after restart
2. **Tests application response** 
3. **Provides monitoring commands**
4. **Shows rollback instructions** if needed

---

## 📁 What Gets Preserved

### 🗄️ **Database:**
- All measurements
- All products and dimensions  
- All molds and maintenance records
- User accounts and settings
- Machine assignments

### 📄 **Files:**
- All uploaded drawings (`static/drawings/`)
- All tolerance tables (`static/tolerance_tables/`)
- Configuration files (`.env`)

### ⚙️ **Settings:**
- Admin passwords
- Secret keys
- Service configuration

---

## 🔧 Manual Update Steps (Alternative)

If you prefer manual control:

### 1. Create Backup
```bash
# Create backup directory
mkdir -p backups/manual_$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/manual_$(date +%Y%m%d_%H%M%S)"

# Backup critical files
cp quality_control.db "$BACKUP_DIR/"
cp -r static/drawings "$BACKUP_DIR/" 2>/dev/null || true
cp -r static/tolerance_tables "$BACKUP_DIR/" 2>/dev/null || true
cp .env "$BACKUP_DIR/" 2>/dev/null || true

echo "Backup created: $BACKUP_DIR"
```

### 2. Stop Service
```bash
sudo systemctl stop quality-control
```

### 3. Update Code
```bash
git stash  # Save any local changes
git pull origin main
```

### 4. Update Dependencies
```bash
source venv/bin/activate
pip install -r requirements.txt --upgrade

# Rebuild CSS if needed
npm install
npx tailwindcss -i static/css/input.css -o static/css/output.css
```

### 5. Run Migrations
```bash
# Start app briefly to trigger database migrations
timeout 10 python app.py || true
```

### 6. Restart Service
```bash
sudo systemctl start quality-control
sudo systemctl status quality-control
```

---

## 🆘 Emergency Rollback

If something goes wrong:

### Restore Database:
```bash
cp backups/update_YYYYMMDD_HHMMSS/quality_control.db .
```

### Restore Files:
```bash
cp -r backups/update_YYYYMMDD_HHMMSS/drawings_backup static/drawings
cp -r backups/update_YYYYMMDD_HHMMSS/tolerance_tables_backup static/tolerance_tables
```

### Restart Service:
```bash
sudo systemctl restart quality-control
```

---

## 📊 Monitoring After Update

### Check Service Status:
```bash
sudo systemctl status quality-control
```

### View Recent Logs:
```bash
sudo journalctl -u quality-control -f
```

### Test Application:
```bash
curl http://localhost:8000
# Should return HTML content
```

### Check Database:
```bash
sqlite3 quality_control.db "SELECT COUNT(*) FROM measurements;"
sqlite3 quality_control.db "SELECT COUNT(*) FROM products;"
```

---

## 🔄 Regular Maintenance

### Daily Backup (Automated):
Add to crontab:
```bash
crontab -e
# Add this line:
0 2 * * * /home/your-username/quality_control_app/backup.sh
```

### Weekly Database Optimization:
```bash
sqlite3 quality_control.db "VACUUM;"
```

### Monthly Log Cleanup:
```bash
sudo journalctl --vacuum-time=30d
```

---

## 🚨 Important Notes

### ⚠️ **Before Every Update:**
1. **Always create backup** (script does this automatically)
2. **Test in development** first (your Windows machine)
3. **Update during low-usage hours** (early morning/late evening)
4. **Have rollback plan ready**

### ✅ **After Every Update:**
1. **Verify service is running** (`systemctl status`)
2. **Test critical functions** (login, add measurement)
3. **Check recent measurements** are displaying correctly
4. **Monitor logs** for any errors

### 🔒 **Security:**
- Backups contain sensitive data - protect them
- Keep GitHub repository private
- Use strong passwords for VPS access
- Regularly update VPS system packages

---

## 📞 Quick Reference Commands

| Task | Command |
|------|---------|
| Safe update | `./update_server.sh` |
| Manual backup | `./backup.sh` |
| Check service | `sudo systemctl status quality-control` |
| View logs | `sudo journalctl -u quality-control -f` |
| Restart service | `sudo systemctl restart quality-control` |
| Check database | `sqlite3 quality_control.db ".tables"` |

---

Your Quality Control Application can now be updated safely while preserving all your valuable measurement data! 🎯
