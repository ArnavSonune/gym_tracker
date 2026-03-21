import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/achievement_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';

class AchievementChecker {
  final WidgetRef ref;

  AchievementChecker(this.ref);

  /// Check all achievement conditions after any workout/cardio/streak update
  Future<List<AchievementModel>> checkAllAchievements() async {
    final unlocked = <AchievementModel>[];

    // Get current stats
    final workoutCount = ref.read(workoutProvider.notifier).totalWorkouts;
    final cardioCount = ref.read(cardioProvider.notifier).totalCardio;
    final totalSets = ref.read(workoutProvider.notifier).totalSets;
    final currentStreak = ref.read(streakProvider).currentStreak;

    // Check first workout
    if (workoutCount >= 1) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.firstWorkoutAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 7-day streak
    if (currentStreak >= 7) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.sevenDayStreakAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 30 workouts
    if (workoutCount >= 30) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.thirtyWorkoutsAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 10 cardio
    if (cardioCount >= 10) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.tenCardioAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 100 sets
    if (totalSets >= 100) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.hundredSetsAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 30-day streak (hidden achievement)
    if (currentStreak >= 30) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock('thirty_day_streak');
      if (achievement != null) unlocked.add(achievement);
    }

    // Check 100 workouts (hidden achievement)
    if (workoutCount >= 100) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock('hundred_workouts');
      if (achievement != null) unlocked.add(achievement);
    }

    // Check first PR achievement
    final exercises = ref.read(exerciseProvider);
    final hasAnyPR = exercises.any((e) => e.prWeight > 0);
    if (hasAnyPR) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.firstPRAchievement);
      if (achievement != null) unlocked.add(achievement);
    }

    // Check weight goal achievement
    final user = ref.read(userProvider);
    final currentWeight = ref.read(weightProvider.notifier).currentWeight;
    if (user?.targetWeight != null && currentWeight != null) {
      final targetReached = (currentWeight - user!.targetWeight!).abs() <= 1.0;
      if (targetReached) {
        final achievement = await ref
            .read(achievementProvider.notifier)
            .tryUnlock(AppConstants.weightGoalAchievement);
        if (achievement != null) unlocked.add(achievement);
      }
    }

    // Check first photo achievement
    final photoCount = ref.read(photoProvider.notifier).totalPhotos;
    if (photoCount >= 1) {
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock('first_photo');
      if (achievement != null) unlocked.add(achievement);
    }

    return unlocked;
  }
}
