import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../../data/models/automation_rule_model.dart';
import '../../core/services/storage_service.dart';
import 'location_service.dart';
import 'time_service.dart';
import 'wifi_service.dart';

/// Central service for managing automation rules
class AutomationService {
  final Logger _logger = Logger();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();
  final TimeService _timeService = TimeService();
  final WiFiService _wifiService = WiFiService();
  final _uuid = const Uuid();

  final List<AutomationRuleModel> _rules = [];
  Timer? _evaluationTimer;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _wifiSubscription;

  /// Initialize automation service
  Future<void> initialize() async {
    try {
      await _storageService.init();
      await loadRules();
      _startAutomationMonitoring();
      _logger.i('Automation service initialized with ${_rules.length} rules');
    } catch (e) {
      _logger.e('Error initializing automation service', error: e);
    }
  }

  /// Load all automation rules from storage
  Future<void> loadRules() async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      _rules.clear();
      _rules.addAll(box.values.where((rule) => rule.isEnabled));
    } catch (e) {
      _logger.e('Error loading automation rules', error: e);
    }
  }

  /// Add new automation rule
  Future<AutomationRuleModel> addRule(AutomationRuleModel rule) async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      await box.put(rule.id, rule);
      _rules.add(rule);
      _logger.i('Automation rule added: ${rule.name}');
      return rule;
    } catch (e) {
      _logger.e('Error adding automation rule', error: e);
      rethrow;
    }
  }

  /// Update existing automation rule
  Future<void> updateRule(AutomationRuleModel rule) async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      await box.put(rule.id, rule);

      final index = _rules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _rules[index] = rule;
      }

      _logger.i('Automation rule updated: ${rule.name}');
    } catch (e) {
      _logger.e('Error updating automation rule', error: e);
      rethrow;
    }
  }

  /// Delete automation rule
  Future<void> deleteRule(String ruleId) async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      await box.delete(ruleId);
      _rules.removeWhere((rule) => rule.id == ruleId);
      _logger.i('Automation rule deleted: $ruleId');
    } catch (e) {
      _logger.e('Error deleting automation rule', error: e);
      rethrow;
    }
  }

  /// Get all automation rules
  Future<List<AutomationRuleModel>> getAllRules() async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      return box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _logger.e('Error getting automation rules', error: e);
      return [];
    }
  }

  /// Evaluate all rules and return triggered rules
  Future<List<AutomationRuleModel>> evaluateRules() async {
    final triggeredRules = <AutomationRuleModel>[];

    for (final rule in _rules) {
      if (!rule.isEnabled) continue;

      bool shouldTrigger = false;

      switch (rule.ruleType) {
        case 'location':
          shouldTrigger = await _locationService.isInLocation(rule);
          break;
        case 'time':
          shouldTrigger = _timeService.isInTimeRange(rule);
          break;
        case 'wifi':
          shouldTrigger = await _wifiService.isConnectedToRuleWiFi(rule);
          break;
        case 'battery':
          // TODO: Implement battery-based rules
          break;
      }

      if (shouldTrigger) {
        triggeredRules.add(rule);
        _logger.i('Rule triggered: ${rule.name} (${rule.ruleType})');

        // Update last triggered time
        final updatedRule = rule.copyWith(lastTriggered: DateTime.now());
        await updateRule(updatedRule);
      }
    }

    return triggeredRules;
  }

  /// Start monitoring for automation triggers
  void _startAutomationMonitoring() {
    // Periodic evaluation every minute
    _evaluationTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await evaluateRules();
    });

    // Watch for location changes
    _locationSubscription = _locationService.watchPosition().listen((_) async {
      final locationRules = _rules.where((r) => r.ruleType == 'location');
      for (final rule in locationRules) {
        if (await _locationService.isInLocation(rule)) {
          _logger.i('Location rule triggered: ${rule.name}');
        }
      }
    });

    // Watch for WiFi changes
    _wifiSubscription = _wifiService.watchConnectivity().listen((result) async {
      final wifiRules = _rules.where((r) => r.ruleType == 'wifi');
      for (final rule in wifiRules) {
        if (await _wifiService.isConnectedToRuleWiFi(rule)) {
          _logger.i('WiFi rule triggered: ${rule.name}');
        }
      }
    });
  }

  /// Stop monitoring
  void dispose() {
    _evaluationTimer?.cancel();
    _locationSubscription?.cancel();
    _wifiSubscription?.cancel();
    _logger.i('Automation service disposed');
  }

  List<AutomationRuleModel> get rules => List.unmodifiable(_rules);
}
