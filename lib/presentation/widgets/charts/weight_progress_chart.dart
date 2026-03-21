import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../common/glass_card.dart';

class WeightProgressChart extends ConsumerStatefulWidget {
  const WeightProgressChart({super.key});

  @override
  ConsumerState<WeightProgressChart> createState() => _WeightProgressChartState();
}

class _WeightProgressChartState extends ConsumerState<WeightProgressChart> {
  String _selectedRange = AppConstants.chartRanges[2]; // 3 Months default

  @override
  Widget build(BuildContext context) {
    final weightRepo = ref.watch(weightRepositoryProvider);
    final startDate = _getStartDate();
    final data = weightRepo.getWeightChartData(startDate: startDate);

    if (data.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 250,
          child: Center(
            child: Text(
              'No weight data available.\nStart logging your weight!',
              textAlign: TextAlign.center,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEIGHT PROGRESS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textTertiary,
                      letterSpacing: 2,
                    ),
              ),
              _buildRangeSelector(),
            ],
          ),
          const SizedBox(height: 8),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                'Current',
                '${data.last['value'].toStringAsFixed(1)} kg',
                AppTheme.neonBlue,
              ),
              _buildStat(
                context,
                'Starting',
                '${data.first['value'].toStringAsFixed(1)} kg',
                AppTheme.textSecondary,
              ),
              _buildStat(
                context,
                'Change',
                '${data.last['value'] - data.first['value'] >= 0 ? '+' : ''}${(data.last['value'] - data.first['value']).toStringAsFixed(1)} kg',
                (data.last['value'] - data.first['value']) >= 0
                    ? AppTheme.successGreen
                    : AppTheme.dangerRed,
              ),
            ],
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

  Widget _buildRangeSelector() {
    return PopupMenuButton<String>(
      initialValue: _selectedRange,
      color: AppTheme.darkSurface,
      onSelected: (value) => setState(() => _selectedRange = value),
      itemBuilder: (context) => AppConstants.chartRanges
          .map((range) => PopupMenuItem(
                value: range,
                child: Text(
                  range,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: range == _selectedRange
                            ? AppTheme.neonBlue
                            : AppTheme.textPrimary,
                      ),
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.neonBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedRange,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.neonBlue,
                  ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppTheme.neonBlue, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange > 0 ? yRange * 0.15 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yRange > 0 ? yRange / 4 : 1,
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
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 10,
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
                // Highlight first and last points
                final isFirstOrLast = index == 0 || index == spots.length - 1;
                return FlDotCirclePainter(
                  radius: isFirstOrLast ? 5 : 4,
                  color: isFirstOrLast ? AppTheme.accentGold : AppTheme.neonBlue,
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
                  '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)} kg',
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
        return now.subtract(const Duration(days: 90));
    }
  }
}
