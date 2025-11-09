// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaultItemModelAdapter extends TypeAdapter<VaultItemModel> {
  @override
  final int typeId = 5;

  @override
  VaultItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaultItemModel(
      id: fields[0] as String,
      itemType: fields[1] as String,
      encryptedFilePath: fields[2] as String,
      originalFileName: fields[3] as String?,
      thumbnailPath: fields[4] as String?,
      fileSizeBytes: fields[5] as int,
      addedAt: fields[6] as DateTime,
      lastAccessedAt: fields[7] as DateTime?,
      mimeType: fields[8] as String?,
      isFavorite: fields[9] as bool,
      category: fields[10] as String?,
      tags: (fields[11] as List).cast<String>(),
      isDecoy: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VaultItemModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemType)
      ..writeByte(2)
      ..write(obj.encryptedFilePath)
      ..writeByte(3)
      ..write(obj.originalFileName)
      ..writeByte(4)
      ..write(obj.thumbnailPath)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.addedAt)
      ..writeByte(7)
      ..write(obj.lastAccessedAt)
      ..writeByte(8)
      ..write(obj.mimeType)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.isDecoy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaultItemModel _$VaultItemModelFromJson(Map<String, dynamic> json) =>
    VaultItemModel(
      id: json['id'] as String,
      itemType: json['itemType'] as String,
      encryptedFilePath: json['encryptedFilePath'] as String,
      originalFileName: json['originalFileName'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      mimeType: json['mimeType'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isDecoy: json['isDecoy'] as bool? ?? false,
    );

Map<String, dynamic> _$VaultItemModelToJson(VaultItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemType': instance.itemType,
      'encryptedFilePath': instance.encryptedFilePath,
      'originalFileName': instance.originalFileName,
      'thumbnailPath': instance.thumbnailPath,
      'fileSizeBytes': instance.fileSizeBytes,
      'addedAt': instance.addedAt.toIso8601String(),
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'mimeType': instance.mimeType,
      'isFavorite': instance.isFavorite,
      'category': instance.category,
      'tags': instance.tags,
      'isDecoy': instance.isDecoy,
    };
