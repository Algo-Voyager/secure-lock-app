import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'intruder_photo_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class IntruderPhotoModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String photoPath;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String appPackageName;

  @HiveField(4)
  final String appName;

  @HiveField(5)
  final int failedAttempts;

  @HiveField(6)
  final String? location;

  @HiveField(7)
  final String? latitude;

  @HiveField(8)
  final String? longitude;

  @HiveField(9)
  final String attemptType; // 'pin', 'password', 'pattern', 'biometric'

  IntruderPhotoModel({
    required this.id,
    required this.photoPath,
    required this.timestamp,
    required this.appPackageName,
    required this.appName,
    required this.failedAttempts,
    this.location,
    this.latitude,
    this.longitude,
    this.attemptType = 'pin',
  });

  factory IntruderPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$IntruderPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntruderPhotoModelToJson(this);

  IntruderPhotoModel copyWith({
    String? id,
    String? photoPath,
    DateTime? timestamp,
    String? appPackageName,
    String? appName,
    int? failedAttempts,
    String? location,
    String? latitude,
    String? longitude,
    String? attemptType,
  }) {
    return IntruderPhotoModel(
      id: id ?? this.id,
      photoPath: photoPath ?? this.photoPath,
      timestamp: timestamp ?? this.timestamp,
      appPackageName: appPackageName ?? this.appPackageName,
      appName: appName ?? this.appName,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      attemptType: attemptType ?? this.attemptType,
    );
  }
}
