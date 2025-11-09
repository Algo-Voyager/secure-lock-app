import 'package:flutter/foundation.dart';
import '../../data/models/automation_rule_model.dart';
import '../../services/automation/automation_service.dart';

/// Provider for automation rules state
class AutomationProvider with ChangeNotifier {
  final AutomationService _automationService = AutomationService();

  List<AutomationRuleModel> _rules = [];
  bool _isLoading = false;
  String? _error;

  List<AutomationRuleModel> get rules => _rules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _automationService.initialize();
      await loadRules();
      _error = null;
    } catch (e) {
      _error = 'Error initializing automation: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all automation rules
  Future<void> loadRules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rules = await _automationService.getAllRules();
      _error = null;
    } catch (e) {
      _error = 'Error loading rules: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new automation rule
  Future<AutomationRuleModel?> addRule(AutomationRuleModel rule) async {
    try {
      final addedRule = await _automationService.addRule(rule);
      _rules.insert(0, addedRule);
      notifyListeners();
      return addedRule;
    } catch (e) {
      _error = 'Error adding rule: $e';
      debugPrint(_error);
      notifyListeners();
      return null;
    }
  }

  /// Update existing rule
  Future<bool> updateRule(AutomationRuleModel rule) async {
    try {
      await _automationService.updateRule(rule);
      final index = _rules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _rules[index] = rule;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error updating rule: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Delete rule
  Future<bool> deleteRule(String ruleId) async {
    try {
      await _automationService.deleteRule(ruleId);
      _rules.removeWhere((rule) => rule.id == ruleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting rule: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Toggle rule enabled status
  Future<void> toggleRuleEnabled(String ruleId) async {
    final rule = _rules.firstWhere((r) => r.id == ruleId);
    final updatedRule = rule.copyWith(isEnabled: !rule.isEnabled);
    await updateRule(updatedRule);
  }

  /// Get rules by type
  List<AutomationRuleModel> getRulesByType(String type) {
    return _rules.where((rule) => rule.ruleType == type).toList();
  }

  /// Evaluate all rules
  Future<List<AutomationRuleModel>> evaluateRules() async {
    return await _automationService.evaluateRules();
  }

  int get ruleCount => _rules.length;
  int get enabledRuleCount => _rules.where((r) => r.isEnabled).length;

  @override
  void dispose() {
    _automationService.dispose();
    super.dispose();
  }
}
