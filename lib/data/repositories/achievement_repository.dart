import '../models/achievement_model.dart';
import '../database/hive_service.dart';

// ─── ACHIEVEMENT REPOSITORY ───────────────────────────────────────────────────
// Extracted from user_repository.dart to follow the same pattern as
// all other repositories in the project.

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

  /// Unlock an achievement and return it (returns null if already unlocked).
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