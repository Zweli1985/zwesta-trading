class BrokerAccount {
  final String id;
  final String brokerName;
  final String accountNumber;
  final String server;
  final bool isDemo;
  final double accountBalance;
  final double leverage;
  final double spreadAverage;
  final DateTime createdAt;
  final DateTime? lastConnected;
  final bool isActive;
  final String connectionStatus; // CONNECTED, DISCONNECTED, RECONNECTING

  BrokerAccount({
    required this.id,
    required this.brokerName,
    required this.accountNumber,
    required this.server,
    required this.isDemo,
    required this.accountBalance,
    required this.leverage,
    required this.spreadAverage,
    required this.createdAt,
    this.lastConnected,
    required this.isActive,
    required this.connectionStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brokerName': brokerName,
      'accountNumber': accountNumber,
      'server': server,
      'isDemo': isDemo,
      'accountBalance': accountBalance,
      'leverage': leverage,
      'spreadAverage': spreadAverage,
      'createdAt': createdAt.toIso8601String(),
      'lastConnected': lastConnected?.toIso8601String(),
      'isActive': isActive,
      'connectionStatus': connectionStatus,
    };
  }

  factory BrokerAccount.fromJson(Map<String, dynamic> json) {
    return BrokerAccount(
      id: json['id'],
      brokerName: json['brokerName'],
      accountNumber: json['accountNumber'],
      server: json['server'],
      isDemo: json['isDemo'],
      accountBalance: (json['accountBalance'] ?? 0).toDouble(),
      leverage: (json['leverage'] ?? 1).toDouble(),
      spreadAverage: (json['spreadAverage'] ?? 1.5).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      lastConnected: json['lastConnected'] != null 
          ? DateTime.parse(json['lastConnected'])
          : null,
      isActive: json['isActive'],
      connectionStatus: json['connectionStatus'],
    );
  }
}

class ConnectionMetric {
  final DateTime timestamp;
  final double latency; // in milliseconds
  final bool isConnected;
  final String status;
  final double accountBalance;
  final int tradeCount;
  final double equityChange;

  ConnectionMetric({
    required this.timestamp,
    required this.latency,
    required this.isConnected,
    required this.status,
    required this.accountBalance,
    required this.tradeCount,
    required this.equityChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'latency': latency,
      'isConnected': isConnected,
      'status': status,
      'accountBalance': accountBalance,
      'tradeCount': tradeCount,
      'equityChange': equityChange,
    };
  }
}

class ConnectionStats {
  final int totalConnections;
  final int successfulConnections;
  final double successRate;
  final double averageLatency;
  final Duration totalUptime;
  final DateTime? lastSync;
  final List<ConnectionMetric> metrics;

  ConnectionStats({
    required this.totalConnections,
    required this.successfulConnections,
    required this.successRate,
    required this.averageLatency,
    required this.totalUptime,
    this.lastSync,
    required this.metrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalConnections': totalConnections,
      'successfulConnections': successfulConnections,
      'successRate': successRate,
      'averageLatency': averageLatency,
      'totalUptime': totalUptime.inSeconds,
      'lastSync': lastSync?.toIso8601String(),
      'metrics': metrics.map((m) => m.toJson()).toList(),
    };
  }
}

class BrokerRequirements {
  final String brokerName;
  final double minBalance;
  final double minLeverage;
  final double maxLeverage;
  final double minSpread;
  final double maxSpread;
  final List<String> tradableAssets;
  final bool hasCommission;
  final double commissionRate;
  final bool supportsScalping;
  final bool supportsEA;

  BrokerRequirements({
    required this.brokerName,
    required this.minBalance,
    required this.minLeverage,
    required this.maxLeverage,
    required this.minSpread,
    required this.maxSpread,
    required this.tradableAssets,
    required this.hasCommission,
    required this.commissionRate,
    required this.supportsScalping,
    required this.supportsEA,
  });
}
