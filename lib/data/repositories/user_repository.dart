import '../models/user_model.dart';
import '../models/streak_data_model.dart';
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
    final updated = user.copyWith(totalXP: newXP, currentLevel: newLevel);
    await DatabaseHelper.updateUser(updated);
  }

  bool hasUser() => getUser() != null;

  bool didLevelUp(int oldXP, int newXP) {
    return AppUtils.getLevelFromXP(newXP) > AppUtils.getLevelFromXP(oldXP);
  }
}

// ─── STREAK REPOSITORY ────────────────────────────────────────────────────────

class StreakRepository {
  StreakDataModel getStreakData() => DatabaseHelper.getStreakData();

  Future<StreakDataModel> recordWorkoutDay(DateTime workoutDate) async {
    var streakData = getStreakData();
    final dateOnly = AppUtils.getDateOnly(workoutDate);
    if (streakData.hadWorkoutOn(dateOnly)) return streakData;

    streakData = streakData.addWorkoutDate(dateOnly);
    final lastDate = streakData.lastWorkoutDate;
    int newStreak;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final daysSinceLast = AppUtils.daysBetween(lastDate, dateOnly);
      newStreak = daysSinceLast <= AppConstants.maxMissedDaysBeforeBreak
          ? streakData.currentStreak + 1
          : 1;
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

  Future<StreakDataModel> checkAndUpdateStreak() async {
    final streakData = getStreakData();
    final lastDate = streakData.lastWorkoutDate;
    if (lastDate == null) return streakData;

    final today = AppUtils.getDateOnly(DateTime.now());
    final daysSinceLast = AppUtils.daysBetween(lastDate, today);

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