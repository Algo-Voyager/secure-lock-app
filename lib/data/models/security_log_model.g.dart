// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecurityLogModelAdapter extends TypeAdapter<SecurityLogModel> {
  @override
  final int typeId = 3;

  @override
  SecurityLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecurityLogModel(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      eventType: fields[2] as String,
      appPackageName: fields[3] as String?,
      appName: fields[4] as String?,
      authMethod: fields[5] as String,
      success: fields[6] as bool,
      details: fields[7] as String?,
      ipAddress: fields[8] as String?,
      deviceInfo: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SecurityLogModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.eventType)
      ..writeByte(3)
      ..write(obj.appPackageName)
      ..writeByte(4)
      ..write(obj.appName)
      ..writeByte(5)
      ..write(obj.authMethod)
      ..writeByte(6)
      ..write(obj.success)
      ..writeByte(7)
      ..write(obj.details)
      ..writeByte(8)
      ..write(obj.ipAddress)
      ..writeByte(9)
      ..write(obj.deviceInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityLogModel _$SecurityLogModelFromJson(Map<String, dynamic> json) =>
    SecurityLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      eventType: json['eventType'] as String,
      appPackageName: json['appPackageName'] as String?,
      appName: json['appName'] as String?,
      authMethod: json['authMethod'] as String? ?? 'pin',
      success: json['success'] as bool? ?? true,
      details: json['details'] as String?,
      ipAddress: json['ipAddress'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
    );

Map<String, dynamic> _$SecurityLogModelToJson(SecurityLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'eventType': instance.eventType,
      'appPackageName': instance.appPackageName,
      'appName': instance.appName,
      'authMethod': instance.authMethod,
      'success': instance.success,
      'details': instance.details,
      'ipAddress': instance.ipAddress,
      'deviceInfo': instance.deviceInfo,
    };
