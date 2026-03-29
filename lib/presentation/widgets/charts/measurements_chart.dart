import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../common/glass_card.dart';

class MeasurementsChart extends ConsumerStatefulWidget {
  const MeasurementsChart({super.key});

  @override
  ConsumerState<MeasurementsChart> createState() => _MeasurementsChartState();
}

class _MeasurementsChartState extends ConsumerState<MeasurementsChart> {
  // The measurement field currently shown in the chart
  String _selectedField = 'Waist';

  // Color per field — same order as AppConstants.bodyMeasurements
  static const _fieldColors = {
    'Chest': AppTheme.neonBlue,
    'Waist': AppTheme.dangerRed,
    'Shoulders': AppTheme.neonPurple,
    'Arms': AppTheme.successGreen,
    'Forearms': AppTheme.accentGold,
    'Thighs': AppTheme.warningOrange,
    'Calves': Color(0xFF00BCD4),
    'Neck': Color(0xFFE91E63),
    'Body Fat %': AppTheme.accentGold,
  };

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(measurementRepositoryProvider);
    final data = repo.getMeasurementChartData(_selectedField);
    final color = _fieldColors[_selectedField] ?? AppTheme.neonBlue;
    final unit = _selectedField == 'Body Fat %' ? '%' : 'cm';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'MEASUREMENT TRENDS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textTertiary,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 12),

          // Field selector chips — horizontally scrollable
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: AppConstants.bodyMeasurements.map((field) {
                final isSelected = _selectedField == field;
                final c = _fieldColors[field] ?? AppTheme.neonBlue;
                return GestureDetector(
                  onTap: () => setState(() => _selectedField = field),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? c
                            : AppTheme.textTertiary.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      field,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                isSelected ? c : AppTheme.textTertiary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Stats row or empty message
          if (data.length >= 2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(context, 'Latest',
                    '${(data.last['value'] as double).toStringAsFixed(1)}$unit',
                    color),
                _stat(context, 'First',
                    '${(data.first['value'] as double).toStringAsFixed(1)}$unit',
                    AppTheme.textSecondary),
                _stat(
                  context,
                  'Change',
                  () {
                    final diff = (data.last['value'] as double) -
                        (data.first['value'] as double);
                    return '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}$unit';
                  }(),
                  () {
                    final diff = (data.last['value'] as double) -
                        (data.first['value'] as double);
                    // For waist/body fat, going down is good (red→green flip)
                    final lowerIsBetter =
                        _selectedField == 'Waist' ||
                        _selectedField == 'Body Fat %';
                    return diff == 0
                        ? AppTheme.textTertiary
                        : (lowerIsBetter
                            ? (diff < 0
                                ? AppTheme.successGreen
                                : AppTheme.dangerRed)
                            : (diff > 0
                                ? AppTheme.successGreen
                                : AppTheme.dangerRed));
                  }(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(data, color, unit),
            ),
          ] else if (data.length == 1) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      '${(data.first['value'] as double).toStringAsFixed(1)}$unit',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log at least 2 entries to see the trend chart',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No $_selectedField data yet.\nAdd measurements to see your trend.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(BuildContext ctx, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, style: Theme.of(ctx).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildChart(
      List<Map<String, dynamic>> data, Color color, String unit) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i]['value'] as double)));
    }

    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPad = yRange > 0 ? yRange * 0.2 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yRange > 0 ? yRange / 4 : 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppTheme.glassBlue.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (data.length / 5).ceilToDouble().clamp(1, 999),
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('M/d').format(data[i]['date'] as DateTime),
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
        minY: minY - yPad,
        maxY: maxY + yPad,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                radius: (i == 0 || i == spots.length - 1) ? 5 : 3.5,
                color: (i == 0 || i == spots.length - 1)
                    ? AppTheme.accentGold
                    : color,
                strokeWidth: 1.5,
                strokeColor: AppTheme.darkSurface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.darkSurface,
            getTooltipItems: (spots) => spots.map((s) {
              final date = data[s.x.toInt()]['date'] as DateTime;
              return LineTooltipItem(
                '${DateFormat('MMM d').format(date)}\n${s.y.toStringAsFixed(1)}$unit',
                Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
