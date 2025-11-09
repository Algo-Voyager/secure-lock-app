// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_rule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutomationRuleModelAdapter extends TypeAdapter<AutomationRuleModel> {
  @override
  final int typeId = 4;

  @override
  AutomationRuleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutomationRuleModel(
      id: fields[0] as String,
      name: fields[1] as String,
      ruleType: fields[2] as String,
      isEnabled: fields[3] as bool,
      action: fields[4] as String,
      targetApps: (fields[5] as List).cast<String>(),
      locationName: fields[6] as String?,
      latitude: fields[7] as double?,
      longitude: fields[8] as double?,
      radiusMeters: fields[9] as double?,
      startTime: fields[10] as String?,
      endTime: fields[11] as String?,
      daysOfWeek: (fields[12] as List?)?.cast<int>(),
      wifiSSID: fields[13] as String?,
      wifiBSSID: fields[14] as String?,
      batteryLevelThreshold: fields[15] as int?,
      batteryCondition: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      lastTriggered: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AutomationRuleModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ruleType)
      ..writeByte(3)
      ..write(obj.isEnabled)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.targetApps)
      ..writeByte(6)
      ..write(obj.locationName)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.radiusMeters)
      ..writeByte(10)
      ..write(obj.startTime)
      ..writeByte(11)
      ..write(obj.endTime)
      ..writeByte(12)
      ..write(obj.daysOfWeek)
      ..writeByte(13)
      ..write(obj.wifiSSID)
      ..writeByte(14)
      ..write(obj.wifiBSSID)
      ..writeByte(15)
      ..write(obj.batteryLevelThreshold)
      ..writeByte(16)
      ..write(obj.batteryCondition)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.lastTriggered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomationRuleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutomationRuleModel _$AutomationRuleModelFromJson(Map<String, dynamic> json) =>
    AutomationRuleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ruleType: json['ruleType'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      action: json['action'] as String? ?? 'unlock_all',
      targetApps: (json['targetApps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      wifiSSID: json['wifiSSID'] as String?,
      wifiBSSID: json['wifiBSSID'] as String?,
      batteryLevelThreshold: (json['batteryLevelThreshold'] as num?)?.toInt(),
      batteryCondition: json['batteryCondition'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastTriggered: json['lastTriggered'] == null
          ? null
          : DateTime.parse(json['lastTriggered'] as String),
    );

Map<String, dynamic> _$AutomationRuleModelToJson(
        AutomationRuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ruleType': instance.ruleType,
      'isEnabled': instance.isEnabled,
      'action': instance.action,
      'targetApps': instance.targetApps,
      'locationName': instance.locationName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'daysOfWeek': instance.daysOfWeek,
      'wifiSSID': instance.wifiSSID,
      'wifiBSSID': instance.wifiBSSID,
      'batteryLevelThreshold': instance.batteryLevelThreshold,
      'batteryCondition': instance.batteryCondition,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastTriggered': instance.lastTriggered?.toIso8601String(),
    };
