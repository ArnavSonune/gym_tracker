class AppConstants {
  // App Info
  static const String appName = 'System: Hunter';
  static const String appVersion = '1.0.0';
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String workoutBox = 'workout_box';
  static const String cardioBox = 'cardio_box';
  static const String exerciseBox = 'exercise_box';
  static const String weightLogBox = 'weight_log_box';
  static const String measurementBox = 'measurement_box';
  static const String photoBox = 'photo_box';
  static const String achievementBox = 'achievement_box';
  static const String streakBox = 'streak_box';
  
  // Hive Type IDs
  static const int userTypeId = 0;
  static const int workoutTypeId = 1;
  static const int cardioTypeId = 2;
  static const int exerciseTypeId = 3;
  static const int weightLogTypeId = 4;
  static const int measurementTypeId = 5;
  static const int photoLogTypeId = 6;
  static const int achievementTypeId = 7;
  static const int streakDataTypeId = 8;
  
  // XP Calculation Constants
  static const double strengthXpMultiplier = 0.01; // (sets * reps * weight) / 100
  static const double cardioDurationXpMultiplier = 2.0; // duration_minutes * 2
  static const double cardioDistanceXpMultiplier = 10.0; // distance_km * 10
  
  // Level Requirements
  static const int baseXpPerLevel = 100;
  static const double xpGrowthMultiplier = 1.5; // Each level requires 1.5x more XP
  
  // Rank Thresholds
  static const Map<String, int> rankThresholds = {
    'E': 0,   // Level 1-10
    'D': 11,  // Level 11-20
    'C': 21,  // Level 21-30
    'B': 31,  // Level 31-40
    'A': 41,  // Level 41-50
    'S': 51,  // Level 51+
  };
  
  // Streak Configuration
  static const int maxMissedDaysBeforeBreak = 2; // Streak breaks after 2 consecutive missed days
  
  // Muscle Groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Abs',
    'Obliques',
    'Lower Back',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Traps',
    'Lats',
    'Rear Delts',
  ];
  
  // Cardio Types
  static const List<String> cardioTypes = [
    'Running',
    'Cycling',
    'Treadmill',
    'Swimming',
    'Elliptical',
    'Rowing',
    'Jump Rope',
    'Stairs',
    'Walking',
    'Hiking',
    'Other',
  ];
  
  // Body Measurements
  static const List<String> bodyMeasurements = [
    'Chest',
    'Waist',
    'Shoulders',
    'Arms',
    'Forearms',
    'Thighs',
    'Calves',
    'Neck',
    'Body Fat %',
  ];
  
  // Activity Levels for TDEE
  static const Map<String, double> activityMultipliers = {
    'Sedentary (little to no exercise)': 1.2,
    'Lightly Active (1-3 days/week)': 1.375,
    'Moderately Active (3-5 days/week)': 1.55,
    'Very Active (6-7 days/week)': 1.725,
    'Extremely Active (physical job + training)': 1.9,
  };
  
  // Protein Goals (g per kg of body weight)
  static const Map<String, double> proteinGoals = {
    'Cutting': 2.2,
    'Maintenance': 1.8,
    'Bulking': 2.0,
  };
  
  // Chart Time Ranges
  static const List<String> chartRanges = [
    'Week',
    'Month',
    '3 Months',
    'Year',
    'All Time',
  ];
  
  // Achievement IDs
  static const String firstWorkoutAchievement = 'first_workout';
  static const String sevenDayStreakAchievement = 'seven_day_streak';
  static const String thirtyWorkoutsAchievement = 'thirty_workouts';
  static const String firstPRAchievement = 'first_pr';
  static const String tenCardioAchievement = 'ten_cardio';
  static const String hundredSetsAchievement = 'hundred_sets';
  static const String weightGoalAchievement = 'weight_goal';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double defaultBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
  
  // Image Quality
  static const int photoQuality = 85; // JPEG quality for saved photos
  static const int maxPhotoWidth = 1920;
  static const int maxPhotoHeight = 1920;
  
  // Pagination
  static const int workoutHistoryPageSize = 20;
  static const int photoGalleryPageSize = 50;
  
  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String storageDateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  
  // System Messages
  static const List<String> motivationalMessages = [
    'The system acknowledges your dedication, Hunter.',
    'Your power level continues to rise.',
    'Every rep brings you closer to S-Rank.',
    'The grind never stops, Hunter.',
    'Your progress has been recorded.',
    'Level up imminent. Keep pushing.',
    'The system detects increased strength.',
  ];
  
  // Empty State Messages
  static const String emptyWorkoutsMessage = 'Your journey begins now, Hunter!\nLog your first workout to start leveling up.';
  static const String emptyCardioMessage = 'No cardio sessions recorded.\nTime to boost your endurance!';
  static const String emptyPhotosMessage = 'Document your transformation.\nCapture your first progress photo!';
  static const String emptyWeightMessage = 'Track your weight journey.\nAdd your first weight entry!';
  static const String emptyMeasurementsMessage = 'Monitor your body metrics.\nRecord your first measurements!';
}