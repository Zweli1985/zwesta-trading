import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MultiAccountManagementScreen extends StatefulWidget {
  const MultiAccountManagementScreen({Key? key}) : super(key: key);

  @override
  State<MultiAccountManagementScreen> createState() =>
      _MultiAccountManagementScreenState();
}

class _MultiAccountManagementScreenState
    extends State<MultiAccountManagementScreen> {
  final String _apiUrl = 'http://127.0.0.1:9000';

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _availableBrokers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers
  late TextEditingController _accountIdController;
  late TextEditingController _accountNumberController;
  late TextEditingController _passwordController;
  late TextEditingController _serverController;

  String? _selectedBroker;

  @override
  void initState() {
    super.initState();
    _accountIdController = TextEditingController();
    _accountNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _serverController = TextEditingController();

    _loadAccounts();
    _loadBrokers();
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _accountNumberController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$_apiUrl/api/accounts/list'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _accounts = List<Map<String, dynamic>>.from(data['accounts'] ?? []);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load accounts';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBrokers() async {
    try {
      final response = await http
          .get(Uri.parse('$_apiUrl/api/brokers/list'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _availableBrokers =
              List<Map<String, dynamic>>.from(data['brokers'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading brokers: $e');
    }
  }

  Future<void> _addAccount() async {
    if (_accountIdController.text.isEmpty ||
        _selectedBroker == null ||
        _accountNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/accounts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accountId': _accountIdController.text,
          'brokerType': _selectedBroker,
          'credentials': {
            'account': int.tryParse(_accountNumberController.text),
            'password': _passwordController.text,
            'server': _serverController.text,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account added successfully')),
          );
          _accountIdController.clear();
          _accountNumberController.clear();
          _passwordController.clear();
          _serverController.clear();
          setState(() {
            _selectedBroker = null;
          });
          _loadAccounts();
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'Failed to add account';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectAccount(String accountId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(Uri.parse('$_apiUrl/api/accounts/connect/$accountId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to $accountId')),
        );
        _loadAccounts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trading Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _accountIdController,
                decoration: const InputDecoration(
                  labelText: 'Account ID (nickname)',
                  hintText: 'e.g., My MT5 Account',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBroker,
                items: _availableBrokers
                    .map((b) => DropdownMenuItem<String>(
                          value: b['type'] as String,
                          child: Text(b['name'] as String),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBroker = value),
                decoration: const InputDecoration(labelText: 'Broker'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'e.g., 136372035',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Server',
                  hintText: 'e.g., MetaQuotes-Demo',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addAccount,
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Account Management'),
        elevation: 0,
      ),
      body: _isLoading && _accounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddAccountDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Trading Account'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_accounts.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No accounts added yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first trading account to get started',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._accounts.map((account) => _buildAccountCard(account)),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final isConnected = account['connected'] ?? false;
    final info = account['info'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account['accountId'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Broker: ${account['broker'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (info != null) ...[
              _buildInfoRow('Account #', info['accountNumber']?.toString()),
              _buildInfoRow('Balance', '\$${info['balance']?.toStringAsFixed(2)}'),
              _buildInfoRow('Equity', '\$${info['equity']?.toStringAsFixed(2)}'),
              _buildInfoRow('Currency', info['currency']),
              _buildInfoRow('Leverage', '1:${info['leverage']}'),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isConnected
                  ? null
                  : () => _connectAccount(account['accountId']),
              icon: Icon(isConnected ? Icons.check_circle : Icons.link),
              label: Text(isConnected ? 'Connected' : 'Connect Account'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
