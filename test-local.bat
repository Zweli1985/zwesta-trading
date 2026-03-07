@echo off
REM Zwesta Trading System - Local Testing Script
REM This script runs everything needed for local testing

setlocal enabledelayedexpansion

cls
echo.
echo ================================================================================
echo   Zwesta Trading System - LOCAL TESTING SUITE
echo ================================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8+ and add to PATH
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter and add to PATH
    pause
    exit /b 1
)

echo [OK] Python found: 
python --version

echo [OK] Flutter found:
flutter --version

echo.
echo ================================================================================
echo   STEP 1: Install Python Dependencies
echo ================================================================================
echo.

pip install -r trading_backend_requirements.txt --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Python dependencies
    pause
    exit /b 1
)
echo [OK] Python dependencies installed

echo.
echo ================================================================================
echo   STEP 2: Getting Flutter Dependencies
echo ================================================================================
echo.

call flutter pub get --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get Flutter dependencies
    pause
    exit /b 1
)
echo [OK] Flutter dependencies resolved

echo.
echo ================================================================================
echo   STEP 3: Starting Backend Server
echo ================================================================================
echo.
echo Backend will start on: http://localhost:9000
echo Logs will appear below... (Keep this window open)
echo.

REM Start backend in separate window
start "Zwesta Backend" cmd /k "python multi_broker_backend_updated.py"

REM Wait for backend to start
timeout /t 3 /nobreak

echo [OK] Backend server started

echo.
echo ================================================================================
echo   STEP 4: Starting Flutter Web App
echo ================================================================================
echo.
echo Flutter app will open in your default browser
echo.

REM Start Flutter app
call flutter run -d chrome --dart-define=ZWESTA_ENV=development

pause
