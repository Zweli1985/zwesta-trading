# Zwesta Trading Flutter App - Quick Reference Guide

## 🚀 Quick Start Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## 🔑 Demo Credentials

```
Username: demo
Password: demo123
```

---

## 📚 File Navigation Guide

| What you want | File location |
|---|---|
| **Add a new screen** | `lib/screens/new_screen.dart` |
| **Modify app colors** | `lib/utils/constants.dart` |
| **Change app theme** | `lib/utils/theme.dart` |
| **Handle authentication** | `lib/services/auth_service.dart` |
| **Manage trades** | `lib/services/trading_service.dart` |
| **Create new widget** | `lib/widgets/custom_widgets.dart` |
| **Define data model** | `lib/models/your_model.dart` |
| **Main app setup** | `lib/main.dart` |

---

## 🎯 Common Tasks

### **Add a new page/screen**

1. Create file: `lib/screens/new_screen.dart`
2. Implement StatefulWidget or StatelessWidget
3. Add to navigation in `dashboard_screen.dart`
4. Update `lib/screens/index.dart`

```dart
class NewScreen extends StatelessWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screen')),
      body: Center(
        child: Text('Your content here'),
      ),
    );
  }
}
```

### **Access user data**

```dart
final user = context.read<AuthService>().currentUser;
print(user?.fullName);
```

### **Make API call**

```dart
Future<void> fetchData() async {
  try {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      // Handle success
    }
  } catch (e) {
    // Handle error
  }
}
```

### **Show error banner**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error message')),
);
```

### **Show dialog**

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Title'),
    content: const Text('Content'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);
```

### **Use Consumer for state**

```dart
Consumer<TradingService>(
  builder: (context, tradingService, _) {
    return Text('Balance: ${tradingService.totalBalance}');
  },
)
```

---

## 🎨 Color Reference

```dart
// Use these colors from AppColors class
AppColors.primaryColor      // #1E88E5
AppColors.primaryDark       // #1565C0
AppColors.primaryLight      // #64B5F6
AppColors.accentColor       // #FF6B6B
AppColors.successColor      // #4CAF50
AppColors.warningColor      // #FFC107
AppColors.dangerColor       // #F44336
AppColors.dark              // #1F1F1F
AppColors.darkGrey          // #424242
AppColors.grey              // #757575
AppColors.lightGrey         // #BDBDBD
AppColors.veryLightGrey     // #E0E0E0
AppColors.white             // #FFFFFF
```

---

## 📐 Spacing Reference

```dart
// Use these spacing values
AppSpacing.xs   // 4dp
AppSpacing.sm   // 8dp
AppSpacing.md   // 16dp
AppSpacing.lg   // 24dp
AppSpacing.xl   // 32dp
```

---

## 🔄 State Management Patterns

### **Read Provider**
```dart
final value = context.read<MyService>().property;
```

### **Watch Provider (rebuild on change)**
```dart
final value = context.watch<MyService>().property;
```

### **Consumer (watch + builder)**
```dart
Consumer<MyService>(
  builder: (context, service, _) => Text(service.property),
)
```

### **Listen (one-time)**
```dart
context.read<MyService>().addListener(() {
  // React to changes
});
```

---

## 🧩 Widget Components

### **StatCard**
```dart
StatCard(
  title: 'Balance',
  value: '\$50,000',
  icon: Icons.money,
  foregroundColor: AppColors.primaryColor,
)
```

### **TradeCard**
```dart
TradeCard(
  symbol: 'EUR/USD',
  type: 'buy',
  quantity: 10000,
  entryPrice: 1.0850,
  currentPrice: 1.0920,
  profit: 700,
  profitPercentage: 0.64,
)
```

### **ErrorBanner**
```dart
ErrorBanner(
  message: 'Something went wrong',
  onDismiss: () => authService.clearErrorMessage(),
)
```

---

## 🐛 Debugging Tips

### **Enable verbose logging**
```bash
flutter run -v
```

### **Restart app quickly**
- Press `R` in terminal

### **Hot reload**
- Press `r` in terminal

### **Open DevTools**
- Press `d` in terminal

### **Check device list**
```bash
flutter devices
```

### **Check Flutter setup**
```bash
flutter doctor
```

---

## 📦 Adding Dependencies

### **Add new package**
```bash
flutter pub add package_name
```

### **Add dev dependency**
```bash
flutter pub add --dev package_name
```

### **Update dependencies**
```bash
flutter pub upgrade
```

### **Get specific version**
```bash
flutter pub add package_name:^1.0.0
```

---

## 🔗 API Integration Checklist

- [ ] Set API base URL in `constants.dart`
- [ ] Update `auth_service.dart` login method
- [ ] Add token to API headers
- [ ] Handle 401 (unauthorized) responses
- [ ] Implement token refresh
- [ ] Add error handling
- [ ] Test with real API
- [ ] Add request validation
- [ ] Add response validation

---

## 🧪 Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 🚨 Common Errors & Solutions

### **"Flutter not found"**
```bash
# Add Flutter to PATH or use full path
export PATH="$PATH:/path/to/flutter/bin"
```

### **"No connected devices"**
```bash
# List devices
flutter devices

# Start emulator
emulator -avd emulator_name
```

### **"Gradle build failed"**
```bash
flutter clean
flutter pub get
flutter run
```

### **"Pod install failed" (iOS)**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

---

## 📱 Platform-Specific Paths

### **Android**
- Config: `android/app/build.gradle`
- Manifest: `android/app/src/main/AndroidManifest.xml`
- Icons: `android/app/src/main/res/`

### **iOS**
- Config: `ios/Podfile`
- Project: `ios/Runner.xcodeproj`
- Icons: `ios/Runner/Assets.xcassets`

### **Web**
- Config: `web/index.html`
- Assets: `web/assets`

---

## 🎯 Project Constants

```dart
// From constants.dart
const String appName = 'Zwesta Trading';
const String apiBaseUrl = 'https://api.zwesta-trading.com';
const Duration connectionTimeout = Duration(seconds: 30);
const Duration receiveTimeout = Duration(seconds: 30);
```

---

## 🔐 Security Checklist

- [ ] Never hardcode API keys or passwords
- [ ] Use HTTPS for all API calls
- [ ] Validate all user inputs
- [ ] Encrypt sensitive local data
- [ ] Implement token refresh mechanism
- [ ] Handle session timeouts
- [ ] Validate API responses
- [ ] Use certificate pinning for production
- [ ] Implement rate limiting
- [ ] Add request signing

---

## 📊 Performance Tips

1. **Use const constructors** when possible
2. **Minimize rebuilds** with Consumer/Selector
3. **Lazy load** images and data
4. **Cache API responses** locally
5. **Use ListView.builder** for long lists
6. **Profile with DevTools** before optimizing
7. **Use release mode** for performance testing
8. **Minimize dependencies** and bundle size

---

## 🌍 Localization Setup (Future)

```dart
// Add to pubspec.yaml
dependencies:
  intl: ^0.18.0

// Use in code
import 'package:intl/intl.dart';

final formatter = NumberFormat.currency(locale: 'en_US');
print(formatter.format(1000)); // $1,000.00
```

---

## 📚 Useful Documentation Links

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
- [Flutter Community](https://flutter.dev/community)

---

## 💡 Pro Tips

1. **Use `?? ??` operator** for null safety
2. **Always use `const`** for widgets
3. **Extract widgets** to reduce complexity
4. **Use meaningful variable names**
5. **Comment complex logic** only
6. **Run `flutter analyze`** before commits
7. **Test on both platforms** before release
8. **Monitor bundle size** in releases

---

## 📝 Code Style

```dart
// Use single quotes
final String name = 'John';

// Use const where possible
const Widget divider = SizedBox(height: 16);

// Use trailing commas
final widget = MyWidget(
  title: 'Title',
  description: 'Description', // Trailing comma helps with formatting
);

// Use if instead of ternary for readability
if (isValid) {
  doSomething();
} else {
  doOtherThing();
}
```

---

## 🚀 Deployment Checklist

- [ ] Update version in pubspec.yaml
- [ ] Update build number
- [ ] Run tests and analyze
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Update privacy policy
- [ ] Update terms of service
- [ ] Prepare screenshots
- [ ] Write release notes
- [ ] Submit for review

---

**Last Updated**: March 2026

**Next Steps**: 
1. Run `flutter pub get`
2. Test with demo credentials
3. Explore the codebase
4. Customize for your needs
5. Integrate your backend API

Good luck! 🎉
