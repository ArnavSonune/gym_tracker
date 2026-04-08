import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/hive_service.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/cardio_model.dart';
import '../models/weight_log_model.dart';
import '../models/measurement_model.dart';
import '../models/streak_data_model.dart';

class BackupService {
  // ── EXPORT ────────────────────────────────────────────────────────────────

  static Future<void> exportBackup() async {
    final data = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'user': _exportUser(),
      'workouts': _exportWorkouts(),
      'cardio': _exportCardio(),
      'weightLogs': _exportWeightLogs(),
      'measurements': _exportMeasurements(),
      'streak': _exportStreak(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final file = File('${dir.path}/hunter_backup_$timestamp.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'System: Hunter Backup',
    );
  }

  static Map<String, dynamic>? _exportUser() {
    final user = HiveService.userBox.get('current_user');
    if (user == null) return null;
    return {
      'id': user.id,
      'name': user.name,
      'totalXP': user.totalXP,
      'currentLevel': user.currentLevel,
      'createdAt': user.createdAt.toIso8601String(),
      'startingWeight': user.startingWeight,
      'targetWeight': user.targetWeight,
      'age': user.age,
      'heightCm': user.heightCm,
      'isMale': user.isMale,
      'gymExperienceLevel': user.gymExperienceLevel,
    };
  }

  static List<Map<String, dynamic>> _exportWorkouts() {
    return HiveService.workoutBox.values.map((w) => {
      'id': w.id,
      'date': w.date.toIso8601String(),
      'muscleGroup': w.muscleGroup,
      'exerciseName': w.exerciseName,
      'sets': w.sets.map((s) => {
        'setNumber': s.setNumber,
        'reps': s.reps,
        'weight': s.weight,
      }).toList(),
      'notes': w.notes,
      'xpEarned': w.xpEarned,
      'createdAt': w.createdAt.toIso8601String(),
    }).toList();
  }

  static List<Map<String, dynamic>> _exportCardio() {
    return HiveService.cardioBox.values.map((c) => {
      'id': c.id,
      'date': c.date.toIso8601String(),
      'cardioType': c.cardioType,
      'durationMinutes': c.durationMinutes,
      'distanceKm': c.distanceKm,
      'caloriesBurned': c.caloriesBurned,
      'notes': c.notes,
      'xpEarned': c.xpEarned,
      'createdAt': c.createdAt.toIso8601String(),
    }).toList();
  }

  static List<Map<String, dynamic>> _exportWeightLogs() {
    return HiveService.weightLogBox.values.map((w) => {
      'id': w.id,
      'date': w.date.toIso8601String(),
      'weightKg': w.weightKg,
      'notes': w.notes,
      'createdAt': w.createdAt.toIso8601String(),
    }).toList();
  }

  static List<Map<String, dynamic>> _exportMeasurements() {
    return HiveService.measurementBox.values.map((m) => {
      'id': m.id,
      'date': m.date.toIso8601String(),
      'chest': m.chest,
      'waist': m.waist,
      'shoulders': m.shoulders,
      'arms': m.arms,
      'forearms': m.forearms,
      'thighs': m.thighs,
      'calves': m.calves,
      'neck': m.neck,
      'bodyFatPercentage': m.bodyFatPercentage,
      'notes': m.notes,
      'createdAt': m.createdAt.toIso8601String(),
    }).toList();
  }

  static Map<String, dynamic> _exportStreak() {
    final streak = HiveService.streakBox.get('streak_data');
    if (streak == null) return {};
    return {
      'currentStreak': streak.currentStreak,
      'highestStreak': streak.highestStreak,
      'lastWorkoutDate': streak.lastWorkoutDate?.toIso8601String(),
      'workoutDates': streak.workoutDates,
    };
  }

  // ── IMPORT ────────────────────────────────────────────────────────────────

  static Future<String?> importBackup(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;

      // Version check
      final version = data['version'] as int? ?? 1;
      if (version > 1) return 'Backup version not supported';

      // Clear existing data (except achievements + exercises — keep seeded data)
      await HiveService.workoutBox.clear();
      await HiveService.cardioBox.clear();
      await HiveService.weightLogBox.clear();
      await HiveService.measurementBox.clear();
      await HiveService.streakBox.clear();

      // Restore user (preserve current passwordHash + isLoggedIn)
      if (data['user'] != null) {
        await _importUser(data['user'] as Map<String, dynamic>);
      }

      // Restore workouts
      if (data['workouts'] != null) {
        await _importWorkouts(data['workouts'] as List<dynamic>);
      }

      // Restore cardio
      if (data['cardio'] != null) {
        await _importCardio(data['cardio'] as List<dynamic>);
      }

      // Restore weight logs
      if (data['weightLogs'] != null) {
        await _importWeightLogs(data['weightLogs'] as List<dynamic>);
      }

      // Restore measurements
      if (data['measurements'] != null) {
        await _importMeasurements(data['measurements'] as List<dynamic>);
      }

      // Restore streak
      if (data['streak'] != null) {
        await _importStreak(data['streak'] as Map<String, dynamic>);
      }

      return null; // null = success
    } catch (e) {
      return 'Invalid backup file: $e';
    }
  }

  static Future<void> _importUser(Map<String, dynamic> u) async {
    final existing = HiveService.userBox.get('current_user');
    final user = UserModel(
      id: u['id'] as String,
      name: u['name'] as String,
      totalXP: u['totalXP'] as int,
      currentLevel: u['currentLevel'] as int,
      createdAt: DateTime.parse(u['createdAt'] as String),
      startingWeight: (u['startingWeight'] as num?)?.toDouble(),
      targetWeight: (u['targetWeight'] as num?)?.toDouble(),
      age: u['age'] as int?,
      heightCm: (u['heightCm'] as num?)?.toDouble(),
      isMale: u['isMale'] as bool? ?? true,
      gymExperienceLevel: u['gymExperienceLevel'] as int? ?? 0,
      // Preserve auth from existing account
      passwordHash: existing?.passwordHash,
      isLoggedIn: true,
      profilePhotoPath: existing?.profilePhotoPath,
    );
    await HiveService.userBox.put('current_user', user);
  }

  static Future<void> _importWorkouts(List<dynamic> list) async {
    for (final item in list) {
      final w = item as Map<String, dynamic>;
      final sets = (w['sets'] as List<dynamic>).map((s) {
        final setMap = s as Map<String, dynamic>;
        return WorkoutSetModel(
          setNumber: setMap['setNumber'] as int,
          reps: setMap['reps'] as int,
          weight: (setMap['weight'] as num).toDouble(),
        );
      }).toList();

      final workout = WorkoutModel(
        id: w['id'] as String,
        date: DateTime.parse(w['date'] as String),
        muscleGroup: w['muscleGroup'] as String,
        exerciseName: w['exerciseName'] as String,
        sets: sets,
        notes: w['notes'] as String?,
        xpEarned: w['xpEarned'] as int? ?? 0,
        createdAt: DateTime.parse(w['createdAt'] as String),
      );
      await HiveService.workoutBox.put(workout.id, workout);
    }
  }

  static Future<void> _importCardio(List<dynamic> list) async {
    for (final item in list) {
      final c = item as Map<String, dynamic>;
      final cardio = CardioModel(
        id: c['id'] as String,
        date: DateTime.parse(c['date'] as String),
        cardioType: c['cardioType'] as String,
        durationMinutes: c['durationMinutes'] as int,
        distanceKm: (c['distanceKm'] as num?)?.toDouble(),
        caloriesBurned: c['caloriesBurned'] as int?,
        notes: c['notes'] as String?,
        xpEarned: c['xpEarned'] as int? ?? 0,
        createdAt: DateTime.parse(c['createdAt'] as String),
      );
      await HiveService.cardioBox.put(cardio.id, cardio);
    }
  }

  static Future<void> _importWeightLogs(List<dynamic> list) async {
    for (final item in list) {
      final w = item as Map<String, dynamic>;
      final log = WeightLogModel(
        id: w['id'] as String,
        date: DateTime.parse(w['date'] as String),
        weightKg: (w['weightKg'] as num).toDouble(),
        notes: w['notes'] as String?,
        createdAt: DateTime.parse(w['createdAt'] as String),
      );
      await HiveService.weightLogBox.put(log.id, log);
    }
  }

  static Future<void> _importMeasurements(List<dynamic> list) async {
    for (final item in list) {
      final m = item as Map<String, dynamic>;
      final measurement = MeasurementModel(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        chest: (m['chest'] as num?)?.toDouble(),
        waist: (m['waist'] as num?)?.toDouble(),
        shoulders: (m['shoulders'] as num?)?.toDouble(),
        arms: (m['arms'] as num?)?.toDouble(),
        forearms: (m['forearms'] as num?)?.toDouble(),
        thighs: (m['thighs'] as num?)?.toDouble(),
        calves: (m['calves'] as num?)?.toDouble(),
        neck: (m['neck'] as num?)?.toDouble(),
        bodyFatPercentage: (m['bodyFatPercentage'] as num?)?.toDouble(),
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
      await HiveService.measurementBox.put(measurement.id, measurement);
    }
  }

  static Future<void> _importStreak(Map<String, dynamic> s) async {
    final streak = StreakDataModel(
      currentStreak: s['currentStreak'] as int? ?? 0,
      highestStreak: s['highestStreak'] as int? ?? 0,
      lastWorkoutDate: s['lastWorkoutDate'] != null
          ? DateTime.parse(s['lastWorkoutDate'] as String)
          : null,
      workoutDates: (s['workoutDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
    await HiveService.streakBox.put('streak_data', streak);
  }
}
