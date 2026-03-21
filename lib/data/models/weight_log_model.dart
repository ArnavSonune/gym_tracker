import 'package:hive/hive.dart';

part 'weight_log_model.g.dart';

@HiveType(typeId: 5)
class WeightLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  DateTime createdAt;

  WeightLogModel({
    required this.id,
    required this.date,
    required this.weightKg,
    this.notes,
    required this.createdAt,
  });

  WeightLogModel copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? notes,
    DateTime? createdAt,
  }) {
    return WeightLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
