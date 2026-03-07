# Quick Start Guide - New Features

## 🎯 PDF Statement Export

### Generate a Statement Programmatically

```dart
// Example in StatementsScreen
void _generateStatement(BuildContext context, TradingService tradingService, 
    StatementService statementService) async {
  final account = tradingService.accounts.first;
  final statement = await statementService.generateStatement(
    account,
    tradingService.trades,
    DateTime(2024, 1, 1),
    DateTime(2024, 1, 31),
  );
  
  // Export as PDF
  final pdf = await PdfExportService.generateStatementPdf(statement, account);
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'statement_${account.accountNumber}.pdf',
  );
}
```

### Statement Metrics Available

```dart
statement.totalTrades          // Total number of trades
statement.winningTrades       // Number of winning trades
statement.losingTrades        // Number of losing trades
statement.winRate             // Win rate percentage
statement.totalProfit         // Total profit amount
statement.totalLoss           // Total loss amount
statement.largestWin          // Largest winning trade
statement.largestLoss         // Largest losing trade
statement.averageWin          // Average win amount
statement.averageLoss         // Average loss amount
statement.openingBalance      // Account balance at start
statement.closingBalance      // Account balance at end
statement.netProfit           // Total profit - loss
```

## 🌍 Environment Configuration

### Build for Different Environments

```bash
# Development (Debug Mode)
flutter run --dart-define=ZWESTA_ENV=development

# Staging (Limited Debug)
flutter run --dart-define=ZWESTA_ENV=staging

# Production (Optimized)
flutter run --dart-define=ZWESTA_ENV=production
flutter build web --release --dart-define=ZWESTA_ENV=production
```

### Check Current Environment in Code

```dart
import 'package:zwesta_trading/utils/environment_config.dart';

// Get current environment
final env = EnvironmentConfig.currentEnvironment;
print('Current environment: ${EnvironmentConfig.environmentName}');

// Check if production
if (EnvironmentConfig.currentEnvironment == Environment.production) {
  // Production-specific code
}

// Get configuration values
final apiUrl = EnvironmentConfig.apiUrl;
final debugMode = EnvironmentConfig.debugMode;
final logLevel = EnvironmentConfig.logLevel;
```

### Feature Flags

```dart
// Check if features are enabled
if (EnvironmentConfig.enablePdfExport) {
  // Show PDF export button
}

if (EnvironmentConfig.enableOfflineMode) {
  // Enable offline functionality
}

if (EnvironmentConfig.enableDataEncryption) {
  // Use encrypted storage
}
```

## 📊 Statement Service Usage

### Generate Statement

```dart
final statementService = context.read<StatementService>();
final tradingService = context.read<TradingService>();

try {
  final statement = await statementService.generateStatement(
    account: tradingService.accounts[0],
    trades: tradingService.trades,
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 12, 31),
  );
  
  print('Statement generated: ${statement.id}');
} catch (e) {
  print('Error: $e');
}
```

### Load Statements

```dart
// Automatically loaded from SharedPreferences
final statements = statementService.statements;

for (var statement in statements) {
  print('${statement.accountNumber}: ${statement.totalTrades} trades');
}
```

### Delete Statement

```dart
await statementService.deleteStatement(statement.id);
```

## 📄 PDF Export Service

### Export Statement to PDF

```dart
final pdf = await PdfExportService.generateStatementPdf(statement, account);

// Get bytes
final bytes = await pdf.save();

// Share PDF
await Printing.sharePdf(bytes: bytes, filename: 'statement.pdf');

// Print directly
await Printing.layoutPdf(onLayout: (format) => pdf.save());
```

## 🖥️ Accessing New UI

### From Dashboard

Navigate to the Statements screen from the dashboard navigation:

```dart
// In dashboard navigation
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatementsScreen()),
    );
  },
  child: const Text('View Statements'),
)
```

### Statements Screen Features

- **Date Range Selection**: Pick custom start and end dates
- **Account Filter**: Select which account's statements to view
- **Generate Button**: Create new statement on-demand
- **Statement List**: View all generated statements
- **Quick Actions**: View details, export PDF, or delete

## 🔑 API Integration

### Using EnvironmentConfig for API Calls

```dart
import 'package:zwesta_trading/utils/environment_config.dart';

Future<void> fetchData() async {
  final url = Uri.parse('${EnvironmentConfig.apiUrl}/api/trades');
  
  final response = await http.get(
    url,
    headers: EnvironmentConfig.getHeaders(),
  );
  
  if (response.statusCode == 200) {
    // Process response
  }
}
```

## 📦 Provider Setup

The new services are automatically provided in main.dart:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService(prefs)),
    ChangeNotifierProxyProvider<AuthService, TradingService>(...),
    ChangeNotifierProvider(create: (_) => BotService()),
    ChangeNotifierProvider(create: (_) => StatementService()),
  ],
  child: MyApp(),
)
```

## 🧪 Testing Examples

### Test Statement Generation

```dart
testWidgets('Generate statement with trades', (WidgetTester tester) async {
  final statementService = StatementService();
  final account = Account(...);
  final trades = [Trade(...), Trade(...)];
  
  final statement = await statementService.generateStatement(
    account,
    trades,
    DateTime(2024, 1, 1),
    DateTime(2024, 12, 31),
  );
  
  expect(statement.totalTrades, equals(2));
  expect(statement.winRate, greaterThan(0));
});
```

## 🚀 VPS Deployment Quick Start

### 1. Prepare Application

```bash
# Get dependencies
flutter pub get

# Build for web
flutter build web --release --dart-define=ZWESTA_ENV=production
```

### 2. Set Environment Variables

```bash
export ZWESTA_ENV=production
export API_URL=https://api.zwesta.com
export DATABASE_URL=postgresql://user:password@localhost/zwesta
```

### 3. Run on VPS

```bash
# Using Flutter web server
flutter run -d web --web-hostname 0.0.0.0 --web-port 8080

# Or use production build with Nginx
# (See VPS_DEPLOYMENT_GUIDE.md)
```

## 📋 Troubleshooting

### PDF Export Not Working

```dart
// Check if feature is enabled
if (!EnvironmentConfig.enablePdfExport) {
  throw Exception('PDF export is disabled');
}

// Ensure proper permissions
// (Add to AndroidManifest.xml or iOS Info.plist)
```

### Statement Not Generating

```dart
// Check debug logs
print('Statement service error: ${statementService.errorMessage}');

// Verify environment
print('Environment: ${EnvironmentConfig.environmentName}');
```

### API Connection Issues

```dart
// Check API URL
print('API URL: ${EnvironmentConfig.apiUrl}');

// Verify timeout settings
print('Timeout: ${EnvironmentConfig.connectionTimeout}s');

// Check headers
print('Headers: ${EnvironmentConfig.getHeaders()}');
```

## 📚 Additional Resources

- [VPS Deployment Guide](VPS_DEPLOYMENT_GUIDE.md)
- [Enhanced Features](ENHANCED_FEATURES.md)
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
- [Environment Configuration](lib/utils/environment_config.dart)
- [Statement Service](lib/services/statement_service.dart)
- [PDF Export Service](lib/services/pdf_export_service.dart)

---

**Last Updated**: March 2026  
**Version**: 1.1.0
