import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_log_model.dart';
import '../database/hive_service.dart';

class PhotoRepository {
  static const _uuid = Uuid();

  /// Safe photo directory inside app's document storage
  static Future<Directory> getPhotoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/gym_photos');
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    return photoDir;
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Save photo from gallery/camera to safe app storage and log it
  Future<PhotoLogModel?> addPhoto({
    required String sourcePath,
    required DateTime date,
    String photoType = 'front',
    String? notes,
  }) async {
    try {
      final photoDir = await getPhotoDirectory();
      final fileName = '${_uuid.v4()}.jpg';
      final destinationPath = '${photoDir.path}/$fileName';

      // Copy photo to app's document directory (safe storage)
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      final photoLog = PhotoLogModel(
        id: _uuid.v4(),
        date: date,
        localFilePath: destinationPath,
        notes: notes,
        createdAt: DateTime.now(),
        photoType: photoType,
      );

      await HiveService.photoBox.put(photoLog.id, photoLog);
      return photoLog;
    } catch (e) {
      return null;
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<PhotoLogModel> getAllPhotos() {
    return HiveService.photoBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<PhotoLogModel> getPhotosForDate(DateTime date) {
    return HiveService.photoBox.values
        .where((p) =>
            p.date.year == date.year &&
            p.date.month == date.month &&
            p.date.day == date.day)
        .toList();
  }

  PhotoLogModel? getLatestPhoto() {
    if (HiveService.photoBox.isEmpty) return null;
    return HiveService.photoBox.values
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  PhotoLogModel? getEarliestPhoto() {
    if (HiveService.photoBox.isEmpty) return null;
    return HiveService.photoBox.values
        .reduce((a, b) => a.date.isBefore(b.date) ? a : b);
  }

  int getTotalPhotosCount() => HiveService.photoBox.length;

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updatePhoto(PhotoLogModel photo) async {
    await HiveService.photoBox.put(photo.id, photo);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Delete photo log AND the actual file from storage
  Future<void> deletePhoto(String photoId) async {
    final photo = HiveService.photoBox.get(photoId);
    if (photo != null) {
      // Delete physical file
      final file = File(photo.localFilePath);
      if (await file.exists()) {
        await file.delete();
      }
      // Delete from database
      await HiveService.photoBox.delete(photoId);
    }
  }

  /// Check if photo file still exists on disk
  Future<bool> photoFileExists(String photoId) async {
    final photo = HiveService.photoBox.get(photoId);
    if (photo == null) return false;
    return File(photo.localFilePath).exists();
  }
}
