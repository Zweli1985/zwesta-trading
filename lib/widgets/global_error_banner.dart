import 'package:flutter/material.dart';

class GlobalErrorBanner extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool show;

  const GlobalErrorBanner({
    Key? key,
    required this.errorMessage,
    this.onRetry,
    this.show = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show || errorMessage == null || errorMessage!.isEmpty) return SizedBox.shrink();
    return MaterialBanner(
      content: Text(errorMessage!, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red[800],
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
