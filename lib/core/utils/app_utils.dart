import 'dart:math';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // XP Calculation for Strength Training
  static int calculateStrengthXP({
    required int sets,
    required int reps,
    required double weight,
  }) {
    final totalVolume = sets * reps * weight;
    final xp = (totalVolume * AppConstants.strengthXpMultiplier).round();
    return xp > 0 ? xp : 1; // Minimum 1 XP
  }

  // XP Calculation for Cardio
  static int calculateCardioXP({
    required int durationMinutes,
    double distanceKm = 0,
  }) {
    final durationXP = durationMinutes * AppConstants.cardioDurationXpMultiplier;
    final distanceXP = distanceKm * AppConstants.cardioDistanceXpMultiplier;
    final totalXP = (durationXP + distanceXP).round();
    return totalXP > 0 ? totalXP : 1; // Minimum 1 XP
  }

  // Calculate required XP for a specific level
  static int getRequiredXPForLevel(int level) {
    if (level <= 1) return 0;

    // Correct exponential formula: baseXP * (growthMultiplier ^ (level - 1))
    // Was incorrectly using * instead of pow() — fixed.
    final requiredXP = (AppConstants.baseXpPerLevel *
            pow(AppConstants.xpGrowthMultiplier, level - 1))
        .round();

    return requiredXP;
  }

  // Calculate total XP needed to reach a level from level 1
  static int getTotalXPForLevel(int level) {
    int totalXP = 0;
    for (int i = 2; i <= level; i++) {
      totalXP += getRequiredXPForLevel(i);
    }
    return totalXP;
  }

  // Get current level from total XP
  static int getLevelFromXP(int totalXP) {
    int level = 1;
    int xpAccumulated = 0;
    
    while (xpAccumulated <= totalXP) {
      level++;
      xpAccumulated += getRequiredXPForLevel(level);
    }
    
    return level - 1; // Return the last completed level
  }

  // Get XP progress percentage for current level
  static double getLevelProgress(int currentXP, int level) {
    final currentLevelBaseXP = getTotalXPForLevel(level);
    final nextLevelBaseXP = getTotalXPForLevel(level + 1);
    final requiredXPForNextLevel = nextLevelBaseXP - currentLevelBaseXP;
    final currentProgress = currentXP - currentLevelBaseXP;
    
    if (requiredXPForNextLevel <= 0) return 1.0;
    
    final progress = currentProgress / requiredXPForNextLevel;
    return progress.clamp(0.0, 1.0);
  }

  // Get rank from level
  static String getRank(int level) {
    return AppConstants.rankThresholds.entries
        .lastWhere(
          (entry) => level >= entry.value,
          orElse: () => AppConstants.rankThresholds.entries.first,
        )
        .key;
  }

  // Get rank title
  static String getRankTitle(int level) {
    final rank = getRank(level);
    return '$rank-Rank Hunter';
  }

  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  // Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get date without time
  static DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Calculate days between dates
  static int daysBetween(DateTime from, DateTime to) {
    from = getDateOnly(from);
    to = getDateOnly(to);
    return to.difference(from).inDays;
  }

  // BMR Calculation (Mifflin-St Jeor Equation)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // TDEE Calculation
  static double calculateTDEE({
    required double bmr,
    required double activityMultiplier,
  }) {
    return bmr * activityMultiplier;
  }

  // BMI Calculation
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // BMI Category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Protein Calculation
  static double calculateProtein({
    required double weightKg,
    required String goal,
  }) {
    final multiplier = AppConstants.proteinGoals[goal] ?? 1.8;
    return weightKg * multiplier;
  }

  // Format number with suffix (K, M)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Format weight
  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  // Format distance
  static String formatDistance(double distance) {
    return '${distance.toStringAsFixed(2)} km';
  }

  // Format duration
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  // Get random motivational message
  static String getRandomMotivationalMessage() {
    const messages = AppConstants.motivationalMessages;
    return messages[DateTime.now().millisecond % messages.length];
  }

  // Calculate percentage change
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  // Check if streak is broken
  static bool isStreakBroken(DateTime lastWorkoutDate, DateTime currentDate) {
    final daysMissed = daysBetween(lastWorkoutDate, currentDate);
    return daysMissed > AppConstants.maxMissedDaysBeforeBreak;
  }

  // Get date range for chart filter
  static DateTime getStartDateForRange(String range) {
    final now = DateTime.now();
    
    switch (range) {
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return DateTime(now.year, now.month - 1, now.day);
      case '3 Months':
        return DateTime(now.year, now.month - 3, now.day);
      case 'Year':
        return DateTime(now.year - 1, now.month, now.day);
      case 'All Time':
      default:
        return DateTime(2020, 1, 1); // Arbitrary past date
    }
  }

  // Validate input
  static bool isValidNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  static bool isValidPositiveNumber(String? value) {
    if (!isValidNumber(value)) return false;
    final number = double.parse(value!);
    return number > 0;
  }

  // Clamp value between min and max
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}