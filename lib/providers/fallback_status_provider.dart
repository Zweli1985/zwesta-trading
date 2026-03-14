import 'package:flutter/foundation.dart';

class FallbackStatusProvider extends ChangeNotifier {
  bool _usingFallback = false;
  String? _fallbackReason;

  bool get usingFallback => _usingFallback;
  String? get fallbackReason => _fallbackReason;

  void setFallback({required String reason}) {
    _usingFallback = true;
    _fallbackReason = reason;
    notifyListeners();
  }

  void clearFallback() {
    _usingFallback = false;
    _fallbackReason = null;
    notifyListeners();
  }
}
