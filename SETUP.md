# Zwesta Trading Flutter App - Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### 1. Flutter SDK
- Download from: https://flutter.dev/docs/get-started/install
- Minimum version: 3.0.0
- Add Flutter to your PATH

### 2. Dart SDK
- Usually comes bundled with Flutter
- Verify installation: `dart --version`

### 3. IDE/Editor
- **Recommended**: Visual Studio Code or Android Studio
- Install Flutter and Dart extensions

### 4. Emulator or Physical Device
- **Android**: Android Studio emulator or physical device with Android 21+
- **iOS**: Xcode simulator or physical device (requires macOS)
- **Web**: Can run on Chrome browser

## Installation Steps

### Step 1: Clone/Download Project

```bash
# Navigate to the project directory
cd "Zwesta Flutter App"
```

### Step 2: Get Flutter Dependencies

```bash
# Get all project dependencies
flutter pub get
```

### Step 3: Verify Setup

```bash
# Check Flutter environment
flutter doctor

# Should show:
# - Flutter SDK
# - Dart SDK
# - At least one connected device or emulator
```

## Running the App

### Option 1: Run on Android Emulator

```bash
# Start Android emulator
emulator -avd <emulator_name>

# Run the app
flutter run
```

### Option 2: Run on iOS Simulator (macOS only)

```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run
```

### Option 3: Run on Physical Device

```bash
# Connect device via USB
# Enable Developer Mode and USB Debugging

# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Option 4: Run on Web

```bash
# Run on Chrome (default)
flutter run -d chrome

# Run on Firefox
flutter run -d firefox

# Run on Safari (macOS)
flutter run -d safari
```

## Building the App

### Android APK

```bash
# Release APK
flutter build apk --release

# Split APK (smaller size)
flutter build apk --split-per-abi
```

### iOS App

```bash
# iOS App Bundle (requires Apple developer account)
flutter build ios --release
```

### Web Bundle

```bash
# Web release
flutter build web --release
```

## Project Structure

```
Zwesta Flutter App/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── screens/                       # UI screens
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── trades_screen.dart
│   │   └── account_management_screen.dart
│   ├── models/                        # Data models
│   │   ├── user.dart
│   │   ├── trade.dart
│   │   └── account.dart
│   ├── services/                      # Business logic
│   │   ├── auth_service.dart
│   │   └── trading_service.dart
│   ├── widgets/                       # Reusable widgets
│   │   └── custom_widgets.dart
│   └── utils/                         # Utilities
│       ├── constants.dart
│       └── theme.dart
├── assets/                            # Static assets
├── pubspec.yaml                       # Project configuration
├── analysis_options.yaml               # Linter rules
└── README.md                          # Documentation
```

## Testing

### Run Flutter Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Run Analyzer

```bash
# Check for linting issues
flutter analyze

# Fix issues automatically (when possible)
dart fix --apply
```

## Development Tips

### Hot Reload
- Press 'r' in terminal while app is running
- Reloads code without losing state

### Hot Restart
- Press 'R' in terminal
- Full restart of the app

### Debug Mode
- Use `flutter run` (default)
- Access DevTools: Press 'd' while app is running

### Release Mode
- Use `flutter run --release`
- For performance testing

## API Integration

Currently, the app uses mock data for demonstration. To integrate with your backend:

### 1. Update Base URL
Edit `lib/utils/constants.dart`:

```dart
static const String apiBaseUrl = 'YOUR_API_URL';
```

### 2. Update AuthService
Update `lib/services/auth_service.dart` to make HTTP requests:

```dart
Future<bool> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);
      // ... save to storage
      return true;
    }
    return false;
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  }
}
```

### 3. Update TradingService
Similarly update trading API calls in `lib/services/trading_service.dart`

## Environment Setup

### Development Environment

```bash
# Create .env file (optional)
echo "API_BASE_URL=https://api-dev.zwesta.com" > .env
echo "APP_VERSION=1.0.0" >> .env
```

### Release Environment

Update configuration for production:

1. **API Endpoints**: Use production URLs
2. **Error Reporting**: Integrate Sentry or similar
3. **Logging**: Disable verbose logging
4. **Analytics**: Enable analytics tracking

## Troubleshooting

### Issue: "Flutter not found"
- **Solution**: Add Flutter to PATH or use full path to flutter executable

### Issue: "No connected devices"
- **Solution**: 
  - Check `flutter devices`
  - Start an emulator or connect a physical device
  - Run `adb devices` for Android devices

### Issue: "Gradle build failed"
- **Solution**: 
  - Clean build: `flutter clean && flutter pub get`
  - Update Gradle: `./gradlew --version`

### Issue: "Pod install failed" (iOS)
- **Solution**:
  - `cd ios && pod deintegrate && pod install && cd ..`
  - Ensure Xcode is updated

### Issue: "Dependencies conflict"
- **Solution**:
  - `flutter pub outdated`
  - `flutter pub upgrade`
  - Check pubspec.yaml for version conflicts

## Performance Optimization

### Build Size
```bash
# Analyze app size
flutter build apk --analyze-size

# Generate size report
flutter build web --web-release-build
```

### Runtime Performance
- Use DevTools Profiler
- Check Performance tab in DevTools
- Monitor frame rate (target: 60 FPS)

## Security Best Practices

1. **API Communication**
   - Always use HTTPS
   - Implement certificate pinning

2. **Local Storage**
   - Never store sensitive data in plain text
   - Use encrypted_shared_preferences for sensitive data

3. **Authentication**
   - Implement token refresh mechanism
   - Handle token expiration gracefully

4. **Code Obfuscation**
   ```bash
   flutter build apk --obfuscate --split-debug-info=./symbols
   ```

## Deployment

### Google Play Store
1. Create app bundle: `flutter build appbundle --release`
2. Sign the bundle
3. Upload to Google Play Console

### Apple App Store
1. Build iOS app: `flutter build ios --release`
2. Create Archive in Xcode
3. Configure in App Store Connect
4. Submit for review

## Support & Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Dart Documentation**: https://dart.dev/guides
- **Provider Package**: https://pub.dev/packages/provider
- **Flutter Community**: https://flutter.dev/community

## Next Steps

1. Review the [README.md](README.md) for feature documentation
2. Explore the code and understand the architecture
3. Customize styling and branding
4. Integrate with your backend API
5. Add additional features as needed

## License

© 2024 Zwesta Trading System. All rights reserved.
