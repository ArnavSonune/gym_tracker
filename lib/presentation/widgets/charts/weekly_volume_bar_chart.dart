import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../common/glass_card.dart';

class WeeklyVolumeBarChart extends ConsumerWidget {
  const WeeklyVolumeBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumeByDay = ref.watch(workoutProvider.notifier).weeklyVolumeByDay;
    
    if (volumeByDay.isEmpty) {
      return const SizedBox();
    }

    // Sort by date
    final sortedEntries = volumeByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY VOLUME',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textTertiary,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                '${(sortedEntries.fold(0.0, (sum, e) => sum + e.value) / 1000).toStringAsFixed(1)}k kg',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.neonPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedEntries
                        .map((e) => e.value)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.darkSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = sortedEntries[groupIndex];
                      return BarTooltipItem(
                        '${DateFormat('MMM d').format(entry.key)}\n${(entry.value / 1000).toStringAsFixed(1)}k kg',
                        Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: AppTheme.neonPurple,
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
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
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox();
                        }
                        final date = sortedEntries[index].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('EEE').format(date).substring(0, 1),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.textTertiary,
                                  fontSize: 10,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.glassBlue.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final volume = entry.value.value;
                  final isToday = entry.value.key.day == DateTime.now().day;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: volume,
                        color: isToday ? AppTheme.neonBlue : AppTheme.neonPurple,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            (isToday ? AppTheme.neonBlue : AppTheme.neonPurple)
                                .withOpacity(0.7),
                            isToday ? AppTheme.neonBlue : AppTheme.neonPurple,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
