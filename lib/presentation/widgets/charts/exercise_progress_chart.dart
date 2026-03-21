import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../common/glass_card.dart';

class ExerciseProgressChart extends ConsumerStatefulWidget {
  final String exerciseName;

  const ExerciseProgressChart({
    super.key,
    required this.exerciseName,
  });

  @override
  ConsumerState<ExerciseProgressChart> createState() =>
      _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends ConsumerState<ExerciseProgressChart> {
  String _selectedMetric = 'Weight'; // Weight, Volume, Reps
  String _selectedRange = AppConstants.chartRanges[1]; // Month

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = ref.watch(exerciseRepositoryProvider);
    
    // Get the appropriate data based on metric
    final List<Map<String, dynamic>> data;
    final startDate = _getStartDate();
    
    switch (_selectedMetric) {
      case 'Weight':
        data = exerciseRepo.getExerciseWeightProgress(
          widget.exerciseName,
          startDate: startDate,
        );
        break;
      case 'Volume':
        data = exerciseRepo.getExerciseVolumeProgress(
          widget.exerciseName,
          startDate: startDate,
        );
        break;
      case 'Reps':
        data = exerciseRepo.getExerciseRepsProgress(
          widget.exerciseName,
          startDate: startDate,
        );
        break;
      default:
        data = [];
    }

    if (data.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 250,
          child: Center(
            child: Text(
              'No data available for ${widget.exerciseName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with metric selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.exerciseName.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.neonBlue,
                      letterSpacing: 1,
                    ),
              ),
              _buildMetricSelector(),
            ],
          ),
          const SizedBox(height: 8),
          
          // Range selector
          Row(
            children: AppConstants.chartRanges.map((range) {
              final isSelected = _selectedRange == range;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRange = range),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.neonBlue.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.neonBlue
                            : AppTheme.textTertiary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      range,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? AppTheme.neonBlue
                                : AppTheme.textTertiary,
                          ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 220,
            child: _buildLineChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return DropdownButton<String>(
      value: _selectedMetric,
      dropdownColor: AppTheme.darkSurface,
      underline: const SizedBox(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.neonBlue,
          ),
      items: ['Weight', 'Volume', 'Reps']
          .map((m) => DropdownMenuItem(
                value: m,
                child: Text(m),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedMetric = v!),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();

    // Convert data to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    // Calculate min/max for Y axis
    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.glassBlue.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                final date = data[index]['date'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 9,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY - yPadding,
        maxY: maxY + yPadding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.neonBlue,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.neonBlue,
                  strokeWidth: 2,
                  strokeColor: AppTheme.darkSurface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.neonBlue.withOpacity(0.3),
                  AppTheme.neonBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppTheme.darkSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = data[spot.x.toInt()]['date'] as DateTime;
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)} ${_getUnit()}',
                  Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: AppTheme.neonBlue,
                        fontWeight: FontWeight.bold,
                      ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  DateTime? _getStartDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return now.subtract(const Duration(days: 30));
      case '3 Months':
        return now.subtract(const Duration(days: 90));
      case 'Year':
        return now.subtract(const Duration(days: 365));
      case 'All':
        return null;
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case 'Weight':
        return 'kg';
      case 'Volume':
        return 'kg';
      case 'Reps':
        return 'reps';
      default:
        return '';
    }
  }
}
