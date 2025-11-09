// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intruder_photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntruderPhotoModelAdapter extends TypeAdapter<IntruderPhotoModel> {
  @override
  final int typeId = 2;

  @override
  IntruderPhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntruderPhotoModel(
      id: fields[0] as String,
      photoPath: fields[1] as String,
      timestamp: fields[2] as DateTime,
      appPackageName: fields[3] as String,
      appName: fields[4] as String,
      failedAttempts: fields[5] as int,
      location: fields[6] as String?,
      latitude: fields[7] as String?,
      longitude: fields[8] as String?,
      attemptType: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IntruderPhotoModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.appPackageName)
      ..writeByte(4)
      ..write(obj.appName)
      ..writeByte(5)
      ..write(obj.failedAttempts)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.attemptType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntruderPhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntruderPhotoModel _$IntruderPhotoModelFromJson(Map<String, dynamic> json) =>
    IntruderPhotoModel(
      id: json['id'] as String,
      photoPath: json['photoPath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      appPackageName: json['appPackageName'] as String,
      appName: json['appName'] as String,
      failedAttempts: (json['failedAttempts'] as num).toInt(),
      location: json['location'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      attemptType: json['attemptType'] as String? ?? 'pin',
    );

Map<String, dynamic> _$IntruderPhotoModelToJson(IntruderPhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photoPath': instance.photoPath,
      'timestamp': instance.timestamp.toIso8601String(),
      'appPackageName': instance.appPackageName,
      'appName': instance.appName,
      'failedAttempts': instance.failedAttempts,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'attemptType': instance.attemptType,
    };
