import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 4)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  bool isCustom;

  @HiveField(4)
  DateTime createdAt;

  // PR Tracking (auto-calculated from workouts, stored for quick access)
  @HiveField(5)
  double prWeight;

  @HiveField(6)
  DateTime? prAchievedDate;

  @HiveField(7)
  double bestVolume;

  @HiveField(8)
  DateTime? bestVolumeDate;

  @HiveField(9)
  DateTime? lastPerformed;

  @HiveField(10)
  int totalSessions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isCustom = false,
    required this.createdAt,
    this.prWeight = 0.0,
    this.prAchievedDate,
    this.bestVolume = 0.0,
    this.bestVolumeDate,
    this.lastPerformed,
    this.totalSessions = 0,
  });

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    bool? isCustom,
    DateTime? createdAt,
    double? prWeight,
    DateTime? prAchievedDate,
    double? bestVolume,
    DateTime? bestVolumeDate,
    DateTime? lastPerformed,
    int? totalSessions,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      prWeight: prWeight ?? this.prWeight,
      prAchievedDate: prAchievedDate ?? this.prAchievedDate,
      bestVolume: bestVolume ?? this.bestVolume,
      bestVolumeDate: bestVolumeDate ?? this.bestVolumeDate,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
