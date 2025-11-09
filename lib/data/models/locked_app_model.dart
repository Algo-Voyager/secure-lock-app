import 'package:json_annotation/json_annotation.dart';

part 'locked_app_model.g.dart';

/// Model representing a locked application
@JsonSerializable()
class LockedAppModel {
  final String packageName;
  final String appName;
  final String? iconPath;
  final bool isLocked;
  final DateTime lockedAt;
  final int unlockAttempts;
  final DateTime? lastUnlockAttempt;

  const LockedAppModel({
    required this.packageName,
    required this.appName,
    this.iconPath,
    this.isLocked = true,
    required this.lockedAt,
    this.unlockAttempts = 0,
    this.lastUnlockAttempt,
  });

  factory LockedAppModel.fromJson(Map<String, dynamic> json) =>
      _$LockedAppModelFromJson(json);

  Map<String, dynamic> toJson() => _$LockedAppModelToJson(this);

  LockedAppModel copyWith({
    String? packageName,
    String? appName,
    String? iconPath,
    bool? isLocked,
    DateTime? lockedAt,
    int? unlockAttempts,
    DateTime? lastUnlockAttempt,
  }) {
    return LockedAppModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconPath: iconPath ?? this.iconPath,
      isLocked: isLocked ?? this.isLocked,
      lockedAt: lockedAt ?? this.lockedAt,
      unlockAttempts: unlockAttempts ?? this.unlockAttempts,
      lastUnlockAttempt: lastUnlockAttempt ?? this.lastUnlockAttempt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockedAppModel &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}

/// Simple app info model (for app selection)
class AppInfo {
  final String packageName;
  final String appName;
  final String? icon;
  final bool isSystemApp;

  const AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
    this.isSystemApp = false,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      icon: json['icon'] as String?,
      isSystemApp: json['isSystemApp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'icon': icon,
      'isSystemApp': isSystemApp,
    };
  }
}
