import '../models/exercise_model.dart';
import '../database/hive_service.dart';

class ExerciseRepository {

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<ExerciseModel> getAllExercises() {
    return HiveService.exerciseBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ExerciseModel> getExercisesByMuscleGroup(String muscleGroup) {
    return HiveService.exerciseBox.values
        .where((e) => e.muscleGroup == muscleGroup)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ExerciseModel> searchExercises(String query) {
    final lower = query.toLowerCase();
    return HiveService.exerciseBox.values
        .where((e) =>
            e.name.toLowerCase().contains(lower) ||
            e.muscleGroup.toLowerCase().contains(lower))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  ExerciseModel? getExerciseByName(String name) {
    try {
      return HiveService.exerciseBox.values.firstWhere(
        (e) => e.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  ExerciseModel? getExerciseById(String id) {
    return HiveService.exerciseBox.get(id);
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateExercise(ExerciseModel exercise) async {
    await HiveService.exerciseBox.put(exercise.id, exercise);
  }

  // ─── DELETE (custom exercises only) ─────────────────────────────────────

  Future<void> deleteExercise(String exerciseId) async {
    final exercise = HiveService.exerciseBox.get(exerciseId);
    if (exercise != null && exercise.isCustom) {
      await HiveService.exerciseBox.delete(exerciseId);
    }
  }

  // ─── PROGRESS DATA FOR CHARTS ─────────────────────────────────────────────

  /// Get time-series data for an exercise (weight over time)
  List<Map<String, dynamic>> getExerciseWeightProgress(
    String exerciseName, {
    DateTime? startDate,
  }) {
    final workouts = HiveService.workoutBox.values
        .where((w) =>
            w.exerciseName.toLowerCase() == exerciseName.toLowerCase() &&
            (startDate == null || w.date.isAfter(startDate)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return workouts.map((w) => {
      'date': w.date,
      'value': w.maxWeight,
    }).toList();
  }

  /// Get time-series data for volume progress
  List<Map<String, dynamic>> getExerciseVolumeProgress(
    String exerciseName, {
    DateTime? startDate,
  }) {
    final workouts = HiveService.workoutBox.values
        .where((w) =>
            w.exerciseName.toLowerCase() == exerciseName.toLowerCase() &&
            (startDate == null || w.date.isAfter(startDate)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return workouts.map((w) => {
      'date': w.date,
      'value': w.totalVolume,
    }).toList();
  }

  /// Get time-series data for reps progress (max reps in a set)
  List<Map<String, dynamic>> getExerciseRepsProgress(
    String exerciseName, {
    DateTime? startDate,
  }) {
    final workouts = HiveService.workoutBox.values
        .where((w) =>
            w.exerciseName.toLowerCase() == exerciseName.toLowerCase() &&
            (startDate == null || w.date.isAfter(startDate)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return workouts.map((w) => {
      'date': w.date,
      'value': w.sets.isEmpty
          ? 0
          : w.sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b),
    }).toList();
  }

  /// Most used exercises (by session count)
  List<ExerciseModel> getMostUsedExercises({int limit = 5}) {
    final exercises = HiveService.exerciseBox.values.toList()
      ..sort((a, b) => b.totalSessions.compareTo(a.totalSessions));
    return exercises.take(limit).toList();
  }

  /// Most used exercises for a specific muscle group
  List<String> getMostUsedExercisesForMuscle(String muscleGroup, {int limit = 3}) {
    final workouts = HiveService.workoutBox.values
        .where((w) => w.muscleGroup == muscleGroup)
        .toList();

    final Map<String, int> exerciseCount = {};
    for (final w in workouts) {
      exerciseCount[w.exerciseName] =
          (exerciseCount[w.exerciseName] ?? 0) + 1;
    }

    return exerciseCount.entries
        .toList()
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(limit)
        .map((e) => e.key)
        .toList();
  }
}

// Extension for List sorting
extension ListSort<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final copy = List<T>.from(this);
    copy.sort(compare);
    return copy;
  }
}
