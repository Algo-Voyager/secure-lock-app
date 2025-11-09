import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'automation_rule_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class AutomationRuleModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String ruleType; // 'location', 'time', 'wifi', 'battery'

  @HiveField(3)
  final bool isEnabled;

  @HiveField(4)
  final String action; // 'unlock_all', 'lock_all', 'unlock_specific', 'lock_specific'

  @HiveField(5)
  final List<String> targetApps; // Package names

  // Location-based fields
  @HiveField(6)
  final String? locationName;

  @HiveField(7)
  final double? latitude;

  @HiveField(8)
  final double? longitude;

  @HiveField(9)
  final double? radiusMeters;

  // Time-based fields
  @HiveField(10)
  final String? startTime; // HH:mm format

  @HiveField(11)
  final String? endTime; // HH:mm format

  @HiveField(12)
  final List<int>? daysOfWeek; // 1-7 (Monday-Sunday)

  // WiFi-based fields
  @HiveField(13)
  final String? wifiSSID;

  @HiveField(14)
  final String? wifiBSSID;

  // Battery-based fields
  @HiveField(15)
  final int? batteryLevelThreshold;

  @HiveField(16)
  final String? batteryCondition; // 'below', 'above'

  @HiveField(17)
  final DateTime createdAt;

  @HiveField(18)
  final DateTime? lastTriggered;

  AutomationRuleModel({
    required this.id,
    required this.name,
    required this.ruleType,
    this.isEnabled = true,
    this.action = 'unlock_all',
    this.targetApps = const [],
    this.locationName,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.startTime,
    this.endTime,
    this.daysOfWeek,
    this.wifiSSID,
    this.wifiBSSID,
    this.batteryLevelThreshold,
    this.batteryCondition,
    required this.createdAt,
    this.lastTriggered,
  });

  factory AutomationRuleModel.fromJson(Map<String, dynamic> json) =>
      _$AutomationRuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$AutomationRuleModelToJson(this);

  AutomationRuleModel copyWith({
    String? id,
    String? name,
    String? ruleType,
    bool? isEnabled,
    String? action,
    List<String>? targetApps,
    String? locationName,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? startTime,
    String? endTime,
    List<int>? daysOfWeek,
    String? wifiSSID,
    String? wifiBSSID,
    int? batteryLevelThreshold,
    String? batteryCondition,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return AutomationRuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ruleType: ruleType ?? this.ruleType,
      isEnabled: isEnabled ?? this.isEnabled,
      action: action ?? this.action,
      targetApps: targetApps ?? this.targetApps,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      wifiSSID: wifiSSID ?? this.wifiSSID,
      wifiBSSID: wifiBSSID ?? this.wifiBSSID,
      batteryLevelThreshold: batteryLevelThreshold ?? this.batteryLevelThreshold,
      batteryCondition: batteryCondition ?? this.batteryCondition,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
}
