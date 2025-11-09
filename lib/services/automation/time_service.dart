import 'package:logger/logger.dart';
import '../../data/models/automation_rule_model.dart';

/// Service for time-based automation
class TimeService {
  final Logger _logger = Logger();

  /// Check if current time matches a time-based rule
  bool isInTimeRange(AutomationRuleModel rule) {
    if (rule.startTime == null || rule.endTime == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      final startTime = _parseTime(rule.startTime!);
      final endTime = _parseTime(rule.endTime!);

      if (startTime == null || endTime == null) {
        return false;
      }

      // Check day of week if specified
      if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty) {
        final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
        if (!rule.daysOfWeek!.contains(currentDayOfWeek)) {
          return false;
        }
      }

      // Compare times
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      // Handle time ranges that cross midnight
      if (endMinutes < startMinutes) {
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      } else {
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      }
    } catch (e) {
      _logger.e('Error checking time range', error: e);
      return false;
    }
  }

  /// Parse time string in HH:mm format
  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      _logger.e('Error parsing time: $timeStr', error: e);
      return null;
    }
  }

  /// Format time for display
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get day name from day number (1-7)
  String getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (day < 1 || day > 7) return 'Unknown';
    return days[day - 1];
  }

  /// Get current day of week (1-7)
  int getCurrentDayOfWeek() {
    return DateTime.now().weekday;
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
