import 'package:hive/hive.dart';

part 'photo_log_model.g.dart';

@HiveType(typeId: 7)
class PhotoLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  // Absolute path to photo stored in app's document directory (safe storage)
  @HiveField(2)
  String localFilePath;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  DateTime createdAt;

  // Optional: photo type for categorization
  @HiveField(5)
  String photoType; // 'front', 'back', 'side', 'other'

  PhotoLogModel({
    required this.id,
    required this.date,
    required this.localFilePath,
    this.notes,
    required this.createdAt,
    this.photoType = 'front',
  });

  PhotoLogModel copyWith({
    String? id,
    DateTime? date,
    String? localFilePath,
    String? notes,
    DateTime? createdAt,
    String? photoType,
  }) {
    return PhotoLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      localFilePath: localFilePath ?? this.localFilePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      photoType: photoType ?? this.photoType,
    );
  }
}
