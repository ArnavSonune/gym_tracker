import 'package:uuid/uuid.dart';
import '../models/cardio_model.dart';
import '../database/hive_service.dart';
import '../database/database_helper.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

class CardioRepository {
  static const _uuid = Uuid();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<CardioModel> addCardio({
    required DateTime date,
    required String cardioType,
    required int durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
    String? notes,
  }) async {
    final user = DatabaseHelper.getCurrentUser();
    final expLevel = user?.gymExperienceLevel ?? 0;
    final expMultiplier = AppConstants.gymExperienceXpMultipliers[
        expLevel.clamp(0, AppConstants.gymExperienceXpMultipliers.length - 1)];

    final xp = AppUtils.calculateCardioXP(
      durationMinutes: durationMinutes,
      distanceKm: distanceKm ?? 0,
      experienceMultiplier: expMultiplier,
    );

    final cardio = CardioModel(
      id: _uuid.v4(),
      date: date,
      cardioType: cardioType,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      caloriesBurned: caloriesBurned,
      notes: notes,
      xpEarned: xp,
      createdAt: DateTime.now(),
    );

    await HiveService.cardioBox.put(cardio.id, cardio);
    return cardio;
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<CardioModel> getAllCardio() {
    return HiveService.cardioBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<CardioModel> getCardioByDateRange(DateTime start, DateTime end) {
    return HiveService.cardioBox.values
        .where((c) =>
            c.date.isAfter(start.subtract(const Duration(days: 1))) &&
            c.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<CardioModel> getCardioForDate(DateTime date) {
    return HiveService.cardioBox.values
        .where((c) => AppUtils.isSameDay(c.date, date))
        .toList();
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateCardio(CardioModel cardio) async {
    await HiveService.cardioBox.put(cardio.id, cardio);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteCardio(String cardioId) async {
    await HiveService.cardioBox.delete(cardioId);
  }

  // ─── ANALYTICS ────────────────────────────────────────────────────────────

  int getTotalCardioCount() => HiveService.cardioBox.length;

  int getTotalCardioMinutes() {
    return HiveService.cardioBox.values
        .fold(0, (sum, c) => sum + c.durationMinutes);
  }

  double getTotalCardioDistance() {
    return HiveService.cardioBox.values
        .fold(0.0, (sum, c) => sum + (c.distanceKm ?? 0));
  }

  int getCardioThisWeek() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return HiveService.cardioBox.values
        .where((c) => c.date.isAfter(weekAgo))
        .length;
  }

  /// Weekly cardio duration by day (for charts)
  Map<DateTime, int> getWeeklyCardioDurationByDay() {
    final Map<DateTime, int> result = {};
    final weekAgo = DateTime.now().subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final day = AppUtils.getDateOnly(weekAgo.add(Duration(days: i)));
      result[day] = 0;
    }

    for (final cardio in HiveService.cardioBox.values) {
      final day = AppUtils.getDateOnly(cardio.date);
      if (result.containsKey(day)) {
        result[day] = (result[day] ?? 0) + cardio.durationMinutes;
      }
    }

    return result;
  }
}

