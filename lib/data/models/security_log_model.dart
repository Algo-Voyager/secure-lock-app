import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_log_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class SecurityLogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String eventType; // 'unlock_success', 'unlock_fail', 'settings_change', 'app_locked', 'app_unlocked'

  @HiveField(3)
  final String? appPackageName;

  @HiveField(4)
  final String? appName;

  @HiveField(5)
  final String authMethod; // 'pin', 'password', 'pattern', 'biometric'

  @HiveField(6)
  final bool success;

  @HiveField(7)
  final String? details;

  @HiveField(8)
  final String? ipAddress;

  @HiveField(9)
  final String? deviceInfo;

  SecurityLogModel({
    required this.id,
    required this.timestamp,
    required this.eventType,
    this.appPackageName,
    this.appName,
    this.authMethod = 'pin',
    this.success = true,
    this.details,
    this.ipAddress,
    this.deviceInfo,
  });

  factory SecurityLogModel.fromJson(Map<String, dynamic> json) =>
      _$SecurityLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityLogModelToJson(this);

  SecurityLogModel copyWith({
    String? id,
    DateTime? timestamp,
    String? eventType,
    String? appPackageName,
    String? appName,
    String? authMethod,
    bool? success,
    String? details,
    String? ipAddress,
    String? deviceInfo,
  }) {
    return SecurityLogModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      eventType: eventType ?? this.eventType,
      appPackageName: appPackageName ?? this.appPackageName,
      appName: appName ?? this.appName,
      authMethod: authMethod ?? this.authMethod,
      success: success ?? this.success,
      details: details ?? this.details,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}
