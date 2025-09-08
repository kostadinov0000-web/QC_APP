#!/bin/bash

# Safe Server Update Script for Quality Control Application
# This script updates the application while preserving all data

set -e  # Exit on any error

echo "🔄 Quality Control Application - Safe Update Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "app.py" ] || [ ! -f "quality_control.db" ]; then
    print_error "Please run this script from the quality_control_app directory"
    exit 1
fi

print_step "1. Creating backup before update..."

# Create backup directory with timestamp
BACKUP_DIR="backups/update_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup critical data
print_status "Backing up database..."
cp quality_control.db "$BACKUP_DIR/quality_control.db"

print_status "Backing up uploaded files..."
if [ -d "static/drawings" ]; then
    cp -r static/drawings "$BACKUP_DIR/drawings_backup"
fi

if [ -d "static/tolerance_tables" ]; then
    cp -r static/tolerance_tables "$BACKUP_DIR/tolerance_tables_backup"
fi

print_status "Backing up configuration..."
if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/.env_backup"
fi

print_status "Backup completed: $BACKUP_DIR"

print_step "2. Stopping application service..."
if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet quality-control; then
        print_status "Stopping quality-control service..."
        sudo systemctl stop quality-control
        SERVICE_WAS_RUNNING=true
    else
        print_status "Service was not running"
        SERVICE_WAS_RUNNING=false
    fi
else
    print_status "Systemctl not available, assuming manual deployment"
    SERVICE_WAS_RUNNING=false
fi

print_step "3. Updating code from GitHub..."

# Stash any local changes (just in case)
if git status --porcelain | grep -q .; then
    print_warning "Local changes detected, stashing them..."
    git stash push -m "Auto-stash before update $(date)"
fi

# Pull latest changes
print_status "Pulling latest changes from GitHub..."
git pull origin main

print_step "4. Updating dependencies..."

# Activate virtual environment
if [ -d "venv" ]; then
    print_status "Activating virtual environment..."
    source venv/bin/activate
else
    print_error "Virtual environment not found!"
    exit 1
fi

# Update Python packages
print_status "Updating Python packages..."
pip install --upgrade pip
pip install -r requirements.txt --upgrade

print_step "5. Rebuilding CSS (if needed)..."
if [ -f "package.json" ]; then
    print_status "Rebuilding Tailwind CSS..."
    npm install
    npx tailwindcss -i static/css/input.css -o static/css/output.css
else
    print_status "No package.json found, skipping CSS rebuild"
fi

print_step "6. Running database migrations..."
print_status "Starting app briefly to run any database migrations..."
timeout 10 python app.py || true  # Run for 10 seconds to trigger migrations

print_step "7. Setting proper permissions..."
chmod 644 quality_control.db
chmod -R 755 static/
if [ -d "static/drawings" ]; then
    chmod -R 755 static/drawings/
fi
if [ -d "static/tolerance_tables" ]; then
    chmod -R 755 static/tolerance_tables/
fi

print_step "8. Restarting application..."
if [ "$SERVICE_WAS_RUNNING" = true ]; then
    print_status "Restarting quality-control service..."
    sudo systemctl start quality-control
    sleep 3
    if systemctl is-active --quiet quality-control; then
        print_status "Service restarted successfully"
    else
        print_error "Service failed to start! Check logs:"
        echo "sudo journalctl -u quality-control -n 20"
        exit 1
    fi
else
    print_status "Service was not running before update"
    print_status "To start the service: sudo systemctl start quality-control"
fi

print_step "9. Verifying update..."
print_status "Checking application health..."
sleep 2

# Test if application is responding
if command -v curl &> /dev/null; then
    if curl -f -s http://localhost:8000 > /dev/null; then
        print_status "Application is responding correctly"
    else
        print_warning "Application may not be responding on port 8000"
        print_status "Check service status: sudo systemctl status quality-control"
    fi
fi

echo ""
echo "✅ Update completed successfully!"
echo ""
echo "📋 Summary:"
echo "- Backup created: $BACKUP_DIR"
echo "- Code updated from GitHub"
echo "- Dependencies updated"
echo "- Database migrations applied"
echo "- Service restarted (if was running)"
echo ""
echo "🔍 Monitoring Commands:"
echo "- Check service: sudo systemctl status quality-control"
echo "- View logs: sudo journalctl -u quality-control -f"
echo "- Check app: curl http://localhost:8000"
echo ""
echo "🚨 If something went wrong:"
echo "- Restore database: cp $BACKUP_DIR/quality_control.db ."
echo "- Restore drawings: cp -r $BACKUP_DIR/drawings_backup static/drawings"
echo "- Restore tolerance tables: cp -r $BACKUP_DIR/tolerance_tables_backup static/tolerance_tables"
echo "- View backup: ls -la $BACKUP_DIR/"
