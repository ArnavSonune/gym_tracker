import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../models/streak_data_model.dart';
import '../database/hive_service.dart';
import '../database/database_helper.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

// ─── USER REPOSITORY ──────────────────────────────────────────────────────────

class UserRepository {

  UserModel? getUser() => DatabaseHelper.getCurrentUser();

  Future<void> createUser(String name) async {
    await DatabaseHelper.createDefaultUser(name);
  }

  Future<void> updateUser(UserModel user) async {
    await DatabaseHelper.updateUser(user);
  }

  Future<void> addXP(int xpAmount) async {
    final user = getUser();
    if (user == null) return;

    final newXP = user.totalXP + xpAmount;
    final newLevel = AppUtils.getLevelFromXP(newXP);

    final updated = user.copyWith(
      totalXP: newXP,
      currentLevel: newLevel,
    );
    await DatabaseHelper.updateUser(updated);
  }

  bool hasUser() => getUser() != null;

  /// Check if user leveled up after gaining XP
  bool didLevelUp(int oldXP, int newXP) {
    final oldLevel = AppUtils.getLevelFromXP(oldXP);
    final newLevel = AppUtils.getLevelFromXP(newXP);
    return newLevel > oldLevel;
  }
}

// ─── ACHIEVEMENT REPOSITORY ───────────────────────────────────────────────────

class AchievementRepository {

  List<AchievementModel> getAllAchievements() {
    return HiveService.achievementBox.values.toList();
  }

  List<AchievementModel> getUnlockedAchievements() {
    return HiveService.achievementBox.values
        .where((a) => a.isUnlocked)
        .toList()
      ..sort((a, b) => (b.unlockedAt ?? DateTime(0))
          .compareTo(a.unlockedAt ?? DateTime(0)));
  }

  List<AchievementModel> getLockedAchievements() {
    return HiveService.achievementBox.values
        .where((a) => !a.isUnlocked)
        .toList();
  }

  AchievementModel? getAchievement(String id) {
    return HiveService.achievementBox.get(id);
  }

  /// Unlock an achievement and return it (returns null if already unlocked)
  Future<AchievementModel?> unlockAchievement(String achievementId) async {
    final achievement = HiveService.achievementBox.get(achievementId);
    if (achievement == null || achievement.isUnlocked) return null;

    final updated = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
    await HiveService.achievementBox.put(achievementId, updated);
    return updated;
  }

  int getUnlockedCount() => getUnlockedAchievements().length;
  int getTotalCount() => HiveService.achievementBox.length;
}

// ─── STREAK REPOSITORY ────────────────────────────────────────────────────────

class StreakRepository {

  StreakDataModel getStreakData() => DatabaseHelper.getStreakData();

  /// Called after every workout/cardio log to update streak
  Future<StreakDataModel> recordWorkoutDay(DateTime workoutDate) async {
    var streakData = getStreakData();
    final dateOnly = AppUtils.getDateOnly(workoutDate);

    // Already recorded today — no change needed
    if (streakData.hadWorkoutOn(dateOnly)) {
      return streakData;
    }

    streakData = streakData.addWorkoutDate(dateOnly);

    final lastDate = streakData.lastWorkoutDate;
    int newStreak = streakData.currentStreak;

    if (lastDate == null) {
      // First ever workout
      newStreak = 1;
    } else {
      final daysSinceLast = AppUtils.daysBetween(lastDate, dateOnly);

      if (daysSinceLast == 1) {
        // Consecutive day — extend streak
        newStreak = streakData.currentStreak + 1;
      } else if (daysSinceLast <= AppConstants.maxMissedDaysBeforeBreak) {
        // Within allowed gap — keep streak but don't increment
        // (Streak only breaks after 2 consecutive missed days)
        newStreak = streakData.currentStreak + 1;
      } else {
        // Streak broken — reset to 1
        newStreak = 1;
      }
    }

    final newHighest = newStreak > streakData.highestStreak
        ? newStreak
        : streakData.highestStreak;

    final updated = streakData.copyWith(
      currentStreak: newStreak,
      highestStreak: newHighest,
      lastWorkoutDate: dateOnly,
    );

    await DatabaseHelper.updateStreakData(updated);
    return updated;
  }

  /// Check and update streak on app open (break streak if needed)
  Future<StreakDataModel> checkAndUpdateStreak() async {
    var streakData = getStreakData();
    final lastDate = streakData.lastWorkoutDate;

    if (lastDate == null) return streakData;

    final today = AppUtils.getDateOnly(DateTime.now());
    final daysSinceLast = AppUtils.daysBetween(lastDate, today);

    // Break streak if more than allowed consecutive missed days
    if (daysSinceLast > AppConstants.maxMissedDaysBeforeBreak) {
      final updated = streakData.copyWith(currentStreak: 0);
      await DatabaseHelper.updateStreakData(updated);
      return updated;
    }

    return streakData;
  }

  int getCurrentStreak() => getStreakData().currentStreak;
  int getHighestStreak() => getStreakData().highestStreak;

  bool hadWorkoutToday() {
    final today = AppUtils.getDateOnly(DateTime.now());
    return getStreakData().hadWorkoutOn(today);
  }
}
