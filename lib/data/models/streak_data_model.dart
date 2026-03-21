import 'package:hive/hive.dart';

part 'streak_data_model.g.dart';

@HiveType(typeId: 9)
class StreakDataModel extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int highestStreak;

  @HiveField(2)
  DateTime? lastWorkoutDate;

  // List of dates with workouts (stored as ISO strings for Hive compatibility)
  @HiveField(3)
  List<String> workoutDates;

  StreakDataModel({
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.lastWorkoutDate,
    List<String>? workoutDates,
  }) : workoutDates = workoutDates ?? [];

  // Get workout dates as DateTime objects
  List<DateTime> get workoutDatesParsed =>
      workoutDates.map((d) => DateTime.parse(d)).toList();

  // Check if a specific date had a workout
  bool hadWorkoutOn(DateTime date) {
    final dateStr = _dateToString(date);
    return workoutDates.contains(dateStr);
  }

  // Add a workout date
  StreakDataModel addWorkoutDate(DateTime date) {
    final dateStr = _dateToString(date);
    final updatedDates = List<String>.from(workoutDates);
    if (!updatedDates.contains(dateStr)) {
      updatedDates.add(dateStr);
    }
    return copyWith(workoutDates: updatedDates);
  }

  // Helper: Convert DateTime to string key (date only)
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get dates for heatmap (last 365 days)
  Map<DateTime, int> getHeatmapData() {
    final Map<DateTime, int> heatmap = {};
    final parsedDates = workoutDatesParsed;

    for (final date in parsedDates) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      heatmap[dateOnly] = (heatmap[dateOnly] ?? 0) + 1;
    }
    return heatmap;
  }

  StreakDataModel copyWith({
    int? currentStreak,
    int? highestStreak,
    DateTime? lastWorkoutDate,
    List<String>? workoutDates,
  }) {
    return StreakDataModel(
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      workoutDates: workoutDates ?? this.workoutDates,
    );
  }
}
