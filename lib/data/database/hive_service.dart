import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/cardio_model.dart';
import '../models/exercise_model.dart';
import '../models/weight_log_model.dart';
import '../models/measurement_model.dart';
import '../models/photo_log_model.dart';
import '../models/achievement_model.dart';
import '../models/streak_data_model.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static bool _isInitialized = false;

  // Initialize Hive and open all boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();

    _isInitialized = true;
  }

  // Register all Hive type adapters
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WorkoutModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WorkoutSetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CardioModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ExerciseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(WeightLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(MeasurementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PhotoLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(AchievementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(StreakDataModelAdapter());
    }
  }

  // Open all Hive boxes
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<UserModel>(AppConstants.userBox),
      Hive.openBox<WorkoutModel>(AppConstants.workoutBox),
      Hive.openBox<CardioModel>(AppConstants.cardioBox),
      Hive.openBox<ExerciseModel>(AppConstants.exerciseBox),
      Hive.openBox<WeightLogModel>(AppConstants.weightLogBox),
      Hive.openBox<MeasurementModel>(AppConstants.measurementBox),
      Hive.openBox<PhotoLogModel>(AppConstants.photoBox),
      Hive.openBox<AchievementModel>(AppConstants.achievementBox),
      Hive.openBox<StreakDataModel>(AppConstants.streakBox),
    ]);
  }

  // Box Getters
  static Box<UserModel> get userBox =>
      Hive.box<UserModel>(AppConstants.userBox);

  static Box<WorkoutModel> get workoutBox =>
      Hive.box<WorkoutModel>(AppConstants.workoutBox);

  static Box<CardioModel> get cardioBox =>
      Hive.box<CardioModel>(AppConstants.cardioBox);

  static Box<ExerciseModel> get exerciseBox =>
      Hive.box<ExerciseModel>(AppConstants.exerciseBox);

  static Box<WeightLogModel> get weightLogBox =>
      Hive.box<WeightLogModel>(AppConstants.weightLogBox);

  static Box<MeasurementModel> get measurementBox =>
      Hive.box<MeasurementModel>(AppConstants.measurementBox);

  static Box<PhotoLogModel> get photoBox =>
      Hive.box<PhotoLogModel>(AppConstants.photoBox);

  static Box<AchievementModel> get achievementBox =>
      Hive.box<AchievementModel>(AppConstants.achievementBox);

  static Box<StreakDataModel> get streakBox =>
      Hive.box<StreakDataModel>(AppConstants.streakBox);

  // Close all boxes (call on app dispose)
  static Future<void> closeAll() async {
    await Hive.close();
  }

  // Delete all data (for testing/reset)
  static Future<void> clearAll() async {
    await userBox.clear();
    await workoutBox.clear();
    await cardioBox.clear();
    await exerciseBox.clear();
    await weightLogBox.clear();
    await measurementBox.clear();
    await photoBox.clear();
    await achievementBox.clear();
    await streakBox.clear();
  }
}
