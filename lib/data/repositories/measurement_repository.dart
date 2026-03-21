import 'package:uuid/uuid.dart';
import '../models/measurement_model.dart';
import '../database/hive_service.dart';

class MeasurementRepository {
  static const _uuid = Uuid();

  // ─── CREATE ───────────────────────────────────────────────────────────────

  Future<MeasurementModel> addMeasurement({
    required DateTime date,
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
  }) async {
    final measurement = MeasurementModel(
      id: _uuid.v4(),
      date: date,
      chest: chest,
      waist: waist,
      shoulders: shoulders,
      arms: arms,
      forearms: forearms,
      thighs: thighs,
      calves: calves,
      neck: neck,
      bodyFatPercentage: bodyFatPercentage,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await HiveService.measurementBox.put(measurement.id, measurement);
    return measurement;
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  List<MeasurementModel> getAllMeasurements() {
    return HiveService.measurementBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  MeasurementModel? getLatestMeasurement() {
    if (HiveService.measurementBox.isEmpty) return null;
    return HiveService.measurementBox.values
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Chart data for a specific measurement field
  List<Map<String, dynamic>> getMeasurementChartData(
    String fieldName, {
    DateTime? startDate,
  }) {
    var measurements = getAllMeasurements()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (startDate != null) {
      measurements = measurements
          .where((m) => m.date.isAfter(startDate))
          .toList();
    }

    return measurements
        .map((m) {
          final map = m.toMeasurementMap();
          final value = map[fieldName];
          if (value == null) return null;
          return {'date': m.date, 'value': value};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  Future<void> updateMeasurement(MeasurementModel measurement) async {
    await HiveService.measurementBox.put(measurement.id, measurement);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> deleteMeasurement(String measurementId) async {
    await HiveService.measurementBox.delete(measurementId);
  }
}
