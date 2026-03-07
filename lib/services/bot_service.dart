import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bot_model.dart';

class BotService extends ChangeNotifier {
  Bot? _bot;
  BotStats? _stats;
  BotBilling? _billing;
  bool _isLoading = false;

  Bot? get bot => _bot;
  BotStats? get stats => _stats;
  BotBilling? get billing => _billing;
  bool get isLoading => _isLoading;

  // Updated list with all 24 commodities
  final List<String> availableTradingSymbols = [
    // Forex
    'EURUSD', 'GBPUSD', 'USDJPY', 'USDCHF', 'AUDUSD', 'USDCAD', 'NZDUSD',
    
    // Precious Metals
    'XAUUSD', 'XAGUSD', 'XPTUSD', 'XPDUSD',
    
    // Energy
    'WTIUSD', 'BRENTUSD', 'NATGASUS',
    
    // Agriculture  
    'CORNUSD', 'WHEATUSD', 'SOYBEANSUSD', 'COFFEEUSD', 'COCOAUSD', 'SUGARUSD',
    
    // Indices
    'SPX500', 'DAX40', 'FTSE100', 'NIKKEI225'
  ];

  final List<String> availableStrategies = [
    'Scalping',
    'Momentum Trading',
    'Trend Following',
    'Mean Reversion',
    'Range Trading',
    'Breakout Trading'
  ];

  BotService() {
    // Initialize lazily when needed, not in constructor
  }

  Future<void> _initializeBot() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final botJson = prefs.getString('bot_config');

      if (botJson != null) {
        _bot = Bot.fromJson(jsonDecode(botJson));
        _loadBotStats();
        _loadBotBilling();
      } else {
        // Create default bot
        _bot = Bot(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          isActive: false,
          riskPerTrade: 100.0,
          riskType: 'fixed',
          maxDailyLoss: 500.0,
          tradingPairs: ['EURUSD', 'BTCUSD'],
          strategies: ['Scalping'],
          createdAt: DateTime.now(),
        );
        await saveBot(_bot!);
      }
    } catch (e) {
      print('Error initializing bot: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveBot(Bot bot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bot_config', jsonEncode(bot.toJson()));
      _bot = bot;
      notifyListeners();
    } catch (e) {
      print('Error saving bot: $e');
    }
  }

  Future<void> toggleBot(bool isActive) async {
    if (_bot != null) {
      final updatedBot = Bot(
        id: _bot!.id,
        isActive: isActive,
        riskPerTrade: _bot!.riskPerTrade,
        riskType: _bot!.riskType,
        maxDailyLoss: _bot!.maxDailyLoss,
        tradingPairs: _bot!.tradingPairs,
        strategies: _bot!.strategies,
        createdAt: _bot!.createdAt,
        startedAt: isActive ? DateTime.now() : _bot!.startedAt,
      );
      await saveBot(updatedBot);
      _loadBotStats();
    }
  }

  Future<void> updateRiskSettings({
    required double riskPerTrade,
    required String riskType,
    required double maxDailyLoss,
  }) async {
    if (_bot != null) {
      final updatedBot = Bot(
        id: _bot!.id,
        isActive: _bot!.isActive,
        riskPerTrade: riskPerTrade,
        riskType: riskType,
        maxDailyLoss: maxDailyLoss,
        tradingPairs: _bot!.tradingPairs,
        strategies: _bot!.strategies,
        createdAt: _bot!.createdAt,
        startedAt: _bot!.startedAt,
      );
      await saveBot(updatedBot);
    }
  }

  Future<void> updateTradingPairs(List<String> pairs) async {
    if (_bot != null) {
      final updatedBot = Bot(
        id: _bot!.id,
        isActive: _bot!.isActive,
        riskPerTrade: _bot!.riskPerTrade,
        riskType: _bot!.riskType,
        maxDailyLoss: _bot!.maxDailyLoss,
        tradingPairs: pairs,
        strategies: _bot!.strategies,
        createdAt: _bot!.createdAt,
        startedAt: _bot!.startedAt,
      );
      await saveBot(updatedBot);
    }
  }

  Future<void> updateStrategies(List<String> strategies) async {
    if (_bot != null) {
      final updatedBot = Bot(
        id: _bot!.id,
        isActive: _bot!.isActive,
        riskPerTrade: _bot!.riskPerTrade,
        riskType: _bot!.riskType,
        maxDailyLoss: _bot!.maxDailyLoss,
        tradingPairs: _bot!.tradingPairs,
        strategies: strategies,
        createdAt: _bot!.createdAt,
        startedAt: _bot!.startedAt,
      );
      await saveBot(updatedBot);
    }
  }

  void _loadBotStats() {
    // Mock data for demonstration
    _stats = BotStats(
      totalTrades: _bot?.isActive == true ? 125 : 0,
      winningTrades: _bot?.isActive == true ? 87 : 0,
      losingTrades: _bot?.isActive == true ? 38 : 0,
      winRate: _bot?.isActive == true ? 0.696 : 0,
      grossProfit: _bot?.isActive == true ? 4500.00 : 0,
      commission: _bot?.isActive == true ? 675.00 : 0,
      netProfit: _bot?.isActive == true ? 3825.00 : 0,
      dailyPnL: _bot?.isActive == true ? 325.50 : 0,
    );
    notifyListeners();
  }

  void _loadBotBilling() {
    // Mock data - R1000/month + 15% commission
    _billing = BotBilling(
      monthlyFee: 1000.00,
      commissionRate: 0.15,
      totalEarnings: 3825.00,
      totalBilled: 1000.00 + (3825.00 * 0.15),
      billingCycle: DateTime.now(),
    );
    notifyListeners();
  }
}
