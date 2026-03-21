import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/system_progress_bar.dart';
import '../widgets/animations/achievement_checker.dart';
import '../widgets/charts/weekly_volume_bar_chart.dart';
import '../widgets/charts/muscle_group_pie_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakProvider.notifier).checkStreak();
      // Silently check for any newly unlocked achievements
      AchievementChecker(ref).checkAllAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final workoutNotifier = ref.watch(workoutProvider.notifier);
    final cardioNotifier = ref.watch(cardioProvider.notifier);
    final streak = ref.watch(streakProvider);
    final insights = ref.watch(dashboardInsightsProvider);
    final weightNotifier = ref.watch(weightProvider.notifier);

    final level = user?.currentLevel ?? 1;
    final totalXP = user?.totalXP ?? 0;
    final rank = AppUtils.getRank(level);
    final rankColor = AppTheme.getRankColor(rank);
    final xpProgress = AppUtils.getLevelProgress(totalXP, level);
    final xpForNext = AppUtils.getTotalXPForLevel(level + 1) - AppUtils.getTotalXPForLevel(level);
    final xpIntoCurrentLevel = totalXP - AppUtils.getTotalXPForLevel(level);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppTheme.darkBackground,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYSTEM STATUS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.neonBlue,
                        letterSpacing: 2,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rankColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.military_tech, color: rankColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$rank-RANK',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Hunter Profile Card ────────────────────────────────────
                GlassCard(
                  borderColor: AppTheme.neonBlue.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                              ),
                              boxShadow: AppTheme.glowShadow(blurRadius: 12),
                            ),
                            child: Center(
                              child: Text(
                                (user?.name.isNotEmpty == true)
                                    ? user!.name[0].toUpperCase()
                                    : 'H',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Hunter',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  AppUtils.getRankTitle(level),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: rankColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'LVL',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.textTertiary,
                                      letterSpacing: 1,
                                    ),
                              ),
                              Text(
                                '$level',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SystemProgressBar(
                        progress: xpProgress,
                        foregroundColor: AppTheme.neonBlue,
                        height: 12,
                        label: 'XP PROGRESS',
                        valueLabel: '$totalXP XP',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${xpForNext - xpIntoCurrentLevel} XP needed for Level ${level + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // ── Stats Grid ─────────────────────────────────────────────
                Text(
                  'HUNTER STATS',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5, // VERY WIDE = SHORT cards that fit all 4 on screen
                  children: [
                    StatCard(
                      label: 'Current Weight',
                      value: weightNotifier.currentWeight != null
                          ? '${weightNotifier.currentWeight!.toStringAsFixed(1)} kg'
                          : '-- kg',
                      subtitle: weightNotifier.weightChangeLast7Days != null
                          ? '${weightNotifier.weightChangeLast7Days! >= 0 ? '+' : ''}${weightNotifier.weightChangeLast7Days!.toStringAsFixed(1)} kg'
                          : null,
                      icon: Icons.monitor_weight_outlined,
                      color: AppTheme.neonBlue,
                    ),
                    StatCard(
                      label: 'Total Workouts',
                      value: '${workoutNotifier.totalWorkouts}',
                      subtitle: '${workoutNotifier.workoutsThisWeek} this week',
                      icon: Icons.fitness_center,
                      color: AppTheme.neonPurple,
                    ),
                    StatCard(
                      label: 'Cardio Sessions',
                      value: '${cardioNotifier.totalCardio}',
                      icon: Icons.directions_run,
                      color: AppTheme.successGreen,
                    ),
                    StatCard(
                      label: 'Current Streak',
                      value: '${streak.currentStreak}d',
                      subtitle: 'Best: ${streak.highestStreak}d',
                      icon: Icons.local_fire_department,
                      color: AppTheme.warningOrange,
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // ── System Insights ────────────────────────────────────────
                Text(
                  'SYSTEM INSIGHTS',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 10),

                ...insights.asMap().entries.map((entry) {
                  final isAlert = entry.value.startsWith('System Alert');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SystemAlertCard(
                      message: entry.value,
                      color: isAlert ? AppTheme.warningOrange : AppTheme.neonBlue,
                      icon: isAlert ? Icons.warning_amber_outlined : Icons.terminal,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 200 + entry.key * 80),
                          duration: 300.ms,
                        ),
                  );
                }),

                const SizedBox(height: 20),

                // ── Weekly Summary Card ────────────────────────────────────
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THIS WEEK',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.textTertiary,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _weekStat(context, '${workoutNotifier.workoutsThisWeek}',
                              'Workouts', AppTheme.neonBlue),
                          _divider(),
                          _weekStat(
                            context,
                            workoutNotifier.weeklyVolumeByDay.values
                                        .fold(0.0, (a, b) => a + b) >
                                    0
                                ? '${(workoutNotifier.weeklyVolumeByDay.values.fold(0.0, (a, b) => a + b) / 1000).toStringAsFixed(1)}k'
                                : '0',
                            'Vol (kg)',
                            AppTheme.neonPurple,
                          ),
                          _divider(),
                          _weekStat(
                            context,
                            AppUtils.formatDuration(
                                cardioNotifier.totalMinutes),
                            'Cardio',
                            AppTheme.successGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // ── Charts Section ─────────────────────────────────────────
                if (workoutNotifier.totalWorkouts > 0) ...[
                  Text(
                    'PERFORMANCE CHARTS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const WeeklyVolumeBarChart(),
                  const SizedBox(height: 10),
                  const MuscleGroupPieChart(),
                ],

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekStat(
      BuildContext ctx, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(ctx).textTheme.bodySmall),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: AppTheme.glassWhite,
      );
}