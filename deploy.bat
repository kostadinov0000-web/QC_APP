@echo off
REM Quality Control Application Deployment Script for Windows
REM This script automates the deployment process for production

echo 🚀 Quality Control Application Deployment Script
echo ================================================

REM Check Python version
echo [INFO] Checking Python version...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo [INFO] Creating virtual environment...
    python -m venv venv
) else (
    echo [INFO] Virtual environment already exists
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

REM Install dependencies
echo [INFO] Installing dependencies...
pip install -r requirements.txt

REM Set up environment variables
echo [INFO] Setting up environment variables...

REM Generate a secure secret key if not provided
if "%SECRET_KEY%"=="" (
    for /f "delims=" %%i in ('python -c "import secrets; print(secrets.token_hex(32))"') do set SECRET_KEY=%%i
    echo [WARNING] Generated SECRET_KEY: %SECRET_KEY%
    echo [WARNING] Please save this key securely and set it as an environment variable
)

REM Set default admin password if not provided
if "%ADMIN_PASSWORD%"=="" (
    set ADMIN_PASSWORD=admin123
    echo [WARNING] Using default admin password: %ADMIN_PASSWORD%
    echo [WARNING] Please change this password after first login
)

REM Create .env file
echo SECRET_KEY=%SECRET_KEY%> .env
echo ADMIN_PASSWORD=%ADMIN_PASSWORD%>> .env
echo FLASK_DEBUG=False>> .env
echo FLASK_HOST=0.0.0.0>> .env
echo FLASK_PORT=8000>> .env
echo DATABASE_PATH=quality_control.db>> .env

echo [INFO] Environment variables saved to .env file

REM Initialize database
echo [INFO] Initializing database...
start /B python app.py
timeout /t 3 /nobreak >nul
taskkill /f /im python.exe >nul 2>&1

REM Create necessary directories
echo [INFO] Creating necessary directories...
if not exist "static\drawings" mkdir static\drawings
if not exist "logs" mkdir logs
if not exist "backups" mkdir backups

REM Create startup script
echo [INFO] Creating startup script...
echo @echo off> start.bat
echo REM Startup script for Quality Control Application>> start.bat
echo.>> start.bat
echo REM Load environment variables>> start.bat
echo if exist .env ^(>> start.bat
echo     for /f "tokens=1,2 delims==" %%a in ^(.env^) do set %%a=%%b>> start.bat
echo ^)>> start.bat
echo.>> start.bat
echo REM Activate virtual environment>> start.bat
echo call venv\Scripts\activate.bat>> start.bat
echo.>> start.bat
echo REM Start the application>> start.bat
echo gunicorn -c gunicorn.conf.py wsgi:app>> start.bat

REM Create backup script
echo [INFO] Creating backup script...
echo @echo off> backup.bat
echo REM Backup script for Quality Control Application>> backup.bat
echo.>> backup.bat
echo set BACKUP_DIR=backups>> backup.bat
echo for /f "tokens=2 delims==" %%a in ^('wmic OS Get localdatetime /value'^) do set "dt=%%a">> backup.bat
echo set "YY=%dt:~2,2% & set "YYYY=%dt:~0,4% & set "MM=%dt:~4,2% & set "DD=%dt:~6,2%">> backup.bat
echo set "HH=%dt:~8,2% & set "Min=%dt:~10,2% & set "Sec=%dt:~12,2%">> backup.bat
echo set "datestamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%">> backup.bat
echo set DB_FILE=quality_control.db>> backup.bat
echo.>> backup.bat
echo if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%">> backup.bat
echo.>> backup.bat
echo if exist "%DB_FILE%" ^(>> backup.bat
echo     copy "%DB_FILE%" "%BACKUP_DIR%\%DB_FILE%_%datestamp%">> backup.bat
echo     echo Database backed up to: %BACKUP_DIR%\%DB_FILE%_%datestamp%>> backup.bat
echo ^) else ^(>> backup.bat
echo     echo Database file not found: %DB_FILE%>> backup.bat
echo ^)>> backup.bat

echo [INFO] Deployment completed successfully!
echo.
echo 📋 Next Steps:
echo 1. Review the .env file and update SECRET_KEY and ADMIN_PASSWORD
echo 2. Add PDF drawings to static\drawings\ folder
echo 3. Start the application: start.bat
echo 4. Access the application at: http://localhost:8000
echo 5. Login with admin/admin123 (or your custom password)
echo.
echo 🔧 Management Commands:
echo - Start application: start.bat
echo - Create backup: backup.bat
echo.
echo 📚 For more information, see README.md
pause 