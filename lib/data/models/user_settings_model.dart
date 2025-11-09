import 'package:json_annotation/json_annotation.dart';

part 'user_settings_model.g.dart';

/// Authentication method enum
enum AuthenticationMethod {
  @JsonValue('PIN')
  pin,
  @JsonValue('PASSWORD')
  password,
  @JsonValue('PATTERN')
  pattern,
  @JsonValue('BIOMETRIC')
  biometric,
}

/// User settings model
@JsonSerializable()
class UserSettingsModel {
  final String? masterPasswordHash;
  final String? pinCodeHash;
  final String? patternHash;
  final bool biometricEnabled;
  final AuthenticationMethod primaryAuthMethod;
  final AuthenticationMethod? fallbackAuthMethod;
  final int maxFailedAttempts;
  final bool intruderPhotoEnabled;
  final int autoLockDelay; // in seconds
  final bool serviceEnabled;
  final bool showNotification;
  final bool vibrateOnAuth;
  final bool soundOnAuth;
  final String? recoveryEmail;
  final String? recoveryPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSettingsModel({
    this.masterPasswordHash,
    this.pinCodeHash,
    this.patternHash,
    this.biometricEnabled = false,
    this.primaryAuthMethod = AuthenticationMethod.pin,
    this.fallbackAuthMethod,
    this.maxFailedAttempts = 3,
    this.intruderPhotoEnabled = true,
    this.autoLockDelay = 5,
    this.serviceEnabled = true,
    this.showNotification = true,
    this.vibrateOnAuth = true,
    this.soundOnAuth = false,
    this.recoveryEmail,
    this.recoveryPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsModelToJson(this);

  UserSettingsModel copyWith({
    String? masterPasswordHash,
    String? pinCodeHash,
    String? patternHash,
    bool? biometricEnabled,
    AuthenticationMethod? primaryAuthMethod,
    AuthenticationMethod? fallbackAuthMethod,
    int? maxFailedAttempts,
    bool? intruderPhotoEnabled,
    int? autoLockDelay,
    bool? serviceEnabled,
    bool? showNotification,
    bool? vibrateOnAuth,
    bool? soundOnAuth,
    String? recoveryEmail,
    String? recoveryPhone,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      masterPasswordHash: masterPasswordHash ?? this.masterPasswordHash,
      pinCodeHash: pinCodeHash ?? this.pinCodeHash,
      patternHash: patternHash ?? this.patternHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      primaryAuthMethod: primaryAuthMethod ?? this.primaryAuthMethod,
      fallbackAuthMethod: fallbackAuthMethod ?? this.fallbackAuthMethod,
      maxFailedAttempts: maxFailedAttempts ?? this.maxFailedAttempts,
      intruderPhotoEnabled: intruderPhotoEnabled ?? this.intruderPhotoEnabled,
      autoLockDelay: autoLockDelay ?? this.autoLockDelay,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      showNotification: showNotification ?? this.showNotification,
      vibrateOnAuth: vibrateOnAuth ?? this.vibrateOnAuth,
      soundOnAuth: soundOnAuth ?? this.soundOnAuth,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      recoveryPhone: recoveryPhone ?? this.recoveryPhone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get hasPassword => masterPasswordHash != null;
  bool get hasPin => pinCodeHash != null;
  bool get hasPattern => patternHash != null;
  bool get isConfigured => hasPassword || hasPin || hasPattern;
}
