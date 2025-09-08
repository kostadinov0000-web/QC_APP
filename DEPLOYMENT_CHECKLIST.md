# 🚀 Deployment Checklist - Quality Control App

## Step-by-Step Deployment Process

### 📝 **Pre-Deployment (Windows Development Machine)**

- [ ] **Test all new features locally**
- [ ] **Verify no errors in browser console**
- [ ] **Check that measurements save correctly**
- [ ] **Test mobile navigation works**
- [ ] **Verify search functionality works**
- [ ] **Test tolerance tables upload/view**

### 📤 **Push to GitHub (Windows)**

```bash
# 1. Stage all changes
git add .

# 2. Commit with descriptive message
git commit -m "Major update: mobile nav, search, timezone fix, tolerance tables, robust measurements"

# 3. Push to GitHub
git push origin main
```

### 🖥️ **Deploy to VPS Server (Linux)**

```bash
# 1. SSH into your VPS
ssh your-username@your-server-ip

# 2. Navigate to app directory
cd ~/quality_control_app

# 3. Run safe update script
./update_server.sh
```

### ✅ **Post-Deployment Verification**

- [ ] **Service is running**: `sudo systemctl status quality-control`
- [ ] **App responds**: Visit your website URL
- [ ] **Login works**: Test admin login
- [ ] **Database intact**: Check measurements count
- [ ] **Files preserved**: Verify drawings and tolerance tables
- [ ] **New features work**: Test mobile nav, search, timezone

### 🆘 **If Something Goes Wrong**

The update script creates automatic backups. To restore:

```bash
# Find your backup
ls -la backups/

# Restore database (replace YYYYMMDD_HHMMSS with your backup timestamp)
cp backups/update_YYYYMMDD_HHMMSS/quality_control.db .

# Restore files
cp -r backups/update_YYYYMMDD_HHMMSS/drawings_backup static/drawings
cp -r backups/update_YYYYMMDD_HHMMSS/tolerance_tables_backup static/tolerance_tables

# Restart service
sudo systemctl restart quality-control
```

---

## 🔍 Quick Health Check Commands

### **Service Status:**
```bash
sudo systemctl status quality-control
```

### **View Logs:**
```bash
sudo journalctl -u quality-control -f
```

### **Test Application:**
```bash
curl -I http://localhost:8000
```

### **Check Database:**
```bash
sqlite3 quality_control.db "SELECT COUNT(*) as measurements FROM measurements;"
sqlite3 quality_control.db "SELECT COUNT(*) as products FROM products;"
sqlite3 quality_control.db "SELECT COUNT(*) as molds FROM molds;"
```

### **Check Files:**
```bash
ls -la static/drawings/
ls -la static/tolerance_tables/
```

---

## 🎯 Key Features in This Update

### ✅ **What You're Deploying:**

1. **📱 Mobile Navigation**: Responsive dropdown menu for phones
2. **🔍 Search Functionality**: Search products by name/drawing/comments
3. **🕐 Bulgarian Timezone**: All timestamps now show Bulgarian time
4. **📋 Tolerance Tables**: New page for uploading/managing tolerance PDFs
5. **🛡️ Robust Measurements**: Offline storage and duplicate prevention
6. **🚫 Duplicate Prevention**: Case-insensitive product duplicate checking
7. **📄 Pagination**: 50 items per page for better performance
8. **🎨 UI Improvements**: Better error messages and user feedback

### 🗄️ **What Gets Preserved:**
- All measurement data
- All products and molds
- All uploaded drawings
- User accounts and passwords
- All configuration settings

---

**Ready to deploy? Follow the checklist above!** 🚀
