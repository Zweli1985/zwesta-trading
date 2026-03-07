@echo off
REM Zwesta Trading System - Windows VPS Deployment Script
REM Usage: deploy-to-vps.bat [VPS_IP] [USERNAME]
REM Example: deploy-to-vps.bat 38.247.146.198 root

setlocal enabledelayedexpansion

if "%1"=="" (
    echo Usage: deploy-to-vps.bat [VPS_IP] [USERNAME]
    echo Example: deploy-to-vps.bat 38.247.146.198 root
    exit /b 1
)

set VPS_IP=%1
set VPS_USER=%2
if "%VPS_USER%"=="" set VPS_USER=root

echo.
echo ================================================
echo Zwesta Trading System - Windows VPS Deployment
echo ================================================
echo VPS: !VPS_USER!@!VPS_IP!
echo.

REM Check if SSH is available
ssh -V >nul 2>&1
if errorlevel 1 (
    echo ERROR: SSH is not available. Please install OpenSSH or Git Bash.
    exit /b 1
)

REM Check if build directory exists
if not exist "build\web" (
    echo ERROR: build\web directory not found. Run 'flutter build web' first.
    exit /b 1
)

echo [1/3] Copying build files to VPS...
scp -r build\web\* !VPS_USER!@!VPS_IP!:/var/www/zwesta-trading\ || exit /b 1
echo.

echo [2/3] Fixing permissions on VPS...
ssh !VPS_USER!@!VPS_IP! "sudo chown -R www-data:www-data /var/www/zwesta-trading && sudo chmod -R 755 /var/www/zwesta-trading" || exit /b 1
echo.

echo [3/3] Reloading Nginx...
ssh !VPS_USER!@!VPS_IP! "sudo systemctl reload nginx"
echo.

echo ================================================
echo Deployment Complete!
echo ================================================
echo.
echo Your app is now available at:
echo   http://!VPS_IP!
echo.
echo To verify:
echo   1. Open http://!VPS_IP! in your browser
echo   2. You should see "Loading Zwesta Trading System"
echo   3. Wait for the dashboard to load
echo.
if errorlevel 1 (
    echo.
    echo WARNING: Nginx reload had issues. Check VPS logs:
    echo   ssh !VPS_USER!@!VPS_IP! "sudo tail -50 /var/log/nginx/zwesta-error.log"
)

endlocal
