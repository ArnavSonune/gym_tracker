import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../database/hive_service.dart';
import '../database/database_helper.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

class WorkoutRepository {
  static const _uuid = Uuid();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<WorkoutModel> addWorkout({
    required DateTime date,
    required String muscleGroup,
    required String exerciseName,
    required List<WorkoutSetModel> sets,
    String? notes,
  }) async {
    // True total volume = sum of (reps × weight) across every set
    final trueVolume = sets.fold(0.0, (sum, s) => sum + (s.reps * s.weight));

    // Apply experience multiplier from user profile
    final user = DatabaseHelper.getCurrentUser();
    final expLevel = user?.gymExperienceLevel ?? 0;
    final expMultiplier = AppConstants.gymExperienceXpMultipliers[
        expLevel.clamp(0, AppConstants.gymExperienceXpMultipliers.length - 1)];

    final xp = AppUtils.calculateStrengthXP(
      sets: sets.length,
      totalReps: sets.fold(0, (sum, s) => sum + s.reps),
      totalVolume: trueVolume,
      experienceMultiplier: expMultiplier,
    );

    final workout = WorkoutModel(
      id: _uuid.v4(),
      date: date,
      muscleGroup: muscleGroup,
      exerciseName: exerciseName,
      sets: sets,
      notes: notes,
      xpEarned: xp,
      createdAt: DateTime.now(),
    );

    await HiveService.workoutBox.put(workout.id, workout);
    await _updateExerciseStats(exerciseName, muscleGroup, workout);

    return workout;
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<WorkoutModel> getAllWorkouts() {
    return HiveService.workoutBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutModel> getWorkoutsByDateRange(DateTime start, DateTime end) {
    return HiveService.workoutBox.values
        .where((w) =>
            w.date.isAfter(start.subtract(const Duration(days: 1))) &&
            w.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutModel> getWorkoutsForDate(DateTime date) {
    return HiveService.workoutBox.values
        .where((w) => AppUtils.isSameDay(w.date, date))
        .toList();
  }

  List<WorkoutModel> getWorkoutsByMuscleGroup(String muscleGroup) {
    return HiveService.workoutBox.values
        .where((w) => w.muscleGroup == muscleGroup)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<WorkoutModel> getWorkoutsByExercise(String exerciseName) {
    return HiveService.workoutBox.values
        .where((w) => w.exerciseName.toLowerCase() == exerciseName.toLowerCase())
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // oldest first for charts
  }

  List<WorkoutModel> searchWorkouts(String query) {
    final lower = query.toLowerCase();
    return HiveService.workoutBox.values
        .where((w) =>
            w.exerciseName.toLowerCase().contains(lower) ||
            w.muscleGroup.toLowerCase().contains(lower))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateWorkout(WorkoutModel workout) async {
    await HiveService.workoutBox.put(workout.id, workout);
    await _updateExerciseStats(
        workout.exerciseName, workout.muscleGroup, workout);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteWorkout(String workoutId) async {
    await HiveService.workoutBox.delete(workoutId);
  }

  // ─── ANALYTICS ────────────────────────────────────────────────────────────

  /// Total number of workouts logged
  int getTotalWorkoutsCount() => HiveService.workoutBox.length;

  /// Total sets ever performed
  int getTotalSetsCount() {
    return HiveService.workoutBox.values
        .fold(0, (sum, w) => sum + w.totalSets);
  }

  /// Total volume ever lifted (kg)
  double getTotalVolume() {
    return HiveService.workoutBox.values
        .fold(0.0, (sum, w) => sum + w.totalVolume);
  }

  /// Workouts per week (last 7 days)
  int getWorkoutsThisWeek() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return HiveService.workoutBox.values
        .where((w) => w.date.isAfter(weekAgo))
        .length;
  }

  /// Weekly volume grouped by day (for bar chart)
  Map<DateTime, double> getWeeklyVolumeByDay() {
    final Map<DateTime, double> result = {};
    final weekAgo = DateTime.now().subtract(const Duration(days: 6));

    // Initialize all 7 days with 0
    for (int i = 0; i < 7; i++) {
      final day = AppUtils.getDateOnly(weekAgo.add(Duration(days: i)));
      result[day] = 0;
    }

    for (final workout in HiveService.workoutBox.values) {
      final day = AppUtils.getDateOnly(workout.date);
      if (result.containsKey(day)) {
        result[day] = (result[day] ?? 0) + workout.totalVolume;
      }
    }

    return result;
  }

  /// Muscle group distribution (for pie chart)
  Map<String, int> getMuscleGroupDistribution() {
    final Map<String, int> result = {};
    for (final workout in HiveService.workoutBox.values) {
      result[workout.muscleGroup] =
          (result[workout.muscleGroup] ?? 0) + 1;
    }
    return result;
  }

  /// Days since each muscle group was last trained
  Map<String, int> getMuscleGroupDaysSinceLastTrained() {
    final Map<String, DateTime> lastTrained = {};
    final now = DateTime.now();

    for (final workout in HiveService.workoutBox.values) {
      final existing = lastTrained[workout.muscleGroup];
      if (existing == null || workout.date.isAfter(existing)) {
        lastTrained[workout.muscleGroup] = workout.date;
      }
    }

    return lastTrained.map((muscle, date) =>
        MapEntry(muscle, AppUtils.daysBetween(date, now)));
  }

  /// Get muscle groups not trained in last N days
  List<String> getMuscleGroupsNotTrainedInDays(int days) {
    final daysMap = getMuscleGroupDaysSinceLastTrained();
    return daysMap.entries
        .where((e) => e.value >= days)
        .map((e) => e.key)
        .toList();
  }

  /// Stats for a specific muscle group
  Map<String, dynamic> getMuscleGroupStats(String muscleGroup) {
    final workouts = getWorkoutsByMuscleGroup(muscleGroup);
    final totalVolume =
        workouts.fold(0.0, (sum, w) => sum + w.totalVolume);
    final lastTrained =
        workouts.isEmpty ? null : workouts.first.date;

    // Weekly frequency (last 4 weeks)
    final fourWeeksAgo =
        DateTime.now().subtract(const Duration(days: 28));
    final recentWorkouts =
        workouts.where((w) => w.date.isAfter(fourWeeksAgo)).length;
    final weeklyFrequency = recentWorkouts / 4.0;

    return {
      'totalWorkouts': workouts.length,
      'totalVolume': totalVolume,
      'lastTrained': lastTrained,
      'weeklyFrequency': weeklyFrequency,
    };
  }

  // ─── PRIVATE HELPERS ──────────────────────────────────────────────────────

  /// Update exercise PR and stats after a workout is logged
  Future<void> _updateExerciseStats(
    String exerciseName,
    String muscleGroup,
    WorkoutModel workout,
  ) async {
    final exerciseBox = HiveService.exerciseBox;

    // Find existing exercise
    ExerciseModel? exercise;
    for (final e in exerciseBox.values) {
      if (e.name.toLowerCase() == exerciseName.toLowerCase()) {
        exercise = e;
        break;
      }
    }

    exercise ??= ExerciseModel(
        id: _uuid.v4(),
        name: exerciseName,
        muscleGroup: muscleGroup,
        isCustom: true,
        createdAt: DateTime.now(),
      );

    // Check for new PR
    final isPR = workout.maxWeight > exercise.prWeight;
    final isBestVolume = workout.totalVolume > exercise.bestVolume;

    final updated = exercise.copyWith(
      prWeight: isPR ? workout.maxWeight : exercise.prWeight,
      prAchievedDate: isPR ? workout.date : exercise.prAchievedDate,
      bestVolume:
          isBestVolume ? workout.totalVolume : exercise.bestVolume,
      bestVolumeDate:
          isBestVolume ? workout.date : exercise.bestVolumeDate,
      lastPerformed: workout.date,
      totalSessions: exercise.totalSessions + 1,
    );

    await exerciseBox.put(updated.id, updated);
  }
}