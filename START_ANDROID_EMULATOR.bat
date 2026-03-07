@echo off
REM ============================================================================
REM Zwesta Trading - Android Emulator & Mobile App Launcher
REM ============================================================================

cd /d "%~dp0"

echo.
echo ================================================================================
echo   Zwesta Trading - ANDROID MOBILE APP (Emulator)
echo ================================================================================
echo.

REM Check if we can find the Android SDK
where emulator >NUL 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Android emulator not found in PATH
    echo.
    echo To fix:
    echo   1. Install Android Studio: https://developer.android.com/studio
    echo   2. Add Android SDK tools to PATH:
    echo      Control Panel ^> System ^> Environment Variables
    echo      Add: C:\Users\YOUR_USERNAME\AppData\Local\Android\Sdk\emulator
    echo   3. Restart this script
    echo.
    pause
    exit /b 1
)

echo Checking available Android emulators...
echo.

REM List available emulators
emulator -list-avds

echo.
echo ================================================================================
echo ANDROID EMULATOR CONFIGURATION
echo ================================================================================
echo.
echo Available options:
echo   1. Start default emulator (Pixel_6_API_33)
echo   2. List installed emulators
echo   3. Create new emulator
echo   4. Custom emulator name
echo   5. Run app build test
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto start_default
if "%choice%"=="2" goto list_emulator
if "%choice%"=="3" goto create_emulator
if "%choice%"=="4" goto custom_emulator
if "%choice%"=="5" goto test_build
goto end

:start_default
echo.
echo Starting Pixel_6_API_33 emulator...
start "" "emulator" -avd Pixel_6_API_33 -no-snapshot-load
echo.
echo Waiting 20 seconds for emulator to boot...
timeout /t 20 /nobreak
goto run_app

:list_emulator
echo.
emulator -list-avds
echo.
pause
goto end

:create_emulator
echo.
echo To create an Android emulator:
echo   1. Open Android Studio
echo   2. Tools ^> Device Manager
echo   3. Create Virtual Device
echo   4. Select: Pixel 6, API 33, Android 13.0
echo   5. Click Create
echo.
pause
goto end

:custom_emulator
echo.
set /p emulator_name="Enter emulator name (from list above): "
echo.
echo Starting %emulator_name% emulator...
start "" "emulator" -avd %emulator_name% -no-snapshot-load
echo.
echo Waiting 20 seconds for emulator to boot...
timeout /t 20 /nobreak
goto run_app

:run_app
echo.
echo ================================================================================
echo APPLICATION SETUP
echo ================================================================================
echo.

REM Verify backend is running
echo Checking backend connection...
powershell -Command "^
try { ^
  $result = Invoke-RestMethod http://localhost:9000/api/bot/status -ErrorAction Stop -TimeoutSec 2; ^
  Write-Host '✓ Backend ONLINE' -ForegroundColor Green; ^
} catch { ^
  Write-Host '✗ Backend OFFLINE - Make sure to run START_DEVELOPMENT.bat first' -ForegroundColor Red; ^
  exit 1; ^
}" >NUL 2>&1

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Backend not responding on port 9000
    echo.
    echo Please start the backend first:
    echo   1. Open another terminal
    echo   2. Run: START_DEVELOPMENT.bat
    echo   3. Wait for backend to start
    echo   4. Try this script again
    echo.
    pause
    goto end
)

echo.
echo ================================================================================
echo FLUTTER APP BUILD & DEPLOYMENT
echo ================================================================================
echo.

echo [Step 1] Checking Flutter setup...
flutter doctor -v 2>NUL | find "[✓]" >NUL
if %errorlevel% neq 0 (
    echo WARNING: Flutter issues detected
)

echo [Step 2] Getting dependencies...
call flutter pub get

echo.
echo [Step 3] Building and running app on emulator...
echo.
echo NOTE: First build takes ~2-3 minutes
echo       Subsequent builds are faster (hot reload)
echo.

call flutter run

echo.
echo ================================================================================
echo APP LAUNCHED
echo ================================================================================
echo.
echo While app is running in terminal above:
echo   - Press 'r' to hot reload (after code changes)
echo   - Press 'R' to hot restart (full restart)
echo   - Press 'q' to quit
echo.
echo In emulator:
echo   - Dashboard shows active bots from backend
echo   - Create new bot from mobile app
echo   - Verify real-time updates (5 second intervals)
echo   - Watch for intelligent features:
echo       * Strategy switching notifications
echo       * Position size adjustments
echo.
pause
goto end

:test_build
echo.
echo Building Flutter APK...
call flutter clean
call flutter pub get
call flutter build apk --release --split-per-abi
echo.
echo APK built! Location:
echo   build/app/outputs/flutter-apk/
echo.
echo Files:
echo   - app-armeabi-v7a-release.apk (32-bit)
echo   - app-arm64-v8a-release.apk (64-bit)
echo   - app-x86_64-release.apk (emulator)
echo.
pause
goto end

:end
echo.
echo Done.
