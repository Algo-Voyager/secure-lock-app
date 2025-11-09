import 'package:flutter/foundation.dart';

class FlowLogEntry {
  final String message;
  final DateTime timestamp;

  FlowLogEntry({required this.message, required this.timestamp});
}

class FlowLogProvider extends ChangeNotifier {
  static final FlowLogProvider _instance = FlowLogProvider._internal();
  factory FlowLogProvider() => _instance;
  FlowLogProvider._internal();

  final List<FlowLogEntry> _logs = [];
  static const int maxLogs = 100;

  List<FlowLogEntry> get logs => List.unmodifiable(_logs);

  void addLog(String message) {
    _logs.add(FlowLogEntry(
      message: message,
      timestamp: DateTime.now(),
    ));

    // Keep only last 100 logs
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}
