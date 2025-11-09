// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) =>
    UserSettingsModel(
      masterPasswordHash: json['masterPasswordHash'] as String?,
      pinCodeHash: json['pinCodeHash'] as String?,
      patternHash: json['patternHash'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      primaryAuthMethod: $enumDecodeNullable(
              _$AuthenticationMethodEnumMap, json['primaryAuthMethod']) ??
          AuthenticationMethod.pin,
      fallbackAuthMethod: $enumDecodeNullable(
          _$AuthenticationMethodEnumMap, json['fallbackAuthMethod']),
      maxFailedAttempts: (json['maxFailedAttempts'] as num?)?.toInt() ?? 3,
      intruderPhotoEnabled: json['intruderPhotoEnabled'] as bool? ?? true,
      autoLockDelay: (json['autoLockDelay'] as num?)?.toInt() ?? 5,
      serviceEnabled: json['serviceEnabled'] as bool? ?? true,
      showNotification: json['showNotification'] as bool? ?? true,
      vibrateOnAuth: json['vibrateOnAuth'] as bool? ?? true,
      soundOnAuth: json['soundOnAuth'] as bool? ?? false,
      recoveryEmail: json['recoveryEmail'] as String?,
      recoveryPhone: json['recoveryPhone'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserSettingsModelToJson(UserSettingsModel instance) =>
    <String, dynamic>{
      'masterPasswordHash': instance.masterPasswordHash,
      'pinCodeHash': instance.pinCodeHash,
      'patternHash': instance.patternHash,
      'biometricEnabled': instance.biometricEnabled,
      'primaryAuthMethod':
          _$AuthenticationMethodEnumMap[instance.primaryAuthMethod]!,
      'fallbackAuthMethod':
          _$AuthenticationMethodEnumMap[instance.fallbackAuthMethod],
      'maxFailedAttempts': instance.maxFailedAttempts,
      'intruderPhotoEnabled': instance.intruderPhotoEnabled,
      'autoLockDelay': instance.autoLockDelay,
      'serviceEnabled': instance.serviceEnabled,
      'showNotification': instance.showNotification,
      'vibrateOnAuth': instance.vibrateOnAuth,
      'soundOnAuth': instance.soundOnAuth,
      'recoveryEmail': instance.recoveryEmail,
      'recoveryPhone': instance.recoveryPhone,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AuthenticationMethodEnumMap = {
  AuthenticationMethod.pin: 'PIN',
  AuthenticationMethod.password: 'PASSWORD',
  AuthenticationMethod.pattern: 'PATTERN',
  AuthenticationMethod.biometric: 'BIOMETRIC',
};
