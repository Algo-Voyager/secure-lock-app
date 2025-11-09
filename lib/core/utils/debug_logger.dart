import 'package:flutter/foundation.dart';

/// Debug logger that stores logs for in-app viewing
class DebugLogger extends ChangeNotifier {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 500;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String message, {LogLevel level = LogLevel.info, String? tag}) {
    final entry = LogEntry(
      message: message,
      level: level,
      tag: tag,
      timestamp: DateTime.now(),
    );

    _logs.insert(0, entry);

    // Keep only the latest logs
    if (_logs.length > _maxLogs) {
      _logs.removeRange(_maxLogs, _logs.length);
    }

    // Print to console as well
    final prefix = _getLevelPrefix(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('$prefix $tagStr$message');

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.success:
        return '✅';
    }
  }
}

class LogEntry {
  final String message;
  final LogLevel level;
  final String? tag;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    this.tag,
    required this.timestamp,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
  success,
}
