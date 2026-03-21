import 'package:hive/hive.dart';

part 'cardio_model.g.dart';

@HiveType(typeId: 3)
class CardioModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String cardioType;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  double? distanceKm;

  @HiveField(5)
  int? caloriesBurned;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  int xpEarned;

  @HiveField(8)
  DateTime createdAt;

  CardioModel({
    required this.id,
    required this.date,
    required this.cardioType,
    required this.durationMinutes,
    this.distanceKm,
    this.caloriesBurned,
    this.notes,
    this.xpEarned = 0,
    required this.createdAt,
  });

  // Average pace (min/km) if distance is available
  double? get averagePace {
    if (distanceKm == null || distanceKm == 0) return null;
    return durationMinutes / distanceKm!;
  }

  // Average speed (km/h) if distance is available
  double? get averageSpeed {
    if (distanceKm == null || distanceKm == 0) return null;
    return (distanceKm! / durationMinutes) * 60;
  }

  CardioModel copyWith({
    String? id,
    DateTime? date,
    String? cardioType,
    int? durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
    String? notes,
    int? xpEarned,
    DateTime? createdAt,
  }) {
    return CardioModel(
      id: id ?? this.id,
      date: date ?? this.date,
      cardioType: cardioType ?? this.cardioType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      xpEarned: xpEarned ?? this.xpEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
