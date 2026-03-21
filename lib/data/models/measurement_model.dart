import 'package:hive/hive.dart';

part 'measurement_model.g.dart';

@HiveType(typeId: 6)
class MeasurementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  // All measurements in cm, body fat in %
  @HiveField(2)
  double? chest;

  @HiveField(3)
  double? waist;

  @HiveField(4)
  double? shoulders;

  @HiveField(5)
  double? arms;

  @HiveField(6)
  double? forearms;

  @HiveField(7)
  double? thighs;

  @HiveField(8)
  double? calves;

  @HiveField(9)
  double? neck;

  @HiveField(10)
  double? bodyFatPercentage;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  DateTime createdAt;

  MeasurementModel({
    required this.id,
    required this.date,
    this.chest,
    this.waist,
    this.shoulders,
    this.arms,
    this.forearms,
    this.thighs,
    this.calves,
    this.neck,
    this.bodyFatPercentage,
    this.notes,
    required this.createdAt,
  });

  // Map for easy iteration in UI
  Map<String, double?> toMeasurementMap() {
    return {
      'Chest': chest,
      'Waist': waist,
      'Shoulders': shoulders,
      'Arms': arms,
      'Forearms': forearms,
      'Thighs': thighs,
      'Calves': calves,
      'Neck': neck,
      'Body Fat %': bodyFatPercentage,
    };
  }

  // Check if any measurement was entered
  bool get hasAnyMeasurement =>
      chest != null ||
      waist != null ||
      shoulders != null ||
      arms != null ||
      forearms != null ||
      thighs != null ||
      calves != null ||
      neck != null ||
      bodyFatPercentage != null;

  MeasurementModel copyWith({
    String? id,
    DateTime? date,
    double? chest,
    double? waist,
    double? shoulders,
    double? arms,
    double? forearms,
    double? thighs,
    double? calves,
    double? neck,
    double? bodyFatPercentage,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeasurementModel(
      id: id ?? this.id,
      date: date ?? this.date,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      shoulders: shoulders ?? this.shoulders,
      arms: arms ?? this.arms,
      forearms: forearms ?? this.forearms,
      thighs: thighs ?? this.thighs,
      calves: calves ?? this.calves,
      neck: neck ?? this.neck,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
