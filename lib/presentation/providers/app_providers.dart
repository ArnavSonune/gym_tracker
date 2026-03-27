import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/cardio_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/weight_log_model.dart';
import '../../data/models/measurement_model.dart';
import '../../data/models/photo_log_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/streak_data_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/cardio_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/weight_repository.dart';
import '../../data/repositories/measurement_repository.dart';
import '../../data/repositories/photo_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../core/constants/app_constants.dart';

// ─── REPOSITORY PROVIDERS (Singletons) ───────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((_) => UserRepository());
final workoutRepositoryProvider = Provider<WorkoutRepository>((_) => WorkoutRepository());
final cardioRepositoryProvider = Provider<CardioRepository>((_) => CardioRepository());
final exerciseRepositoryProvider = Provider<ExerciseRepository>((_) => ExerciseRepository());
final weightRepositoryProvider = Provider<WeightRepository>((_) => WeightRepository());
final measurementRepositoryProvider = Provider<MeasurementRepository>((_) => MeasurementRepository());
final photoRepositoryProvider = Provider<PhotoRepository>((_) => PhotoRepository());
final achievementRepositoryProvider = Provider<AchievementRepository>((_) => AchievementRepository());
final streakRepositoryProvider = Provider<StreakRepository>((_) => StreakRepository());

// ─── USER PROVIDER ────────────────────────────────────────────────────────────

class UserNotifier extends StateNotifier<UserModel?> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.getUser();
  }

  Future<void> createUser(String name) async {
    await _repository.createUser(name);
    state = _repository.getUser();
  }

  Future<void> updateName(String name) async {
    final user = state;
    if (user == null) return;
    final updated = user.copyWith(name: name);
    await _repository.updateUser(updated);
    state = updated;
  }

  Future<void> updateProfile({
    double? startingWeight,
    double? targetWeight,
    int? age,
    double? heightCm,
    bool? isMale,
    int? gymExperienceLevel,
  }) async {
    final user = state;
    if (user == null) return;
    final updated = user.copyWith(
      startingWeight: startingWeight,
      targetWeight: targetWeight,
      age: age,
      heightCm: heightCm,
      isMale: isMale,
      gymExperienceLevel: gymExperienceLevel,
    );
    await _repository.updateUser(updated);
    state = updated;
  }

  Future<void> updateExperienceLevel(int level) async {
    final user = state;
    if (user == null) return;
    final updated = user.copyWith(gymExperienceLevel: level);
    await _repository.updateUser(updated);
    state = updated;
  }

  Future<void> updateProfilePhoto(String? path) async {
    final user = state;
    if (user == null) return;
    final updated = path == null
        ? user.copyWith(clearProfilePhoto: true)
        : user.copyWith(profilePhotoPath: path);
    await _repository.updateUser(updated);
    state = updated;
  }

  Future<bool> addXPAndCheckLevelUp(int xp) async {
    final user = state;
    if (user == null) return false;
    final oldXP = user.totalXP;
    await _repository.addXP(xp);
    state = _repository.getUser();
    return _repository.didLevelUp(oldXP, state?.totalXP ?? oldXP);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
  (ref) => UserNotifier(ref.watch(userRepositoryProvider)),
);

// ─── WORKOUT PROVIDER ─────────────────────────────────────────────────────────

class WorkoutNotifier extends StateNotifier<List<WorkoutModel>> {
  final WorkoutRepository _repository;

  WorkoutNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllWorkouts();
  }

  Future<WorkoutModel> addWorkout({
    required DateTime date,
    required String muscleGroup,
    required String exerciseName,
    required List<WorkoutSetModel> sets,
    String? notes,
  }) async {
    final workout = await _repository.addWorkout(
      date: date,
      muscleGroup: muscleGroup,
      exerciseName: exerciseName,
      sets: sets,
      notes: notes,
    );
    _load();
    return workout;
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    await _repository.updateWorkout(workout);
    _load();
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _repository.deleteWorkout(workoutId);
    _load();
  }

  List<WorkoutModel> getByMuscle(String muscle) =>
      _repository.getWorkoutsByMuscleGroup(muscle);

  List<WorkoutModel> getByExercise(String exercise) =>
      _repository.getWorkoutsByExercise(exercise);

  List<WorkoutModel> search(String query) =>
      _repository.searchWorkouts(query);

  int get totalWorkouts => _repository.getTotalWorkoutsCount();
  int get totalSets => _repository.getTotalSetsCount();
  double get totalVolume => _repository.getTotalVolume();
  int get workoutsThisWeek => _repository.getWorkoutsThisWeek();
  Map<DateTime, double> get weeklyVolumeByDay => _repository.getWeeklyVolumeByDay();
  Map<String, int> get muscleGroupDistribution => _repository.getMuscleGroupDistribution();
  Map<String, int> get muscleGroupDaysSinceLastTrained =>
      _repository.getMuscleGroupDaysSinceLastTrained();
  
  // Muscle group stats
  Map<String, dynamic> getMuscleGroupStats(String muscleGroup) =>
      _repository.getMuscleGroupStats(muscleGroup);
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, List<WorkoutModel>>(
  (ref) => WorkoutNotifier(ref.watch(workoutRepositoryProvider)),
);

// ─── CARDIO PROVIDER ──────────────────────────────────────────────────────────

class CardioNotifier extends StateNotifier<List<CardioModel>> {
  final CardioRepository _repository;

  CardioNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllCardio();
  }

  Future<CardioModel> addCardio({
    required DateTime date,
    required String cardioType,
    required int durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
    String? notes,
  }) async {
    final cardio = await _repository.addCardio(
      date: date,
      cardioType: cardioType,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      caloriesBurned: caloriesBurned,
      notes: notes,
    );
    _load();
    return cardio;
  }

  Future<void> updateCardio(CardioModel cardio) async {
    await _repository.updateCardio(cardio);
    _load();
  }

  Future<void> deleteCardio(String cardioId) async {
    await _repository.deleteCardio(cardioId);
    _load();
  }

  int get totalCardio => _repository.getTotalCardioCount();
  int get totalMinutes => _repository.getTotalCardioMinutes();
  double get totalDistance => _repository.getTotalCardioDistance();
}

final cardioProvider =
    StateNotifierProvider<CardioNotifier, List<CardioModel>>(
  (ref) => CardioNotifier(ref.watch(cardioRepositoryProvider)),
);

// ─── EXERCISE PROVIDER ────────────────────────────────────────────────────────

class ExerciseNotifier extends StateNotifier<List<ExerciseModel>> {
  final ExerciseRepository _repository;

  ExerciseNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllExercises();
  }

  List<ExerciseModel> search(String query) => _repository.searchExercises(query);

  List<ExerciseModel> getByMuscle(String muscle) =>
      _repository.getExercisesByMuscleGroup(muscle);

  List<ExerciseModel> getMostUsed({int limit = 5}) =>
      _repository.getMostUsedExercises(limit: limit);
}

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, List<ExerciseModel>>(
  (ref) => ExerciseNotifier(ref.watch(exerciseRepositoryProvider)),
);

// ─── WEIGHT PROVIDER ──────────────────────────────────────────────────────────

class WeightNotifier extends StateNotifier<List<WeightLogModel>> {
  final WeightRepository _repository;

  WeightNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllWeightLogs();
  }

  Future<void> addWeightLog({
    required DateTime date,
    required double weightKg,
    String? notes,
  }) async {
    await _repository.addWeightLog(
      date: date,
      weightKg: weightKg,
      notes: notes,
    );
    _load();
  }

  Future<void> updateWeightLog(WeightLogModel log) async {
    await _repository.updateWeightLog(log);
    _load();
  }

  Future<void> deleteWeightLog(String logId) async {
    await _repository.deleteWeightLog(logId);
    _load();
  }

  double? get currentWeight => _repository.getCurrentWeight();
  double? get startingWeight => _repository.getStartingWeight();
  double? get totalWeightChange => _repository.getTotalWeightChange();
  double? get weeklyAverageChange => _repository.getWeeklyAverageChange();
  double? get weightChangeLast7Days => _repository.getWeightChangeLast7Days();
}

final weightProvider =
    StateNotifierProvider<WeightNotifier, List<WeightLogModel>>(
  (ref) => WeightNotifier(ref.watch(weightRepositoryProvider)),
);

// ─── MEASUREMENT PROVIDER ─────────────────────────────────────────────────────

class MeasurementNotifier extends StateNotifier<List<MeasurementModel>> {
  final MeasurementRepository _repository;

  MeasurementNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllMeasurements();
  }

  Future<void> addMeasurement({
    required DateTime date,
    double? chest,
    double? waist,
    double? shoulders,
    double? arms,
    double? forearms,
    double? thighs,
    double? calves,
    double? neck,
    double? bodyFatPercentage,
    String? notes,
  }) async {
    await _repository.addMeasurement(
      date: date,
      chest: chest,
      waist: waist,
      shoulders: shoulders,
      arms: arms,
      forearms: forearms,
      thighs: thighs,
      calves: calves,
      neck: neck,
      bodyFatPercentage: bodyFatPercentage,
      notes: notes,
    );
    _load();
  }

  Future<void> deleteMeasurement(String id) async {
    await _repository.deleteMeasurement(id);
    _load();
  }

  MeasurementModel? get latest => _repository.getLatestMeasurement();
}

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, List<MeasurementModel>>(
  (ref) => MeasurementNotifier(ref.watch(measurementRepositoryProvider)),
);

// ─── PHOTO PROVIDER ───────────────────────────────────────────────────────────

class PhotoNotifier extends StateNotifier<List<PhotoLogModel>> {
  final PhotoRepository _repository;

  PhotoNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllPhotos();
  }

  Future<PhotoLogModel?> addPhoto({
    required String sourcePath,
    required DateTime date,
    String photoType = 'front',
    String? notes,
  }) async {
    final photo = await _repository.addPhoto(
      sourcePath: sourcePath,
      date: date,
      photoType: photoType,
      notes: notes,
    );
    _load();
    return photo;
  }

  Future<void> deletePhoto(String photoId) async {
    await _repository.deletePhoto(photoId);
    _load();
  }

  int get totalPhotos => _repository.getTotalPhotosCount();
}

final photoProvider =
    StateNotifierProvider<PhotoNotifier, List<PhotoLogModel>>(
  (ref) => PhotoNotifier(ref.watch(photoRepositoryProvider)),
);

// ─── ACHIEVEMENT PROVIDER ─────────────────────────────────────────────────────

class AchievementNotifier extends StateNotifier<List<AchievementModel>> {
  final AchievementRepository _repository;

  AchievementNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAllAchievements();
  }

  /// Attempt to unlock — returns the unlocked achievement or null.
  Future<AchievementModel?> tryUnlock(String achievementId) async {
    final unlocked = await _repository.unlockAchievement(achievementId);
    if (unlocked != null) _load();
    return unlocked;
  }

  int get unlockedCount => _repository.getUnlockedCount();
  int get totalCount => _repository.getTotalCount();
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<AchievementModel>>(
  (ref) => AchievementNotifier(ref.watch(achievementRepositoryProvider)),
);

// ─── STREAK PROVIDER ──────────────────────────────────────────────────────────

class StreakNotifier extends StateNotifier<StreakDataModel> {
  final StreakRepository _repository;

  StreakNotifier(this._repository) : super(StreakDataModel()) {
    _load();
  }

  void _load() {
    state = _repository.getStreakData();
  }

  Future<void> recordWorkout(DateTime date) async {
    state = await _repository.recordWorkoutDay(date);
  }

  Future<void> checkStreak() async {
    state = await _repository.checkAndUpdateStreak();
  }

  bool get workedOutToday => _repository.hadWorkoutToday();
  int get currentStreak => state.currentStreak;
  int get highestStreak => state.highestStreak;
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakDataModel>(
  (ref) => StreakNotifier(ref.watch(streakRepositoryProvider)),
);

// ─── DASHBOARD INSIGHTS PROVIDER ──────────────────────────────────────────────

final dashboardInsightsProvider = Provider<List<String>>((ref) {
  final workoutNotifier = ref.watch(workoutProvider.notifier);
  final insights = <String>[];

  // Muscles not trained recently
  final daysMap = workoutNotifier.muscleGroupDaysSinceLastTrained;
  for (final entry in daysMap.entries) {
    if (entry.value >= 9) {
      insights.add(
          'System Alert: ${entry.key} not trained for ${entry.value} days.');
    }
  }

  // Low workout frequency
  final thisWeek = workoutNotifier.workoutsThisWeek;
  if (thisWeek == 0) {
    insights.add('System Alert: No workouts logged this week, Hunter.');
  } else if (thisWeek >= 5) {
    insights.add('System: Excellent training frequency this week!');
  }

  if (insights.isEmpty) {
    insights.add('System: All parameters nominal. Keep pushing, Hunter.');
  }

  return insights;
});

// ─── SELECTED CHART RANGE PROVIDER ────────────────────────────────────────────

final selectedChartRangeProvider = StateProvider<String>(
  (_) => AppConstants.chartRanges[1], // Default: Month
);

// ─── WORKOUT FILTER PROVIDER ──────────────────────────────────────────────────

final workoutMuscleFilterProvider = StateProvider<String?>((_) => null);
final workoutSearchQueryProvider = StateProvider<String>((_) => '');

final filteredWorkoutsProvider = Provider<List<WorkoutModel>>((ref) {
  final workouts = ref.watch(workoutProvider);
  final muscleFilter = ref.watch(workoutMuscleFilterProvider);
  final searchQuery = ref.watch(workoutSearchQueryProvider);

  var filtered = workouts;

  if (muscleFilter != null && muscleFilter.isNotEmpty) {
    filtered = filtered
        .where((w) => w.muscleGroup == muscleFilter)
        .toList();
  }

  if (searchQuery.isNotEmpty) {
    final lower = searchQuery.toLowerCase();
    filtered = filtered
        .where((w) =>
            w.exerciseName.toLowerCase().contains(lower) ||
            w.muscleGroup.toLowerCase().contains(lower))
        .toList();
  }

  return filtered;
});