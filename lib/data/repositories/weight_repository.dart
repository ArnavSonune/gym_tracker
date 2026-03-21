import 'package:uuid/uuid.dart';
import '../models/weight_log_model.dart';
import '../database/hive_service.dart';
import '../../core/utils/app_utils.dart';

class WeightRepository {
  static const _uuid = Uuid();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<WeightLogModel> addWeightLog({
    required DateTime date,
    required double weightKg,
    String? notes,
  }) async {
    final log = WeightLogModel(
      id: _uuid.v4(),
      date: date,
      weightKg: weightKg,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await HiveService.weightLogBox.put(log.id, log);
    return log;
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<WeightLogModel> getAllWeightLogs() {
    return HiveService.weightLogBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // oldest first for charts
  }

  List<WeightLogModel> getWeightLogsByDateRange(
      DateTime start, DateTime end) {
    return HiveService.weightLogBox.values
        .where((w) =>
            w.date.isAfter(start.subtract(const Duration(days: 1))) &&
            w.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  WeightLogModel? getLatestWeightLog() {
    if (HiveService.weightLogBox.isEmpty) return null;
    return HiveService.weightLogBox.values
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  WeightLogModel? getEarliestWeightLog() {
    if (HiveService.weightLogBox.isEmpty) return null;
    return HiveService.weightLogBox.values
        .reduce((a, b) => a.date.isBefore(b.date) ? a : b);
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateWeightLog(WeightLogModel log) async {
    await HiveService.weightLogBox.put(log.id, log);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteWeightLog(String logId) async {
    await HiveService.weightLogBox.delete(logId);
  }

  // ─── ANALYTICS ────────────────────────────────────────────────────────────

  double? getCurrentWeight() => getLatestWeightLog()?.weightKg;

  double? getStartingWeight() => getEarliestWeightLog()?.weightKg;

  double? getTotalWeightChange() {
    final current = getCurrentWeight();
    final starting = getStartingWeight();
    if (current == null || starting == null) return null;
    return current - starting;
  }

  /// Average weight change per week
  double? getWeeklyAverageChange() {
    final logs = getAllWeightLogs();
    if (logs.length < 2) return null;

    final firstLog = logs.first;
    final lastLog = logs.last;
    final days = AppUtils.daysBetween(firstLog.date, lastLog.date);
    if (days == 0) return null;

    final totalChange = lastLog.weightKg - firstLog.weightKg;
    return (totalChange / days) * 7;
  }

  /// Weight change in last 7 days
  double? getWeightChangeLast7Days() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final logs = getWeightLogsByDateRange(weekAgo, DateTime.now());
    if (logs.length < 2) return null;
    return logs.last.weightKg - logs.first.weightKg;
  }

  /// Chart data (date + weight)
  List<Map<String, dynamic>> getWeightChartData({DateTime? startDate}) {
    final logs = startDate != null
        ? getWeightLogsByDateRange(startDate, DateTime.now())
        : getAllWeightLogs();

    return logs
        .map((l) => {'date': l.date, 'value': l.weightKg})
        .toList();
  }
}
