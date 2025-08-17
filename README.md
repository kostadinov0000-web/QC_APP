# Quality Control Application - Complete Documentation

A comprehensive Flask-based web application for managing quality control processes in manufacturing, featuring advanced molds management, measurement tracking, and detailed reporting with visual analytics.

## 🚀 Latest Features & Updates

### ✨ **Recent Enhancements**
- **🕒 Automatic Session Timeout** - 30-minute inactivity logout with warning notifications
- **📊 Visual Progress Bars** - Real-time mold usage visualization with percentage indicators
- **🔍 Advanced Filtering** - Sort and filter by cycles, thresholds, status, and more
- **📱 Enhanced Dashboard** - Improved molds dashboard with search and sorting capabilities
- **🔐 Enhanced Security** - Better session management and activity tracking

## 📋 Features Overview

### 🔐 **User Management & Security**
- **Role-based Access Control**: Admin and Inspector roles with different permissions
- **Secure Authentication**: SHA-256 password hashing with session management
- **Session Timeout**: Automatic logout after 30 minutes of inactivity
- **Activity Tracking**: Real-time session monitoring with warning notifications
- **Admin Controls**: Complete user account management with password management (Admin only)

### 📊 **Product & Molds Management**
- **Product Lifecycle**: Complete product management with drawings and specifications
- **Molds Monitoring**: Advanced mold tracking with cycle counts and maintenance scheduling
- **Visual Progress**: Progress bars and percentage indicators for mold usage
- **Maintenance Planning**: Automated maintenance alerts and scheduling
- **Drawing Integration**: PDF viewer with zoom controls for technical drawings

### 📏 **Measurement Recording & Tracking**
- **Digital Measurements**: Precise measurement recording with tolerance checking
- **Batch Processing**: Support for multiple measurements per session
- **Automatic Validation**: Real-time tolerance checking with visual indicators
- **Machine Tracking**: Record machine numbers and production counts
- **Inspector Attribution**: Track who recorded each measurement

### 📈 **Advanced Reporting & Analytics**
- **Excel Export**: Professional Excel reports with company branding
- **Date Range Filtering**: Flexible reporting periods
- **Product-Specific Reports**: Filter by individual products or view all
- **Visual Indicators**: Color-coded tolerance checking in reports
- **Comprehensive History**: Complete measurement and maintenance tracking

### 🎨 **Modern User Interface**
- **Responsive Design**: Mobile-friendly interface using Tailwind CSS
- **Interactive Dashboard**: Sortable columns, search functionality, and filters
- **Real-time Updates**: Live progress indicators and status updates
- **Toast Notifications**: User-friendly feedback for all actions
- **PDF Integration**: Built-in PDF viewer for technical drawings

## 💻 System Requirements

### Minimum Requirements
- **Python**: 3.8 or higher
- **RAM**: 2GB available memory
- **Storage**: 1GB free disk space
- **Browser**: Modern web browser (Chrome, Firefox, Safari, Edge)
- **Operating System**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+)

### Recommended for Production
- **Python**: 3.9 or higher
- **RAM**: 4GB or more
- **Storage**: 5GB free disk space
- **CPU**: Multi-core processor for better performance
- **Operating System**: Linux server (Ubuntu 20.04 LTS or CentOS 8+)

## 🛠️ Installation & Setup

### 1. **Quick Development Setup**

```bash
# 1. Get the project
git clone <repository-url>
cd quality_control_app

# 2. Create and activate virtual environment
python -m venv venv

# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# 3. Install all dependencies
pip install -r requirements.txt

# 4. Start the application
python app.py

# 5. Open browser to http://127.0.0.1:5000
# Login: admin / admin123
```

### 2. **Production Deployment Options**

#### **Option A: Standard Production Setup**

```bash
# Set secure environment variables
export SECRET_KEY="$(python -c 'import secrets; print(secrets.token_hex(32))')"
export ADMIN_PASSWORD="your-secure-admin-password"
export FLASK_DEBUG="False"
export FLASK_HOST="0.0.0.0"
export FLASK_PORT="8000"

# Install production server
pip install gunicorn

# Run with Gunicorn
gunicorn -c gunicorn.conf.py wsgi:app
```

#### **Option B: Docker Deployment**

```bash
# Build the container
docker build -t quality-control-app .

# Run with environment variables
docker run -d \
  -p 8000:8000 \
  -e SECRET_KEY="your-secret-key-here" \
  -e ADMIN_PASSWORD="your-admin-password" \
  -v ./data:/app/data \
  quality-control-app
```

#### **Option C: Docker Compose (Recommended)**

```bash
# Create .env file
echo "SECRET_KEY=your-secret-key-here" > .env
echo "ADMIN_PASSWORD=your-admin-password" >> .env

# Start the stack
docker-compose up -d

# Includes Nginx reverse proxy (optional)
docker-compose --profile nginx up -d
```

#### **Option D: Linux System Service**

```bash
# Use the automated deployment script
chmod +x deploy.sh
./deploy.sh

# Or manually create systemd service
sudo cp deployment/quality-control.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable quality-control
sudo systemctl start quality-control
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default | Production Required |
|----------|-------------|---------|-------------------|
| `SECRET_KEY` | Flask session encryption key | `dev-key` | ✅ **Yes** |
| `ADMIN_PASSWORD` | Default admin password | `admin123` | ⚠️ **Recommended** |
| `DATABASE_PATH` | SQLite database location | `quality_control.db` | No |
| `FLASK_DEBUG` | Enable debug mode | `False` | No |
| `FLASK_HOST` | Server bind address | `127.0.0.1` | No |
| `FLASK_PORT` | Server port number | `5000` | No |

### Security Configuration

```bash
# Generate secure secret key
python -c "import secrets; print(f'SECRET_KEY={secrets.token_hex(32)}')" >> .env

# Set secure admin password
echo "ADMIN_PASSWORD=YourSecurePassword123!" >> .env

# Production settings
echo "FLASK_DEBUG=False" >> .env
echo "FLASK_HOST=0.0.0.0" >> .env
echo "FLASK_PORT=8000" >> .env
```

## 📁 Project Structure

```
quality_control_app/
├── 📱 Application Core
│   ├── app.py                    # Main Flask application
│   ├── wsgi.py                  # WSGI entry point
│   ├── config.py                # Configuration management
│   └── requirements.txt         # Python dependencies
│
├── 🗄️ Database & Data
│   ├── quality_control.db       # SQLite database (auto-created)
│   └── backups/                 # Database backups
│
├── 🎨 Frontend & UI
│   ├── templates/               # Jinja2 HTML templates
│   │   ├── base.html           # Base template with navigation
│   │   ├── dashboard.html      # Main dashboard
│   │   ├── login.html          # Authentication page
│   │   ├── products.html       # Product management
│   │   ├── measurements.html   # Measurement recording
│   │   ├── reports.html        # Reporting interface
│   │   ├── molds_dashboard.html # Enhanced molds dashboard
│   │   └── users.html          # User management
│   └── static/                 # Static assets
│       ├── css/               # Compiled Tailwind CSS
│       ├── images/            # Application images & icons
│       ├── drawings/          # PDF technical drawings
│       └── pdfjs-4.7.76/     # PDF.js viewer library
│
├── 🚀 Deployment
│   ├── Dockerfile             # Container configuration
│   ├── docker-compose.yml     # Multi-container setup
│   ├── gunicorn.conf.py       # Production server config
│   ├── deploy.sh             # Automated deployment script
│   └── nginx.conf            # Reverse proxy configuration
│
└── 📚 Documentation
    ├── README.md             # This comprehensive guide
    └── README.markdown       # Quick start guide
```

## 🆕 Utilities & Deployment Guide

### reset_data.py
A helper script to **wipe all product, mold, and measurement data** and delete all uploaded drawing PDFs.

```bash
# ⚠️ This is destructive – make sure you have backups
python reset_data.py           # prompts for confirmation
python reset_data.py --yes     # non-interactive wipe
```

### DEPLOYMENT_GUIDE.md
For a step-by-step walkthrough on deploying the application to a Linux cloud VPS (including all PuTTY/SSH commands, firewall configuration, Nginx reverse proxy, and systemd setup) refer to the new **DEPLOYMENT_GUIDE.md** file in the project root.

## 👨‍💼 User Guide

### **Initial Setup Workflow**

1. **👤 First Login**
   - Navigate to the application URL
   - Login with: `admin` / `admin123` (or your custom password)
   - **⚠️ Important**: Change the default password immediately

2. **🏭 Add Your Products**
   - Go to **"Products"** page (Admin access required)
   - Click **"Add Product"** and enter:
     - Product name (e.g., "Plastic Housing E408")
     - Drawing number (e.g., "DWG-E408-001")
   - Upload PDF technical drawings to `static/drawings/` folder
   - Add product comments and specifications

3. **📐 Define Dimensions**
   - For each product, add critical dimensions:
     - Dimension name (e.g., "Overall Length")
     - Nominal value (target measurement)
     - Tolerance plus/minus values
   - Set realistic tolerances for quality control

4. **🔧 Set Up Molds**
   - Molds are automatically created for each product
   - Configure maintenance thresholds (default: 50,000 cycles)
   - Set up maintenance schedules and alerts

### **Daily Operations**

#### **📏 Recording Measurements**
1. Navigate to **"Measurements"** page
2. Select the product from the dropdown
3. Enter the machine number and production count
4. Input measured values for each dimension
5. Add shift information if applicable
6. Save measurements - tolerance checking is automatic

#### **🏭 Monitoring Molds**
1. Check **"Molds Dashboard"** for real-time status
2. Use **sorting** features:
   - Click column headers to sort (Cycles, Remaining Cycles, Threshold)
   - Use **status filter** to find molds needing attention
   - **Search** by mold name or product
3. Monitor **progress bars** for visual usage indicators:
   - 🟢 **Green**: < 70% usage (good condition)
   - 🟡 **Yellow**: 70-89% usage (maintenance due soon)
   - 🔴 **Red**: ≥ 90% usage (urgent maintenance needed)

#### **⚙️ Maintenance Management**
1. Schedule maintenance using **"Поддръжка"** buttons
2. Record rework activities with **"Ремонт"** buttons
3. Track maintenance history and costs
4. Set custom maintenance thresholds per mold

#### **📊 Generating Reports**
1. Go to **"Reports"** page
2. Set date range (DD-MM-YYYY format)
3. Optionally filter by specific product
4. **Export to Excel** for detailed analysis
5. Review **"Recent Measurements"** for quick overview

#### **🔑 Password Management (Admin Only)**
1. **Change Your Own Password**: Go to **"Users"** page → **"Смени собствена парола"** section
2. Enter new password (minimum 6 characters) and confirm
3. **Reset User Passwords**: Click **"Смени парола"** next to any user in the users list
4. Set new password and confirm for the selected user

### **User Roles & Permissions**

#### **👑 Admin Users**
- ✅ **Full System Access**: All features and pages
- ✅ **Product Management**: Add/edit/delete products and dimensions
- ✅ **User Management**: Create, delete user accounts, and reset passwords
- ✅ **File Management**: Upload drawings and modify configurations
- ✅ **Mold Configuration**: Set thresholds and maintenance schedules
- ✅ **Complete Reporting**: Access to all data and exports
- ✅ **Password Management**: Change own password and reset user passwords

#### **👨‍🔧 Inspector Users**
- ✅ **Measurement Recording**: Record and save measurements
- ✅ **Report Viewing**: Generate and view reports
- ✅ **Recent Data Access**: View recent measurements and trends
- ✅ **PDF Viewing**: Access technical drawings
- ❌ **No Product Editing**: Cannot modify products or dimensions
- ❌ **No User Management**: Cannot access user administration
- ❌ **No Configuration**: Cannot change system settings
- ❌ **No Password Management**: Cannot change passwords (admin only)

## 🔒 Security Features

### **Built-in Security**
- **🔐 Session Management**: 30-minute automatic timeout
- **⚠️ Activity Warnings**: 5-minute warning before logout
- **🛡️ Role-based Access**: Strict permission enforcement
- **🔒 Password Hashing**: SHA-256 secure password storage
- **📄 File Validation**: PDF-only upload with size limits
- **🚫 Input Sanitization**: Protection against malicious input

### **Production Security Checklist**

- [ ] **Change Default Credentials**: Update admin password
- [ ] **Set Strong Secret Key**: Use cryptographically secure key
- [ ] **Enable HTTPS**: Configure SSL/TLS certificates
- [ ] **Set Up Firewall**: Restrict network access appropriately
- [ ] **Regular Backups**: Implement automated backup strategy
- [ ] **Monitor Logs**: Set up log monitoring and alerts
- [ ] **Update Dependencies**: Keep all packages current
- [ ] **Database Security**: Set proper file permissions

## 🔧 Troubleshooting

### **Quick Fixes**

#### **🚫 Application Won't Start**
```bash
# Check Python version (should be 3.8+)
python --version

# Verify all dependencies are installed
pip install -r requirements.txt

# Check for port conflicts
netstat -tlnp | grep 5000  # Linux/Mac
netstat -an | findstr 5000  # Windows
```

#### **🎨 UI Issues (Missing Progress Bars, Styling)**
```bash
# Clear browser cache completely
# Try in incognito/private mode
# Check browser console for JavaScript errors
# Ensure static files are accessible
```

#### **💾 Database Problems**
```bash
# Check database permissions
ls -la quality_control.db  # Linux/Mac
dir quality_control.db     # Windows

# Reset database (⚠️ DELETES ALL DATA)
rm quality_control.db
python app.py
```

#### **🔐 Authentication Issues**
```bash
# Reset admin password via environment
export ADMIN_PASSWORD="newpassword123"
python app.py

# Check session configuration
# Clear browser cookies for the site
```

### **Performance Issues**

#### **Slow Loading Times**
1. **Check Database Size**: Large measurement history may slow queries
2. **Static Files**: Ensure drawings are reasonably sized (< 10MB each)
3. **Memory Usage**: Monitor Python process memory consumption
4. **Network**: Verify network latency to the server

#### **High Memory Usage**
```bash
# Monitor process
top -p $(pgrep -f "python.*app.py")  # Linux/Mac
tasklist /FI "IMAGENAME eq python.exe"  # Windows

# Restart application periodically in production
# Consider using Gunicorn with worker recycling
```

### **Advanced Troubleshooting**

#### **Enable Debug Logging**
```bash
export FLASK_DEBUG=True
python app.py
# Check console output for detailed error messages
```

#### **Database Inspection**
```bash
# Install SQLite browser or use command line
sqlite3 quality_control.db
.schema  # View table structure
.quit
```

#### **File Permission Issues (Linux/Mac)**
```bash
# Fix common permission problems
chmod 755 static/
chmod 755 static/drawings/
chmod 644 static/drawings/*.pdf
chmod 644 quality_control.db
```

## 🚀 Performance Optimization

### **Production Optimizations**

1. **🌐 Web Server Configuration**
   ```bash
   # Use Nginx for static files
   # Configure gzip compression
   # Set proper cache headers
   # Enable HTTP/2 if possible
   ```

2. **🗄️ Database Optimization**
   ```bash
   # Regular VACUUM for SQLite
   sqlite3 quality_control.db "VACUUM;"
   
   # For high traffic, consider PostgreSQL
   # Implement connection pooling
   ```

3. **📊 Application Performance**
   - Use production WSGI server (Gunicorn)
   - Enable worker process recycling
   - Implement Redis for session storage (optional)
   - Monitor with tools like Prometheus

### **Scaling Considerations**

- **📈 Horizontal Scaling**: Load balancer with multiple app instances
- **🗄️ Database Scaling**: External database with read replicas
- **☁️ Cloud Storage**: Use S3/equivalent for drawings and exports
- **📊 Monitoring**: Implement comprehensive application monitoring

## 📞 Support & Maintenance

### **Getting Help**

1. **📖 Check Documentation**: Review this README and comments in code
2. **🔍 Search Issues**: Look through troubleshooting section above
3. **📝 Check Logs**: Review application and web server logs
4. **🧪 Test Environment**: Try reproducing issues in development
5. **🔄 Restart Services**: Often resolves temporary issues

### **Maintenance Tasks**

#### **Daily**
- Monitor application logs for errors
- Check disk space and memory usage
- Verify backup completion

#### **Weekly**
- Review measurement data for anomalies
- Check mold maintenance alerts
- Update admin passwords if needed

#### **Monthly**
- Update dependencies: `pip install -r requirements.txt --upgrade`
- Review user accounts and permissions
- Clean up old measurement data if necessary
- Test backup restoration procedure

## 📄 License & Compliance

This is proprietary software. All rights reserved.

**⚠️ Important**: This application handles manufacturing quality data. Ensure compliance with:
- Your organization's data protection policies
- Industry-specific quality standards (ISO 9001, etc.)
- Local data privacy regulations
- Export control requirements if applicable

---

## 🎉 Ready to Deploy?

**Development**: `python app.py` → http://127.0.0.1:5000  
**Production**: `./deploy.sh` or use Docker Compose  
**Quick Start**: See `README.markdown` for 5-minute setup  

**Questions?** Check the troubleshooting section or review the application logs! 🚀 