class Bot {
  final String id;
  final bool isActive;
  final double riskPerTrade;
  final String riskType; // 'fixed' or 'percentage'
  final double maxDailyLoss;
  final List<String> tradingPairs;
  final List<String> strategies; // 'scalping', 'economic_events'
  final DateTime createdAt;
  final DateTime? startedAt;

  Bot({
    required this.id,
    required this.isActive,
    required this.riskPerTrade,
    required this.riskType,
    required this.maxDailyLoss,
    required this.tradingPairs,
    required this.strategies,
    required this.createdAt,
    this.startedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'riskPerTrade': riskPerTrade,
      'riskType': riskType,
      'maxDailyLoss': maxDailyLoss,
      'tradingPairs': tradingPairs,
      'strategies': strategies,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
    };
  }

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      id: json['id'],
      isActive: json['isActive'] ?? false,
      riskPerTrade: json['riskPerTrade'] ?? 0.0,
      riskType: json['riskType'] ?? 'fixed',
      maxDailyLoss: json['maxDailyLoss'] ?? 0.0,
      tradingPairs: List<String>.from(json['tradingPairs'] ?? []),
      strategies: List<String>.from(json['strategies'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    );
  }
}

class BotStats {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double grossProfit;
  final double commission;
  final double netProfit;
  final double dailyPnL;

  BotStats({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.grossProfit,
    required this.commission,
    required this.netProfit,
    required this.dailyPnL,
  });
}

class BotBilling {
  final double monthlyFee; // R1000
  final double commissionRate; // 15%
  final double totalEarnings;
  final double totalBilled;
  final DateTime billingCycle;

  BotBilling({
    required this.monthlyFee,
    required this.commissionRate,
    required this.totalEarnings,
    required this.totalBilled,
    required this.billingCycle,
  });
}
