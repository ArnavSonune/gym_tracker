import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise_model.dart';
import '../models/achievement_model.dart';
import '../models/streak_data_model.dart';
import '../models/user_model.dart';
import 'hive_service.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static const _uuid = Uuid();

  // ── Password hashing ────────────────────────────────────────────────────────
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── Auth: register a brand-new account ─────────────────────────────────────
  static Future<String?> registerUser({
    required String username,
    required String password,
  }) async {
    final box = HiveService.userBox;

    // Username must be unique
    final existing = box.values.cast<UserModel?>().firstWhere(
          (u) => u?.name.toLowerCase() == username.trim().toLowerCase(),
          orElse: () => null,
        );
    if (existing != null) return 'Username already taken';

    if (username.trim().length < 3) return 'Username must be at least 3 characters';
    if (password.length < 6) return 'Password must be at least 6 characters';

    final user = UserModel(
      id: _uuid.v4(),
      name: username.trim(),
      totalXP: 0,
      currentLevel: 1,
      createdAt: DateTime.now(),
      isMale: true,
      passwordHash: _hashPassword(password),
      isLoggedIn: true,
    );
    await box.put('current_user', user);
    return null; // null = success
  }

  // ── Auth: log in to an existing account ────────────────────────────────────
  static Future<String?> loginUser({
    required String username,
    required String password,
  }) async {
    final box = HiveService.userBox;
    final user = box.values.cast<UserModel?>().firstWhere(
          (u) => u?.name.toLowerCase() == username.trim().toLowerCase(),
          orElse: () => null,
        );

    if (user == null) return 'No account found with that username';
    if (user.passwordHash == null) {
      // Legacy account created before auth was added — set the password now
      final updated = user.copyWith(
        passwordHash: _hashPassword(password),
        isLoggedIn: true,
      );
      await box.put('current_user', updated);
      return null;
    }
    if (user.passwordHash != _hashPassword(password)) return 'Incorrect password';

    final updated = user.copyWith(isLoggedIn: true);
    await box.put('current_user', updated);
    return null; // null = success
  }

  // ── Auth: log out (keeps data, clears session flag) ────────────────────────
  static Future<void> logoutUser() async {
    final user = getCurrentUser();
    if (user == null) return;
    final updated = user.copyWith(isLoggedIn: false);
    await HiveService.userBox.put('current_user', updated);
  }

  // ── Auth: check if a valid logged-in session exists ────────────────────────
  static bool isLoggedIn() {
    final user = getCurrentUser();
    return user != null && user.isLoggedIn;
  }

  // Run on first app launch to seed default data
  static Future<void> seedDefaultDataIfNeeded() async {
    await _seedDefaultExercises();
    await _seedDefaultAchievements();
    await _seedStreakData();
  }

  // Create a default user profile
  static Future<void> createDefaultUser(String name) async {
    final box = HiveService.userBox;
    if (box.isEmpty) {
      final user = UserModel(
        id: _uuid.v4(),
        name: name,
        totalXP: 0,
        currentLevel: 1,
        createdAt: DateTime.now(),
        isMale: true,
      );
      await box.put('current_user', user);
    }
  }

  // Get current user
  static UserModel? getCurrentUser() {
    return HiveService.userBox.get('current_user');
  }

  // Update current user
  static Future<void> updateUser(UserModel user) async {
    await HiveService.userBox.put('current_user', user);
  }

  // Seed default exercises per muscle group
  static Future<void> _seedDefaultExercises() async {
    final box = HiveService.exerciseBox;
    if (box.isNotEmpty) return; // Already seeded

    final defaultExercises = _getDefaultExercises();
    final now = DateTime.now();

    for (final exercise in defaultExercises) {
      final model = ExerciseModel(
        id: _uuid.v4(),
        name: exercise['name']!,
        muscleGroup: exercise['muscleGroup']!,
        isCustom: false,
        createdAt: now,
      );
      await box.put(model.id, model);
    }
  }

  // Seed default achievements (all locked initially)
  static Future<void> _seedDefaultAchievements() async {
    final box = HiveService.achievementBox;
    if (box.isNotEmpty) return; // Already seeded

    final achievements = _getDefaultAchievements();
    for (final achievement in achievements) {
      await box.put(achievement.id, achievement);
    }
  }

  // Seed initial streak data
  static Future<void> _seedStreakData() async {
    final box = HiveService.streakBox;
    if (box.isEmpty) {
      final streakData = StreakDataModel(
        currentStreak: 0,
        highestStreak: 0,
      );
      await box.put('streak_data', streakData);
    }
  }

  // Get streak data
  static StreakDataModel getStreakData() {
    return HiveService.streakBox.get('streak_data') ??
        StreakDataModel(currentStreak: 0, highestStreak: 0);
  }

  // Update streak data
  static Future<void> updateStreakData(StreakDataModel data) async {
    await HiveService.streakBox.put('streak_data', data);
  }

  // ─── DEFAULT EXERCISE LIST ─────────────────────────────────────────────────

  static List<Map<String, String>> _getDefaultExercises() {
    return [
      // Chest
      {'name': 'Bench Press', 'muscleGroup': 'Chest'},
      {'name': 'Incline Bench Press', 'muscleGroup': 'Chest'},
      {'name': 'Decline Bench Press', 'muscleGroup': 'Chest'},
      {'name': 'Dumbbell Flyes', 'muscleGroup': 'Chest'},
      {'name': 'Cable Flyes', 'muscleGroup': 'Chest'},
      {'name': 'Push-ups', 'muscleGroup': 'Chest'},
      {'name': 'Dips (Chest)', 'muscleGroup': 'Chest'},
      {'name': 'Pec Deck Machine', 'muscleGroup': 'Chest'},

      // Back
      {'name': 'Deadlift', 'muscleGroup': 'Back'},
      {'name': 'Pull-ups', 'muscleGroup': 'Lats'},
      {'name': 'Lat Pulldown', 'muscleGroup': 'Lats'},
      {'name': 'Bent Over Row', 'muscleGroup': 'Back'},
      {'name': 'Seated Cable Row', 'muscleGroup': 'Back'},
      {'name': 'Single Arm Dumbbell Row', 'muscleGroup': 'Back'},
      {'name': 'T-Bar Row', 'muscleGroup': 'Back'},
      {'name': 'Face Pulls', 'muscleGroup': 'Rear Delts'},
      {'name': 'Good Mornings', 'muscleGroup': 'Lower Back'},
      {'name': 'Hyperextensions', 'muscleGroup': 'Lower Back'},
      {'name': 'Shrugs', 'muscleGroup': 'Traps'},

      // Shoulders
      {'name': 'Overhead Press', 'muscleGroup': 'Shoulders'},
      {'name': 'Dumbbell Shoulder Press', 'muscleGroup': 'Shoulders'},
      {'name': 'Lateral Raises', 'muscleGroup': 'Shoulders'},
      {'name': 'Front Raises', 'muscleGroup': 'Shoulders'},
      {'name': 'Arnold Press', 'muscleGroup': 'Shoulders'},
      {'name': 'Upright Row', 'muscleGroup': 'Shoulders'},

      // Biceps
      {'name': 'Barbell Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Dumbbell Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Hammer Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Incline Dumbbell Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Cable Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Preacher Curl', 'muscleGroup': 'Biceps'},
      {'name': 'Concentration Curl', 'muscleGroup': 'Biceps'},

      // Triceps
      {'name': 'Tricep Pushdown', 'muscleGroup': 'Triceps'},
      {'name': 'Skull Crushers', 'muscleGroup': 'Triceps'},
      {'name': 'Overhead Tricep Extension', 'muscleGroup': 'Triceps'},
      {'name': 'Close-grip Bench Press', 'muscleGroup': 'Triceps'},
      {'name': 'Dips (Triceps)', 'muscleGroup': 'Triceps'},
      {'name': 'Tricep Kickbacks', 'muscleGroup': 'Triceps'},

      // Forearms
      {'name': 'Wrist Curls', 'muscleGroup': 'Forearms'},
      {'name': 'Reverse Wrist Curls', 'muscleGroup': 'Forearms'},
      {'name': 'Farmer\'s Walk', 'muscleGroup': 'Forearms'},

      // Abs
      {'name': 'Crunches', 'muscleGroup': 'Abs'},
      {'name': 'Plank', 'muscleGroup': 'Abs'},
      {'name': 'Leg Raises', 'muscleGroup': 'Abs'},
      {'name': 'Cable Crunches', 'muscleGroup': 'Abs'},
      {'name': 'Ab Wheel Rollout', 'muscleGroup': 'Abs'},
      {'name': 'Russian Twists', 'muscleGroup': 'Obliques'},
      {'name': 'Side Plank', 'muscleGroup': 'Obliques'},

      // Quads
      {'name': 'Squat', 'muscleGroup': 'Quads'},
      {'name': 'Front Squat', 'muscleGroup': 'Quads'},
      {'name': 'Leg Press', 'muscleGroup': 'Quads'},
      {'name': 'Leg Extension', 'muscleGroup': 'Quads'},
      {'name': 'Lunges', 'muscleGroup': 'Quads'},
      {'name': 'Bulgarian Split Squat', 'muscleGroup': 'Quads'},
      {'name': 'Hack Squat', 'muscleGroup': 'Quads'},
      {'name': 'Wall Sit', 'muscleGroup': 'Quads'},

      // Hamstrings
      {'name': 'Romanian Deadlift', 'muscleGroup': 'Hamstrings'},
      {'name': 'Leg Curl', 'muscleGroup': 'Hamstrings'},
      {'name': 'Stiff-Leg Deadlift', 'muscleGroup': 'Hamstrings'},
      {'name': 'Nordic Curl', 'muscleGroup': 'Hamstrings'},

      // Glutes
      {'name': 'Hip Thrust', 'muscleGroup': 'Glutes'},
      {'name': 'Glute Bridge', 'muscleGroup': 'Glutes'},
      {'name': 'Cable Kickbacks', 'muscleGroup': 'Glutes'},
      {'name': 'Sumo Squat', 'muscleGroup': 'Glutes'},

      // Calves
      {'name': 'Standing Calf Raises', 'muscleGroup': 'Calves'},
      {'name': 'Seated Calf Raises', 'muscleGroup': 'Calves'},
      {'name': 'Donkey Calf Raises', 'muscleGroup': 'Calves'},
    ];
  }

  // ─── DEFAULT ACHIEVEMENTS ──────────────────────────────────────────────────

  static List<AchievementModel> _getDefaultAchievements() {
    return [
      AchievementModel(
        id: AppConstants.firstWorkoutAchievement,
        title: 'First Steps',
        description: 'Log your first workout session.',
        iconName: 'fitness_center',
        xpReward: 50,
        rarity: 'common',
      ),
      AchievementModel(
        id: AppConstants.sevenDayStreakAchievement,
        title: 'Week Warrior',
        description: 'Maintain a 7-day workout streak.',
        iconName: 'local_fire_department',
        xpReward: 200,
        rarity: 'rare',
      ),
      AchievementModel(
        id: AppConstants.thirtyWorkoutsAchievement,
        title: 'Dedicated Hunter',
        description: 'Complete 30 total workout sessions.',
        iconName: 'military_tech',
        xpReward: 300,
        rarity: 'rare',
      ),
      AchievementModel(
        id: AppConstants.firstPRAchievement,
        title: 'New Record',
        description: 'Achieve your first Personal Record.',
        iconName: 'emoji_events',
        xpReward: 150,
        rarity: 'common',
      ),
      AchievementModel(
        id: AppConstants.tenCardioAchievement,
        title: 'Cardio Hunter',
        description: 'Log 10 cardio sessions.',
        iconName: 'directions_run',
        xpReward: 100,
        rarity: 'common',
      ),
      AchievementModel(
        id: AppConstants.hundredSetsAchievement,
        title: 'Iron Will',
        description: 'Complete 100 total sets.',
        iconName: 'repeat',
        xpReward: 250,
        rarity: 'rare',
      ),
      AchievementModel(
        id: AppConstants.weightGoalAchievement,
        title: 'Goal Crusher',
        description: 'Reach your target body weight.',
        iconName: 'flag',
        xpReward: 500,
        rarity: 'epic',
      ),
      AchievementModel(
        id: 'thirty_day_streak',
        title: 'Unstoppable',
        description: 'Maintain a 30-day workout streak.',
        iconName: 'bolt',
        xpReward: 1000,
        rarity: 'legendary',
      ),
      AchievementModel(
        id: 'hundred_workouts',
        title: 'Century Hunter',
        description: 'Complete 100 total workout sessions.',
        iconName: 'workspace_premium',
        xpReward: 750,
        rarity: 'epic',
      ),
      AchievementModel(
        id: 'first_photo',
        title: 'Eyes on Progress',
        description: 'Upload your first progress photo.',
        iconName: 'photo_camera',
        xpReward: 50,
        rarity: 'common',
      ),
    ];
  }
}
