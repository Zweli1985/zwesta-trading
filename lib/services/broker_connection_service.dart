import 'dart:async';
import 'dart:math';
import '../models/broker_connection_model.dart';
import 'connection_analytics_service.dart';

class BrokerConnectionService {
  static const Map<String, String> _validCredentials = {
    'demo': 'demo123',
    '136372035': 'demo123',
    '5678': 'secure123',
  };

  static final Map<String, BrokerRequirements> _brokerRequirements = {
    'XM': BrokerRequirements(
      brokerName: 'XM',
      minBalance: 50,
      minLeverage: 1,
      maxLeverage: 888,
      minSpread: 0.6,
      maxSpread: 2.0,
      tradableAssets: ['Forex', 'Metals', 'Indices', 'Stocks'],
      hasCommission: false,
      commissionRate: 0,
      supportsScalping: true,
      supportsEA: true,
    ),
    'Pepperstone': BrokerRequirements(
      brokerName: 'Pepperstone',
      minBalance: 200,
      minLeverage: 1,
      maxLeverage: 500,
      minSpread: 0.5,
      maxSpread: 1.5,
      tradableAssets: ['Forex', 'Metals', 'Cryptos'],
      hasCommission: true,
      commissionRate: 3.5,
      supportsScalping: true,
      supportsEA: true,
    ),
    'FxOpen': BrokerRequirements(
      brokerName: 'FxOpen',
      minBalance: 100,
      minLeverage: 1,
      maxLeverage: 500,
      minSpread: 0.4,
      maxSpread: 1.2,
      tradableAssets: ['Forex', 'Metals', 'Cryptos', 'Stocks'],
      hasCommission: false,
      commissionRate: 0,
      supportsScalping: true,
      supportsEA: true,
    ),
  };

  static final Map<String, List<ConnectionMetric>> _connectionHistory = {};
  static final Map<String, BrokerAccount> _accountCache = {};
  static final Map<String, StreamController<ConnectionMetric>> _monitoringStreams = {};

  /// Test connection with real broker API simulation
  static Future<Map<String, dynamic>> testConnection({
    required String broker,
    required String accountNumber,
    required String password,
    required String server,
  }) async {
    try {
      final random = Random();
      final latency = 50 + random.nextInt(100);
      await Future.delayed(Duration(milliseconds: latency));

      if (!_validateCredentials(accountNumber, password)) {
        return {
          'success': false,
          'connected': false,
          'message': 'Invalid credentials',
          'errorCode': 'AUTH_FAILED',
          'latency': latency,
        };
      }

      final isDemo = accountNumber == 'demo' || accountNumber == '136372035';
      final initialBalance = isDemo ? 100000.0 : 50000.0;

      final account = BrokerAccount(
        id: '${broker}_${accountNumber}_${DateTime.now().millisecondsSinceEpoch}',
        brokerName: broker,
        accountNumber: accountNumber,
        server: server,
        isDemo: isDemo,
        accountBalance: initialBalance,
        leverage: 100,
        spreadAverage: 1.5,
        createdAt: DateTime.now(),
        lastConnected: DateTime.now(),
        isActive: true,
        connectionStatus: 'CONNECTED',
      );

      _accountCache[account.id] = account;

      if (!_connectionHistory.containsKey(account.id)) {
        _connectionHistory[account.id] = [];
      }

      _recordMetric(account.id, initialBalance, true, 'CONNECTED', latency.toDouble());

      return {
        'success': true,
        'connected': true,
        'account': account,
        'message': 'Connection established',
        'latency': latency,
        'balance': initialBalance,
        'leverage': 100,
        'accountType': isDemo ? 'Demo' : 'Live',
      };
    } catch (e) {
      return {
        'success': false,
        'connected': false,
        'message': 'Connection failed: $e',
        'errorCode': 'CONNECTION_ERROR',
      };
    }
  }

  /// Get all saved accounts
  static List<BrokerAccount> getSavedAccounts() {
    return _accountCache.values.toList();
  }

  /// Get specific account
  static BrokerAccount? getAccount(String accountId) {
    return _accountCache[accountId];
  }

  /// Get real-time account balance
  static double getAccountBalance(String accountId) {
    if (_accountCache.containsKey(accountId)) {
      final random = Random();
      final change = (random.nextDouble() - 0.5) * 100;
      return _accountCache[accountId]!.accountBalance + change;
    }
    return 0;
  }

  /// Get broker requirements
  static BrokerRequirements? getBrokerRequirements(String brokerName) {
    return _brokerRequirements[brokerName];
  }

  /// Get connection statistics
  static ConnectionStats getConnectionStats(String accountId) {
    final metrics = _connectionHistory[accountId] ?? [];
    final successful = metrics.where((m) => m.isConnected).length;
    final total = metrics.length;
    final successRate = total > 0 ? ((successful / total) * 100).toDouble() : 0.0;

    double avgLatency = 0;
    if (metrics.isNotEmpty) {
      avgLatency = metrics.fold<double>(0, (sum, m) => sum + m.latency) / metrics.length;
    }

    return ConnectionStats(
      totalConnections: total,
      successfulConnections: successful,
      successRate: successRate,
      averageLatency: avgLatency,
      totalUptime: Duration(minutes: total * 5),
      lastSync: metrics.isNotEmpty ? metrics.last.timestamp : null,
      metrics: metrics,
    );
  }

  /// Stream connection metrics in real-time
  static Stream<ConnectionMetric> monitorConnection({
    required String accountId,
  }) {
    if (!_monitoringStreams.containsKey(accountId)) {
      _monitoringStreams[accountId] = StreamController<ConnectionMetric>();

      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_monitoringStreams.containsKey(accountId) && 
            !_monitoringStreams[accountId]!.isClosed) {
          final random = Random();
          final balance = (_accountCache[accountId]?.accountBalance ?? 0) +
              (random.nextDouble() - 0.5) * 50;
          final latency = 30 + random.nextInt(120).toDouble();

          _recordMetric(
            accountId,
            balance,
            random.nextDouble() > 0.05,
            'CONNECTED',
            latency,
          );

          final metrics = _connectionHistory[accountId] ?? [];
          if (metrics.isNotEmpty) {
            _monitoringStreams[accountId]?.add(metrics.last);
          }
        } else {
          timer.cancel();
        }
      });
    }

    return _monitoringStreams[accountId]!.stream;
  }

  /// Record connection metric
  static void _recordMetric(
    String accountId,
    double balance,
    bool isConnected,
    String status,
    double latency,
  ) {
    final metric = ConnectionMetric(
      timestamp: DateTime.now(),
      latency: latency,
      isConnected: isConnected,
      status: status,
      accountBalance: balance,
      tradeCount: _getRandomTradeCount(),
      equityChange: (Random().nextDouble() - 0.5) * 200,
    );

    if (!_connectionHistory.containsKey(accountId)) {
      _connectionHistory[accountId] = [];
    }

    _connectionHistory[accountId]!.add(metric);

    // Record in analytics service
    ConnectionAnalyticsService.recordMetric(accountId: accountId, metric: metric);

    if (_connectionHistory[accountId]!.length > 100) {
      _connectionHistory[accountId]!.removeAt(0);
    }
  }

  static int _getRandomTradeCount() {
    return Random().nextInt(150) + 50;
  }

  static bool _validateCredentials(String accountNumber, String password) {
    return _validCredentials[accountNumber] == password;
  }

  /// Test auto-reconnect with exponential backoff
  static Future<bool> testAutoReconnect({
    required String accountId,
    int maxAttempts = 3,
  }) async {
    int attempts = 0;
    int delayMs = 1000;

    while (attempts < maxAttempts) {
      try {
        await Future.delayed(Duration(milliseconds: delayMs));
        return Random().nextDouble() > 0.3;
      } catch (e) {
        attempts++;
        delayMs *= 2;
      }
    }
    return false;
  }

  /// Cleanup resources
  static void dispose() {
    for (var stream in _monitoringStreams.values) {
      if (!stream.isClosed) {
        stream.close();
      }
    }
    _monitoringStreams.clear();
    ConnectionAnalyticsService.dispose();
  }
}
