import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../common/glass_card.dart';

class MuscleGroupPieChart extends ConsumerWidget {
  const MuscleGroupPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distribution = ref.watch(workoutProvider.notifier).muscleGroupDistribution;

    if (distribution.isEmpty) {
      return const SizedBox();
    }

    // Sort by count descending
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 6, group rest as "Other"
    final top6 = sortedEntries.take(6).toList();
    final othersCount = sortedEntries.skip(6).fold(0, (sum, e) => sum + e.value);
    
    final displayData = [...top6];
    if (othersCount > 0) {
      displayData.add(MapEntry('Other', othersCount));
    }

    final total = displayData.fold(0, (sum, e) => sum + e.value);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MUSCLE GROUP DISTRIBUTION',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textTertiary,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: displayData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final muscle = entry.value.key;
                        final count = entry.value.value;
                        final percentage = (count / total * 100);
                        final color = _getColorForIndex(index);

                        return PieChartSectionData(
                          value: count.toDouble(),
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: color,
                          radius: 50,
                          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Legend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final muscle = entry.value.key;
                    final count = entry.value.value;
                    final color = _getColorForIndex(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              muscle,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$count',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonPurple,
      AppTheme.successGreen,
      AppTheme.warningOrange,
      AppTheme.accentGold,
      AppTheme.dangerRed,
      AppTheme.textTertiary,
    ];
    return colors[index % colors.length];
  }
}
