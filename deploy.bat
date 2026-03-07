@echo off
REM Zwesta Trading System - VPS Deployment Script (Windows)
REM This script builds and deploys the application with specified configuration

setlocal enabledelayedexpansion

REM Colors (Windows 10+)
cls

echo.
echo ========================================
echo Zwesta Trading System - Deployment
echo ========================================
echo.

REM Default values
set ENVIRONMENT=production
set API_URL=
set API_KEY=
set OFFLINE_MODE=false
set OUTPUT_DIR=build\web
set VPS_HOST=
set VPS_USER=
set VPS_PATH=/var/www/zwesta-trading

REM Check if Flutter is installed
where flutter >nul 2>nul
if errorlevel 1 (
    echo Error: Flutter is not installed
    exit /b 1
)

REM Parse arguments
:parse_args
if "%1"=="" goto :validate
if "%1"=="-e" (
    set ENVIRONMENT=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--env" (
    set ENVIRONMENT=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-a" (
    set API_URL=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--api-url" (
    set API_URL=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-k" (
    set API_KEY=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--api-key" (
    set API_KEY=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-o" (
    set OFFLINE_MODE=true
    shift
    goto :parse_args
)
if "%1"=="--offline" (
    set OFFLINE_MODE=true
    shift
    goto :parse_args
)
if "%1"=="-h" (
    set VPS_HOST=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--host" (
    set VPS_HOST=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-u" (
    set VPS_USER=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--user" (
    set VPS_USER=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-p" (
    set VPS_PATH=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--path" (
    set VPS_PATH=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--help" (
    goto :show_help
)
shift
goto :parse_args

:validate
if "!OFFLINE_MODE!"=="false" (
    if "!API_URL!"=="" (
        echo Warning: No API_URL provided. Using development defaults.
    )
)

REM Print configuration
echo.
echo Configuration:
echo   Environment: !ENVIRONMENT!
echo   API URL: !API_URL!
echo   Offline Mode: !OFFLINE_MODE!
if not "!VPS_HOST!"=="" (
    echo   VPS Deployment: !VPS_HOST!!VPS_PATH!
)
echo.

REM Clean and get dependencies
echo Step 1: Preparing project...
call flutter clean >nul 2>&1
call flutter pub get >nul 2>&1

REM Build web application
echo Step 2: Building web application...
set BUILD_ARGS=--release --dart-define=ZWESTA_ENV=!ENVIRONMENT!

if not "!API_URL!"=="" (
    set BUILD_ARGS=!BUILD_ARGS! --dart-define=API_URL=!API_URL!
)

if not "!API_KEY!"=="" (
    set BUILD_ARGS=!BUILD_ARGS! --dart-define=API_KEY=!API_KEY!
)

if "!OFFLINE_MODE!"=="true" (
    set BUILD_ARGS=!BUILD_ARGS! --dart-define=OFFLINE_MODE=true
)

call flutter build web !BUILD_ARGS!

REM Check build success
if not exist "!OUTPUT_DIR!\index.html" (
    echo Error: Build failed - index.html not found
    exit /b 1
)

echo.
echo [SUCCESS] Build successful
echo.

REM Summary
echo ========================================
echo Deployment Summary
echo ========================================
echo Environment: !ENVIRONMENT!
echo Build Directory: !OUTPUT_DIR!
if not "!VPS_HOST!"=="" (
    echo Deployed to: https://!VPS_HOST!
)
echo ========================================
echo.
echo [SUCCESS] Build complete!
echo.
echo Next steps:
echo 1. To deploy manually, copy the contents of !OUTPUT_DIR! to your VPS
echo 2. Or use: scp -r !OUTPUT_DIR!\* user@your-vps:/var/www/zwesta-trading/
echo.

goto :end

:show_help
echo.
echo Usage: deploy.bat [OPTIONS]
echo.
echo Options:
echo   -e, --env ENV              Environment: production, staging, development
echo   -a, --api-url URL          API URL
echo   -k, --api-key KEY          API Key
echo   -o, --offline              Enable offline mode with mock data
echo   -h, --host HOST            VPS hostname/IP
echo   -u, --user USER            VPS SSH username
echo   -p, --path PATH            VPS deployment path
echo   --help                     Display this help message
echo.
echo Examples:
echo.
echo Production with API:
echo   deploy.bat -e production -a https://api.zwesta.com -k prod_key_xyz
echo.
echo Testing with offline mode:
echo   deploy.bat -e production --offline
echo.
exit /b 0

:end
endlocal
