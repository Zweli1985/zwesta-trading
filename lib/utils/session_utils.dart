import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Call this in your catchError or API error handler when a 401/session expired is detected.
void handleSessionExpired(BuildContext context, {String? message}) {
  final authService = Provider.of<AuthService>(context, listen: false);
  authService.logout();
  // Show a dialog or snackbar
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Expired'),
        content: Text(message ?? 'Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  });
}
