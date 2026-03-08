import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/trading_service.dart';
import 'services/bot_service.dart';
import 'services/statement_service.dart';
import 'services/financial_service.dart';
import 'utils/theme.dart';
import 'utils/environment_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment based on app mode (safe)
  try {
    EnvironmentConfig.setEnvironment(
      const String.fromEnvironment('ZWESTA_ENV', defaultValue: 'production') == 'production'
          ? Environment.production
          : const String.fromEnvironment('ZWESTA_ENV') == 'staging'
              ? Environment.staging
              : Environment.development,
    );
  } catch (_) {
    EnvironmentConfig.setEnvironment(Environment.production);
  }

  // Only log errors in debug mode
  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
    };
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, TradingService>(
          create: (context) => TradingService(null),
          update: (context, authService, tradingService) {
            tradingService?.updateToken(authService.token);
            return tradingService ?? TradingService(authService.token);
          },
        ),
        // Lazy create - don't initialize in constructor
        ChangeNotifierProvider(
          create: (_) => BotService(),
        ),
        // Lazy create - don't initialize in constructor
        ChangeNotifierProvider(
          create: (_) => StatementService(),
        ),
        // Lazy create - don't initialize in constructor
        ChangeNotifierProvider(
          create: (_) => FinancialService(),
        ),
      ],
      child: MaterialApp(
        title: 'Zwesta Trading System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

