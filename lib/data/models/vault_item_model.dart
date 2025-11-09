import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vault_item_model.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class VaultItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemType; // 'photo', 'video', 'file'

  @HiveField(2)
  final String encryptedFilePath;

  @HiveField(3)
  final String? originalFileName;

  @HiveField(4)
  final String? thumbnailPath;

  @HiveField(5)
  final int fileSizeBytes;

  @HiveField(6)
  final DateTime addedAt;

  @HiveField(7)
  final DateTime? lastAccessedAt;

  @HiveField(8)
  final String? mimeType;

  @HiveField(9)
  final bool isFavorite;

  @HiveField(10)
  final String? category; // 'personal', 'work', 'documents', etc.

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final bool isDecoy; // If true, this item belongs to the fake vault

  VaultItemModel({
    required this.id,
    required this.itemType,
    required this.encryptedFilePath,
    this.originalFileName,
    this.thumbnailPath,
    required this.fileSizeBytes,
    required this.addedAt,
    this.lastAccessedAt,
    this.mimeType,
    this.isFavorite = false,
    this.category,
    this.tags = const [],
    this.isDecoy = false,
  });

  factory VaultItemModel.fromJson(Map<String, dynamic> json) =>
      _$VaultItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$VaultItemModelToJson(this);

  VaultItemModel copyWith({
    String? id,
    String? itemType,
    String? encryptedFilePath,
    String? originalFileName,
    String? thumbnailPath,
    int? fileSizeBytes,
    DateTime? addedAt,
    DateTime? lastAccessedAt,
    String? mimeType,
    bool? isFavorite,
    String? category,
    List<String>? tags,
    bool? isDecoy,
  }) {
    return VaultItemModel(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      encryptedFilePath: encryptedFilePath ?? this.encryptedFilePath,
      originalFileName: originalFileName ?? this.originalFileName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      addedAt: addedAt ?? this.addedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      mimeType: mimeType ?? this.mimeType,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isDecoy: isDecoy ?? this.isDecoy,
    );
  }

  String get displayName => originalFileName ?? 'Unknown';

  bool get isPhoto => itemType == 'photo';
  bool get isVideo => itemType == 'video';
  bool get isFile => itemType == 'file';
}
