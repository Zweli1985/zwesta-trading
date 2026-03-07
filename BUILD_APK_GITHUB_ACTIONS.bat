@echo off
REM Zwesta Trading - Android APK Builder Helper
REM Uses GitHub Actions to build APK automatically

setlocal enabledelayedexpansion

cd /d "%~dp0"

cls
echo.
echo ================================================================================
echo   Zwesta Trading - Android APK Builder
echo ================================================================================
echo.
echo This script will help you build an Android APK using GitHub Actions
echo.
echo Why GitHub Actions?
echo   ✓ Free forever
echo   ✓ No local Gradle issues
echo   ✓ Auto-builds when you push code
echo   ✓ APK ready in 10-15 minutes
echo.
echo ================================================================================
echo.

REM Check if git is installed
git --version >NUL 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git not installed
    echo.
    echo Download: https://git-scm.com/download/win
    echo Then restart this script
    echo.
    pause
    exit /b 1
)

echo [Step 1] Check Git Status
echo.

git status >NUL 2>&1
if %errorlevel% neq 0 (
    echo Git not initialized. Initializing...
    git init
    echo.
)

echo [Step 2] Prepare Code
echo.

git add .
echo Files staged for commit
echo.

git commit -m "Zwesta Trading System - Ready for APK build" -q
if %errorlevel% equ 0 (
    echo Code committed
) else (
    echo (No changes to commit - that's OK)
)

echo.
echo ================================================================================
echo [Step 3] Create GitHub Repository
echo ================================================================================
echo.
echo Next: Go to https://github.com/new to create a new repository
echo.
echo Repository settings:
echo   Name: zwesta-trading
echo   Description: Intelligent Trading System with Real-time Dashboard
echo   Visibility: Public (required for GitHub Actions)
echo.
echo After creating repo, copy the commands shown and run in terminal:
echo   git remote add origin https://github.com/YOUR_USERNAME/zwesta-trading.git
echo   git branch -M main
echo   git push -u origin main
echo.
echo.
set /p continue="Press Enter to open GitHub, or 'q' to quit: "
if /i "%continue%"=="q" goto end

start https://github.com/new

echo.
echo Opening https://github.com/new in your browser...
echo.
timeout /t 3 /nobreak

cls

echo ================================================================================
echo AFTER Creating Repository on GitHub
echo ================================================================================
echo.
echo Copy these commands and run in PowerShell here:
echo.
echo ---
echo git remote add origin https://github.com/YOUR_USERNAME/zwesta-trading.git
echo git branch -M main
echo git push -u origin main
echo ---
echo.
echo (Replace YOUR_USERNAME with your GitHub username)
echo.
set /p remote_added="Paste the commands above and press Enter when done: "

REM Try to push
echo.
echo Pushing code to GitHub...
git push -u origin main 2>NUL
if %errorlevel% equ 0 (
    echo.
    echo ✓ Code pushed successfully!
    echo.
) else (
    echo.
    echo Check GitHub error above. May need to authenticate.
    echo.
    pause
    goto end
)

echo ================================================================================
echo [Step 4] GitHub Actions Building Your APK
echo ================================================================================
echo.
echo Your APK is now building automatically!
echo.
echo Go to: https://github.com/YOUR_USERNAME/zwesta-trading/actions
echo.
echo What to do:
echo   1. Open link above
echo   2. Click on the build (top of list)
echo   3. Wait for green checkmark ✓
echo   4. Takes 8-12 minutes
echo   5. Click "app-release.apk" artifact to download
echo.
echo Your APK will be ready in about 10-15 minutes
echo.
echo ================================================================================
echo.

set /p open_actions="Open Actions page now? (y/n): "
if /i "%open_actions%"=="y" (
    start https://github.com/YOUR_USERNAME/zwesta-trading/actions
)

echo.
echo ================================================================================
echo AUTOMATIC UPDATES
echo ================================================================================
echo.
echo From now on, every time you change code:
echo.
echo   1. Make changes in VS Code
echo   2. In PowerShell:
echo      git add .
echo      git commit -m "Description of changes"
echo      git push
echo.
echo   3. GitHub Actions auto-builds APK
echo   4. New APK ready in 10-15 minutes
echo   5. Download from Actions tab
echo.
echo ================================================================================
echo.

goto end

:end
echo.
echo Done!
echo.
pause
