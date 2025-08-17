#!/bin/bash

# Quality Control Application Deployment Script
# This script automates the deployment process for production

set -e  # Exit on any error

echo "🚀 Quality Control Application Deployment Script"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check Python version
print_status "Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
required_version="3.8.0"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" = "$required_version" ]; then
    print_status "Python version $python_version is compatible"
else
    print_error "Python 3.8 or higher is required. Found: $python_version"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
else
    print_status "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
print_status "Installing dependencies..."
pip install -r requirements.txt

# Set up environment variables
print_status "Setting up environment variables..."

# Generate a secure secret key if not provided
if [ -z "$SECRET_KEY" ]; then
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    print_warning "Generated SECRET_KEY: $SECRET_KEY"
    print_warning "Please save this key securely and set it as an environment variable"
fi

# Set default admin password if not provided
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="admin123"
    print_warning "Using default admin password: $ADMIN_PASSWORD"
    print_warning "Please change this password after first login"
fi

# Create .env file
cat > .env << EOF
SECRET_KEY=$SECRET_KEY
ADMIN_PASSWORD=$ADMIN_PASSWORD
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=8000
DATABASE_PATH=quality_control.db
EOF

print_status "Environment variables saved to .env file"

# Initialize database
print_status "Initializing database..."
python3 app.py &
APP_PID=$!
sleep 3
kill $APP_PID 2>/dev/null || true

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p static/drawings
mkdir -p logs
mkdir -p backups

# Set proper permissions
print_status "Setting file permissions..."
chmod 755 static/
chmod 755 static/drawings/
chmod 644 quality_control.db 2>/dev/null || true

# Create systemd service file (Linux only)
if command -v systemctl &> /dev/null; then
    print_status "Creating systemd service file..."
    
    # Get current directory
    CURRENT_DIR=$(pwd)
    VENV_PATH="$CURRENT_DIR/venv"
    
    sudo tee /etc/systemd/system/quality-control.service > /dev/null << EOF
[Unit]
Description=Quality Control Application
After=network.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$CURRENT_DIR
EnvironmentFile=$CURRENT_DIR/.env
ExecStart=$VENV_PATH/bin/gunicorn -c gunicorn.conf.py wsgi:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    print_status "Systemd service file created"
    print_status "To enable the service, run:"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl enable quality-control"
    echo "  sudo systemctl start quality-control"
fi

# Create backup script
print_status "Creating backup script..."
cat > backup.sh << 'EOF'
#!/bin/bash
# Backup script for Quality Control Application

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_FILE="quality_control.db"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

if [ -f "$DB_FILE" ]; then
    cp "$DB_FILE" "$BACKUP_DIR/${DB_FILE}_${DATE}"
    echo "Database backed up to: $BACKUP_DIR/${DB_FILE}_${DATE}"
    
    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/${DB_FILE}_* | tail -n +11 | xargs rm -f 2>/dev/null || true
else
    echo "Database file not found: $DB_FILE"
fi
EOF

chmod +x backup.sh

# Create startup script
print_status "Creating startup script..."
cat > start.sh << 'EOF'
#!/bin/bash
# Startup script for Quality Control Application

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Activate virtual environment
source venv/bin/activate

# Start the application
gunicorn -c gunicorn.conf.py wsgi:app
EOF

chmod +x start.sh

print_status "Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Review the .env file and update SECRET_KEY and ADMIN_PASSWORD"
echo "2. Add PDF drawings to static/drawings/ folder"
echo "3. Start the application: ./start.sh"
echo "4. Access the application at: http://localhost:8000"
echo "5. Login with admin/admin123 (or your custom password)"
echo ""
echo "🔧 Management Commands:"
echo "- Start application: ./start.sh"
echo "- Create backup: ./backup.sh"
echo "- View logs: tail -f logs/quality_control.log"
echo ""
echo "📚 For more information, see README.md" 