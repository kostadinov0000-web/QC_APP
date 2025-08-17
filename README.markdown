# Quality Control Application - Quick Start Guide

A modern Flask-based web application for managing quality control of manufacturing products with comprehensive measurement tracking, molds management, and reporting capabilities.

## ✨ Key Features

- **🔐 Secure Authentication** - Role-based access (Admin/Inspector) with 30-minute session timeout
- **🔑 Password Management** - Admin-controlled password management and reset functionality
- **📊 Product & Molds Management** - Complete product lifecycle and mold monitoring
- **📏 Measurement Recording** - Digital measurement tracking with tolerance checking
- **📈 Advanced Reporting** - Excel exports with visual progress indicators
- **🎨 Modern Interface** - Responsive design with sorting, filtering, and search

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- **Python 3.8+** ([Download here](https://www.python.org/))
- **Git** (optional, for cloning)

### Installation

1. **Get the Project**
   ```bash
   # Download and extract, or clone:
   git clone <repository-url>
   cd quality_control_app
   ```

2. **Set Up Environment**
   ```bash
   # Create virtual environment
   python -m venv venv
   
   # Activate it
   # Windows:
   venv\Scripts\activate
   # Mac/Linux:
   source venv/bin/activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the Application**
   ```bash
   python app.py
   ```

5. **Open Your Browser**
   - Go to: http://127.0.0.1:5000
   - Login: `admin` / `admin123`

## 🎯 First Steps

1. **Add Your First Product**
   - Go to "Products" (Admin only)
   - Add product name and drawing number
   - Upload PDF drawings if available
   - Define dimensions with tolerances

2. **Record Measurements**
   - Go to "Measurements"
   - Select your product
   - Enter measurement values
   - Save results

3. **View Progress**
   - Check "Molds Dashboard" for visual progress
   - Use filters and sorting to find specific data
   - Generate reports with date ranges

## 📂 Project Structure

```
quality_control_app/
├── app.py                    # Main application
├── requirements.txt          # Dependencies
├── quality_control.db       # Database (auto-created)
├── templates/               # HTML pages
├── static/                  # CSS, JS, images
└── static/drawings/         # PDF drawings folder
```

## 🔧 Configuration

### Environment Variables (Optional)
```bash
# For production, set these:
export SECRET_KEY="your-secret-key-here"
export ADMIN_PASSWORD="your-secure-password"
export FLASK_HOST="0.0.0.0"
export FLASK_PORT="8000"
```

### For Production
```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn -c gunicorn.conf.py wsgi:app
```

## 🛡️ Security Features

- **Session Timeout**: Automatic logout after 30 minutes of inactivity
- **Password Management**: Admin-controlled password management with minimum 6-character requirement
- **Role-Based Access**: Admin vs Inspector permissions
- **Secure File Uploads**: PDF validation and secure storage
- **Input Validation**: Comprehensive form validation

## 📊 User Roles

### Admin Users
- ✅ Manage products and dimensions
- ✅ Upload drawings and modify data
- ✅ Manage user accounts and passwords
- ✅ Access all features
- ✅ Change own and user passwords

### Inspector Users
- ✅ Record measurements
- ✅ View reports and data
- ❌ Cannot modify products
- ❌ Cannot access user management
- ❌ Cannot change passwords

## 🔍 Troubleshooting

### Common Issues

**App won't start?**
```bash
# Check Python version
python --version  # Should be 3.8+

# Reinstall dependencies
pip install -r requirements.txt
```

**Can't see progress bars?**
- Clear browser cache
- Check that JavaScript is enabled
- Try refreshing the page

**Database issues?**
```bash
# Reset database (⚠️ This deletes all data)
rm quality_control.db
python app.py
```

**Port already in use?**
```bash
# Windows: Kill process on port 5000
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F

# Mac/Linux: Kill process on port 5000
lsof -ti:5000 | xargs kill -9
```

## 📚 Learn More

- Check the comprehensive **README.md** for detailed deployment options
- Review **templates/** folder for UI customization
- See **gunicorn.conf.py** for production settings

## 🆘 Support

1. Check the troubleshooting section above
2. Review application console output
3. Ensure all files are in the correct directories
4. Verify Python and dependency versions

---

**Ready to get started?** Run `python app.py` and visit http://127.0.0.1:5000! 🎉