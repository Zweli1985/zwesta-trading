import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bot_configuration_screen.dart';
import 'bot_dashboard_screen.dart';

class BotAnalyticsScreen extends StatefulWidget {
  final Map<String, dynamic> bot;

  const BotAnalyticsScreen({
    Key? key,
    required this.bot,
  }) : super(key: key);

  @override
  State<BotAnalyticsScreen> createState() => _BotAnalyticsScreenState();
}

class _BotAnalyticsScreenState extends State<BotAnalyticsScreen> {
  late Future<void> _analyticsLoad;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _analyticsLoad = _refreshAnalytics();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _analyticsLoad = _refreshAnalytics();
        });
      }
    });
  }

  Future<void> _refreshAnalytics() async {
    // Refresh bot data
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing analytics: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  List<FlSpot> _getProfitChartData() {
    final profitHistory = widget.bot['profitHistory'] as List?;
    if (profitHistory == null || profitHistory.isEmpty) {
      return [];
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < profitHistory.length; i++) {
      final point = profitHistory[i];
      spots.add(FlSpot(i.toDouble(), (point['profit'] as num).toDouble()));
    }
    return spots;
  }

  List<BarChartGroupData> _getTradesChartData() {
    final profitHistory = widget.bot['profitHistory'] as List?;
    if (profitHistory == null || profitHistory.isEmpty) {
      return [];
    }

    List<BarChartGroupData> groups = [];
    for (int i = 0; i < profitHistory.length; i++) {
      final point = profitHistory[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (point['trades'] as num).toDouble(),
              color: Colors.blue,
              width: 8,
            ),
          ],
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    try {
      const textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );

      final totalProfit = (widget.bot['totalProfit'] ?? 0).toDouble();
      final totalTrades = widget.bot['totalTrades']?.toInt() ?? 0;
      final winRate = (widget.bot['winRate'] ?? 0).toDouble();
      final roi = (widget.bot['roi'] ?? 0).toDouble();
      final runtimeFormatted = widget.bot['runtimeFormatted'] ?? '0h 0m';
      final dailyProfit = (widget.bot['dailyProfit'] ?? 0).toDouble();
      final avgProfitPerTrade = (widget.bot['avgProfitPerTrade'] ?? 0).toDouble();
      final maxDrawdown = (widget.bot['maxDrawdown'] ?? 0).toDouble();
      final botStatus = widget.bot['status'] ?? 'Unknown';

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.bot['botId'] ?? 'Bot Analytics'),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BotConfigurationScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Config'),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Runtime Section
              _buildStatusSection(
                runtimeFormatted: runtimeFormatted,
                status: botStatus,
                dailyProfit: dailyProfit,
              ),
              const SizedBox(height: 24),

              // Key Metrics Grid
              _buildMetricsGrid(
                totalProfit: totalProfit,
                totalTrades: totalTrades,
                winRate: winRate,
                roi: roi,
                avgProfitPerTrade: avgProfitPerTrade,
                maxDrawdown: maxDrawdown,
              ),
              const SizedBox(height: 24),

              // Profit Over Time Chart
              _buildSectionHeader('Profit Over Time'),
              _buildProfitChart(),
              const SizedBox(height: 24),

              // Trades Growth Chart
              _buildSectionHeader('Trades Growth'),
              _buildTradesChart(),
              const SizedBox(height: 24),

              // Daily Profit Distribution
              if (widget.bot['dailyProfits'] != null && (widget.bot['dailyProfits'] as Map).isNotEmpty)
                _buildDailyProfitsSection(),

              // Trade History
              const SizedBox(height: 24),
              _buildSectionHeader('Recent Trades'),
              _buildTradeHistorySection(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      );
    } catch (e) {
      print('Error building BotAnalyticsScreen: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bot Analytics'),
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.grey[850],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading analytics',
                style: TextStyle(color: Colors.red[400]),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BotDashboardScreen()),
            );
          }
        },
        currentIndex: 2,
      ),
    );
  }

  Widget _buildStatusSection({
    required String runtimeFormatted,
    required String status,
    required double dailyProfit,
  }) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Runtime: $runtimeFormatted',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Today\'s Profit',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${dailyProfit.toStringAsFixed(2)}',
                style: TextStyle(
                  color: dailyProfit >= 0 ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid({
    required double totalProfit,
    required int totalTrades,
    required double winRate,
    required double roi,
    required double avgProfitPerTrade,
    required double maxDrawdown,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard(
          label: 'Total Profit',
          value: '\$${totalProfit.toStringAsFixed(2)}',
          color: totalProfit >= 0 ? Colors.green : Colors.red,
          icon: Icons.trending_up,
        ),
        _buildMetricCard(
          label: 'Total Trades',
          value: totalTrades.toString(),
          color: Colors.blue,
          icon: Icons.credit_card,
        ),
        _buildMetricCard(
          label: 'Win Rate',
          value: '${winRate.toStringAsFixed(1)}%',
          color: Colors.purple,
          icon: Icons.leaderboard,
        ),
        _buildMetricCard(
          label: 'ROI',
          value: '${roi.toStringAsFixed(1)}%',
          color: Colors.orange,
          icon: Icons.percent,
        ),
        _buildMetricCard(
          label: 'Avg Profit/Trade',
          value: '\$${avgProfitPerTrade.toStringAsFixed(2)}',
          color: Colors.cyan,
          icon: Icons.bar_chart,
        ),
        _buildMetricCard(
          label: 'Max Drawdown',
          value: '\$${maxDrawdown.toStringAsFixed(2)}',
          color: Colors.red[400]!,
          icon: Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfitChart() {
    final data = _getProfitChartData();
    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No data yet', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final maxProfit = data.fold<double>(0, (prev, spot) => spot.y > prev ? spot.y : prev);
    final minProfit = data.fold<double>(0, (prev, spot) => spot.y < prev ? spot.y : prev);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.8), Colors.green.withOpacity(0.2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
          minY: minProfit - 100,
          maxY: maxProfit + 100,
        ),
      ),
    );
  }

  Widget _buildTradesChart() {
    final data = _getTradesChartData();
    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No data yet', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.fold<double>(
            0,
            (prev, group) => group.barRods[0].toY > prev ? group.barRods[0].toY : prev,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          barGroups: data,
        ),
      ),
    );
  }

  Widget _buildDailyProfitsSection() {
    final dailyProfits = widget.bot['dailyProfits'] as Map?;
    if (dailyProfits == null || dailyProfits.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = dailyProfits.entries.toList();
    final pieData = entries
        .asMap()
        .entries
        .map((e) => PieChartSectionData(
          value: (e.value.value as num).toDouble().abs() + 1, // Add 1 to avoid 0
          color: (e.value.value as num) >= 0
              ? Colors.green.withOpacity(0.7)
              : Colors.red.withOpacity(0.7),
          radius: 50,
        ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daily Profits'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          height: 250,
          child: pieData.isEmpty
              ? const Center(
                  child: Text(
                    'No daily data',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : PieChart(
                  PieChartData(
                    sections: pieData,
                    centerSpaceRadius: 40,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTradeHistorySection() {
    final tradeHistory = widget.bot['tradeHistory'] as List?;
    if (tradeHistory == null || tradeHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No trades yet',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final recentTrades = tradeHistory.length > 10
        ? tradeHistory.sublist(tradeHistory.length - 10)
        : tradeHistory;

    return Column(
      children: recentTrades.map((trade) {
        final isWinning = trade['isWinning'] as bool;
        final profit = trade['profit'] as num;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(
              color: isWinning ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade['symbol'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trade['type']} • Vol: ${trade['volume']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${profit.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isWinning ? Colors.green : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWinning ? '✓ Win' : '✗ Loss',
                    style: TextStyle(
                      color: isWinning ? Colors.green : Colors.red,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
