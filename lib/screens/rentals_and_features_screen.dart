import 'package:flutter/material.dart';

class RentalsAndFeaturesScreen extends StatefulWidget {
  const RentalsAndFeaturesScreen({Key? key}) : super(key: key);

  @override
  State<RentalsAndFeaturesScreen> createState() =>
      _RentalsAndFeaturesScreenState();
}

class _RentalsAndFeaturesScreenState extends State<RentalsAndFeaturesScreen> {
  final List<Map<String, dynamic>> _rentals = [
    {
      'id': 'R001',
      'name': 'Premium Bot License',
      'type': 'Bot',
      'price': 99.99,
      'daysRemaining': 30,
      'status': 'Active',
    },
    {
      'id': 'R002',
      'name': 'API Access - High Volume',
      'type': 'API',
      'price': 49.99,
      'daysRemaining': 15,
      'status': 'Active',
    },
    {
      'id': 'R003',
      'name': 'Advanced Analytics',
      'type': 'Feature',
      'price': 29.99,
      'daysRemaining': 0,
      'status': 'Expired',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals & Features'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Rentals
            Text(
              'Active Subscriptions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ..._rentals
                .where((r) => r['status'] == 'Active')
                .map(
                  (rental) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rental['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rental['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Type: ${rental['type']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '\$${rental['price']}/month',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Days Remaining: ${rental['daysRemaining']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: rental['daysRemaining'] < 10
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${rental['name']} renewed for another month!',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text('Renew'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 24),

            // Expired/Available Features
            Text(
              'Available Upgrades',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ..._rentals
                .where((r) => r['status'] == 'Expired')
                .map(
                  (rental) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rental['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Expired',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${rental['price']}/month',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${rental['name']} subscription activated!',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text('Subscribe'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
