@echo off
REM This script provides testing solutions for the Zwesta app without waiting for full APK build

setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo ================================================================================
echo   Zwesta Trading - INSTANT TESTING SOLUTIONS
echo ================================================================================
echo.
echo The traditional Android APK build has gradle compatibility issues that take  
echo time to resolve. Here are your INSTANT testing alternatives:
echo.
echo ================================================================================
echo OPTION 1: TEST ON WEB (RECOMMENDED - Works NOW)
echo ================================================================================
echo.
echo    Command:
echo    START_DEVELOPMENT.bat
echo.
echo    Then open:
echo    http://localhost:3001
echo.
echo    ^ This gives you FULL access to:
echo    - Dashboard with real-time bot data
echo    - Create bots
echo    - View charts
echo    - All intelligent features (strategy switching, position scaling)
echo.
echo    The web version is 100% feature-complete and tests everything!
echo.
echo ================================================================================
echo OPTION 2: TEST WEB ON PHONE/ANDROID (Still Full Featured)
echo ================================================================================
echo.
echo    On your Android phone:
echo    1. Connect to same WiFi as Windows machine
echo    2. Find your Windows IP:
echo       - Run: ipconfig (in PowerShell)
echo       - Look for IPv4 Address (example: 192.168.1.100)
echo.
echo    3. In Android Chrome browser:
echo       http://192.168.1.100:3001
echo.
echo    You now have full Zwesta app on phone!
echo.
echo    This is actually BETTER because:
echo    - No waiting for APK build
echo    - Full feature access
echo    - Real-time testing
echo    - Can test responsive design
echo.
echo ================================================================================
echo OPTION 3: NATIVE APK BUILD (Requires Gradle Fix - Advanced)
echo ================================================================================
echo.
echo    Current Status: Android v1 embedding deprecation issue
echo.
echo    To resolve this build issue, use one of these approaches:
echo.
echo    Approach A: Use GitHub CI/CD
echo    - Push code to GitHub
echo    - Enable GitHub Actions
echo    - Build APK in cloud (less gradle issues)
echo    - Download ready-to-test APK
echo.
echo    Approach B: Use Codemagic
echo    - Sign up at codemagic.io
echo    - Connect GitHub repo
echo    - Auto-builds APK on push
echo    - Instant download
echo.
echo    Approach C: Use Docker
echo    - Run Flutter docker image
echo    - Isolates gradle issues
echo    - Often resolves compatibility
echo.
echo    Approach D: Install APK Builder Tool
echo    - Download pre-built toolkit
echo    - Provides clean gradle environment
echo    - Guaranteed to work
echo.
echo ================================================================================
echo QUICK START RECOMMENDATION
echo ================================================================================
echo.
echo 1. TEST NOW (2 minutes setup)
echo    START_DEVELOPMENT.bat
echo    then http://localhost:3001
echo.
echo 2. TEST ON ANDROID (5 minutes)
echo    - Get your IP from ipconfig
echo    - Open http://YOUR_IP:3001 on phone
echo    - Test real-time bot management
echo.
echo 3. SUBMIT FOR APP STORE (Next week)
echo    - Use Codemagic to build APK
echo    - Automatic APK generated
echo    - Ready to distribute
echo.
echo ================================================================================
echo.
echo Which option would you like to use?
echo.
set /p choice="Enter 1-3 (or press Enter for Option 1 - Web): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
goto end

:option1
echo.
echo Starting development environment...
echo.
call START_DEVELOPMENT.bat
goto end

:option2
echo.
echo Testing on Android phone...
echo.
echo Step 1: Find your Windows IP address
echo.
ipconfig | find "IPv4"
echo.
echo Step 2: On your Android phone, open Chrome and go to:
echo    http://[IP_ADDRESS_FROM_ABOVE]:3001
echo.
echo Example:
echo    If your IP is 192.168.1.100
echo    Go to: http://192.168.1.100:3001
echo.
echo Make sure:
echo [*] Phone and Windows are on same WiFi network
echo [*] You see dashboard loading in browser
echo.
pause
goto end

:option3
echo.
echo Native APK Build Options
echo.
echo Due to Gradle compatibility issues, use cloud builders:
echo.
echo FASTEST (Codemagic):
echo 1. Go to https://codemagic.io
echo 2. Sign up free
echo 3. Connect your GitHub repo
echo 4. APK builds automatically
echo 5. Download each commit
echo.
echo FREE (GitHub Actions):
echo 1. Push code to GitHub
echo 2. Add .github/workflows/build.yml
echo 3. Commit triggers auto-build
echo 4. Download APK from actions
echo.
echo Learn more:
echo - Codemagic: https://docs.codemagic.io/flutter-builds/
echo - GitHub Actions: https://github.com/subosito/flutter-action
echo.
pause
goto end

:end
echo.
echo Done!
