import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 2)
class WorkoutSetModel extends HiveObject {
  @HiveField(0)
  int setNumber;

  @HiveField(1)
  int reps;

  @HiveField(2)
  double weight;

  WorkoutSetModel({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  // Volume for this set
  double get volume => reps * weight;

  WorkoutSetModel copyWith({
    int? setNumber,
    int? reps,
    double? weight,
  }) {
    return WorkoutSetModel(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
}

@HiveType(typeId: 1)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  String exerciseName;

  @HiveField(4)
  List<WorkoutSetModel> sets;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  int xpEarned;

  @HiveField(7)
  DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.date,
    required this.muscleGroup,
    required this.exerciseName,
    required this.sets,
    this.notes,
    this.xpEarned = 0,
    required this.createdAt,
  });

  // Auto-calculated total volume: sum of (reps * weight) for all sets
  double get totalVolume =>
      sets.fold(0.0, (sum, set) => sum + set.volume);

  // Total sets count
  int get totalSets => sets.length;

  // Total reps across all sets
  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);

  // Max weight lifted in this session
  double get maxWeight =>
      sets.isEmpty ? 0.0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  // Best set volume
  double get bestSetVolume =>
      sets.isEmpty ? 0.0 : sets.map((s) => s.volume).reduce((a, b) => a > b ? a : b);

  WorkoutModel copyWith({
    String? id,
    DateTime? date,
    String? muscleGroup,
    String? exerciseName,
    List<WorkoutSetModel>? sets,
    String? notes,
    int? xpEarned,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      date: date ?? this.date,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      xpEarned: xpEarned ?? this.xpEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
