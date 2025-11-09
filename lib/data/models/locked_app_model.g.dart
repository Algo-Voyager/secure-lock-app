// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locked_app_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LockedAppModel _$LockedAppModelFromJson(Map<String, dynamic> json) =>
    LockedAppModel(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      iconPath: json['iconPath'] as String?,
      isLocked: json['isLocked'] as bool? ?? true,
      lockedAt: DateTime.parse(json['lockedAt'] as String),
      unlockAttempts: (json['unlockAttempts'] as num?)?.toInt() ?? 0,
      lastUnlockAttempt: json['lastUnlockAttempt'] == null
          ? null
          : DateTime.parse(json['lastUnlockAttempt'] as String),
    );

Map<String, dynamic> _$LockedAppModelToJson(LockedAppModel instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'appName': instance.appName,
      'iconPath': instance.iconPath,
      'isLocked': instance.isLocked,
      'lockedAt': instance.lockedAt.toIso8601String(),
      'unlockAttempts': instance.unlockAttempts,
      'lastUnlockAttempt': instance.lastUnlockAttempt?.toIso8601String(),
    };
