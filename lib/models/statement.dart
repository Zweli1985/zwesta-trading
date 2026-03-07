class Statement {
  final String id;
  final String accountId;
  final String accountNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double openingBalance;
  final double closingBalance;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalProfit;
  final double totalLoss;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double largestWin;
  final double largestLoss;
  final double averageWin;
  final double averageLoss;
  final List<StatementTrade> trades;
  final DateTime generatedAt;

  Statement({
    required this.id,
    required this.accountId,
    required this.accountNumber,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalProfit,
    required this.totalLoss,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.largestWin,
    required this.largestLoss,
    required this.averageWin,
    required this.averageLoss,
    required this.trades,
    required this.generatedAt,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toString()),
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      closingBalance: (json['closingBalance'] ?? 0).toDouble(),
      totalDeposits: (json['totalDeposits'] ?? 0).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      totalLoss: (json['totalLoss'] ?? 0).toDouble(),
      totalTrades: json['totalTrades'] ?? 0,
      winningTrades: json['winningTrades'] ?? 0,
      losingTrades: json['losingTrades'] ?? 0,
      winRate: (json['winRate'] ?? 0).toDouble(),
      largestWin: (json['largestWin'] ?? 0).toDouble(),
      largestLoss: (json['largestLoss'] ?? 0).toDouble(),
      averageWin: (json['averageWin'] ?? 0).toDouble(),
      averageLoss: (json['averageLoss'] ?? 0).toDouble(),
      trades: (json['trades'] as List?)
          ?.map((t) => StatementTrade.fromJson(t))
          .toList() ?? [],
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountNumber': accountNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
      'totalDeposits': totalDeposits,
      'totalWithdrawals': totalWithdrawals,
      'totalProfit': totalProfit,
      'totalLoss': totalLoss,
      'totalTrades': totalTrades,
      'winningTrades': winningTrades,
      'losingTrades': losingTrades,
      'winRate': winRate,
      'largestWin': largestWin,
      'largestLoss': largestLoss,
      'averageWin': averageWin,
      'averageLoss': averageLoss,
      'trades': trades.map((t) => t.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class StatementTrade {
  final String id;
  final String symbol;
  final String type;
  final double quantity;
  final double entryPrice;
  final double exitPrice;
  final DateTime openDate;
  final DateTime closeDate;
  final double profit;
  final double profitPercentage;
  final String status;

  StatementTrade({
    required this.id,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.entryPrice,
    required this.exitPrice,
    required this.openDate,
    required this.closeDate,
    required this.profit,
    required this.profitPercentage,
    required this.status,
  });

  factory StatementTrade.fromJson(Map<String, dynamic> json) {
    return StatementTrade(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      type: json['type'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      exitPrice: (json['exitPrice'] ?? 0).toDouble(),
      openDate: DateTime.parse(json['openDate'] ?? DateTime.now().toString()),
      closeDate: DateTime.parse(json['closeDate'] ?? DateTime.now().toString()),
      profit: (json['profit'] ?? 0).toDouble(),
      profitPercentage: (json['profitPercentage'] ?? 0).toDouble(),
      status: json['status'] ?? 'closed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'openDate': openDate.toIso8601String(),
      'closeDate': closeDate.toIso8601String(),
      'profit': profit,
      'profitPercentage': profitPercentage,
      'status': status,
    };
  }
}
