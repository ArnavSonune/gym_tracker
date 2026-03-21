import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/photo_log_model.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/glow_button.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/charts/weight_progress_chart.dart';
import '../widgets/charts/exercise_progress_chart.dart';

class ProgressHubScreen extends ConsumerStatefulWidget {
  const ProgressHubScreen({super.key});
  @override
  ConsumerState<ProgressHubScreen> createState() => _ProgressHubScreenState();
}

class _ProgressHubScreenState extends ConsumerState<ProgressHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: Text('PROGRESS HUB',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonBlue, letterSpacing: 2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonBlue,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: AppTheme.textTertiary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'WEIGHT'),
            Tab(text: 'EXERCISES'),
            Tab(text: 'MEASUREMENTS'),
            Tab(text: 'PHOTOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WeightTab(),
          _ExercisesTab(),
          _MeasurementsTab(),
          _PhotosTab(),
        ],
      ),
    );
  }
}

// ─── WEIGHT TAB ───────────────────────────────────────────────────────────────

class _WeightTab extends ConsumerStatefulWidget {
  const _WeightTab();
  @override
  ConsumerState<_WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends ConsumerState<_WeightTab> {
  @override
  Widget build(BuildContext context) {
    final weightState = ref.watch(weightProvider);
    final weightNotifier = ref.watch(weightProvider.notifier);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Current',
                      value: weightNotifier.currentWeight != null
                          ? '${weightNotifier.currentWeight!.toStringAsFixed(1)} kg'
                          : '-- kg',
                      icon: Icons.monitor_weight_outlined,
                      color: AppTheme.neonBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Starting',
                      value: weightNotifier.startingWeight != null
                          ? '${weightNotifier.startingWeight!.toStringAsFixed(1)} kg'
                          : '-- kg',
                      icon: Icons.flag_outlined,
                      color: AppTheme.neonPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Change',
                      value: weightNotifier.totalWeightChange != null
                          ? '${weightNotifier.totalWeightChange! >= 0 ? '+' : ''}${weightNotifier.totalWeightChange!.toStringAsFixed(1)} kg'
                          : '-- kg',
                      icon: Icons.trending_up,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Weekly Avg',
                      value: weightNotifier.weeklyAverageChange != null
                          ? '${weightNotifier.weeklyAverageChange! >= 0 ? '+' : ''}${weightNotifier.weeklyAverageChange!.toStringAsFixed(2)} kg'
                          : '-- kg',
                      icon: Icons.show_chart,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              GlowButton(
                label: 'LOG WEIGHT',
                icon: Icons.add,
                width: double.infinity,
                onTap: () => _showAddWeightDialog(context),
              ),

              const SizedBox(height: 16),

              // Weight chart
              const WeightProgressChart(),

              const SizedBox(height: 16),

              if (weightState.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      AppConstants.emptyWeightMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else ...[
                Text('HISTORY',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary, letterSpacing: 2)),
                const SizedBox(height: 10),
                ...weightState.reversed.take(20).toList().asMap().entries.map(
                  (entry) {
                    final log = entry.value;
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppUtils.formatDate(log.date),
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              if (log.notes != null)
                                Text(log.notes!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${log.weightKg.toStringAsFixed(1)} kg',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppTheme.neonBlue),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ref
                                    .read(weightProvider.notifier)
                                    .deleteWeightLog(log.id),
                                child: const Icon(Icons.close,
                                    size: 16, color: AppTheme.textTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: entry.key * 30),
                        duration: 250.ms);
                  },
                ),
              ],
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text('Log Weight',
            style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            labelStyle: TextStyle(color: AppTheme.textTertiary),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final w = double.tryParse(ctrl.text);
              if (w != null && w > 0) {
                ref.read(weightProvider.notifier).addWeightLog(
                      date: DateTime.now(),
                      weightKg: w,
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: AppTheme.neonBlue)),
          ),
        ],
      ),
    );
  }
}

// ─── EXERCISES TAB ────────────────────────────────────────────────────────────

class _ExercisesTab extends ConsumerStatefulWidget {
  const _ExercisesTab();
  @override
  ConsumerState<_ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends ConsumerState<_ExercisesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseProvider);
    final filtered = _query.isEmpty
        ? exercises
        : exercises
            .where((e) =>
                e.name.toLowerCase().contains(_query.toLowerCase()) ||
                e.muscleGroup.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No exercises found.',
                      style: Theme.of(context).textTheme.bodyMedium))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final ex = filtered[i];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      onTap: () => _showExerciseDetail(context, ex.name),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.neonPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fitness_center,
                                color: AppTheme.neonPurple, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall),
                                Text(ex.muscleGroup,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                          if (ex.prWeight > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${ex.prWeight}kg',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                            color: AppTheme.accentGold)),
                                Text('PR',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppTheme.accentGold)),
                              ],
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.textTertiary, size: 18),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: i * 20),
                        duration: 250.ms);
                  },
                ),
        ),
      ],
    );
  }

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(exerciseName: exerciseName),
    );
  }
}

class _ExerciseDetailSheet extends ConsumerWidget {
  final String exerciseName;
  const _ExerciseDetailSheet({required this.exerciseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseRepo = ref.watch(exerciseRepositoryProvider);
    final exercise = exerciseRepo.getExerciseByName(exerciseName);
    if (exercise == null) return const SizedBox();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: AppTheme.textTertiary,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Text(exercise.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.neonBlue)),
            Text(exercise.muscleGroup,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statTile(context, 'PR WEIGHT',
                      exercise.prWeight > 0
                          ? '${exercise.prWeight}kg'
                          : '--',
                      AppTheme.accentGold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statTile(
                    context,
                    'BEST VOLUME',
                    exercise.bestVolume > 0
                        ? '${exercise.bestVolume.toStringAsFixed(0)}kg'
                        : '--',
                    AppTheme.neonPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _statTile(
                    context,
                    'SESSIONS',
                    '${exercise.totalSessions}',
                    AppTheme.neonBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statTile(
                    context,
                    'LAST SESSION',
                    exercise.lastPerformed != null
                        ? AppUtils.formatRelativeDate(exercise.lastPerformed!)
                        : 'Never',
                    AppTheme.successGreen,
                  ),
                ),
              ],
            ),
            if (exercise.prAchievedDate != null) ...[
              const SizedBox(height: 12),
              GlassCard(
                borderColor: AppTheme.accentGold.withOpacity(0.3),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PR set on ${AppUtils.formatDate(exercise.prAchievedDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentGold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Progress chart
            ExerciseProgressChart(exerciseName: exercise.name),
          ],
        ),
      ),
    );
  }

  Widget _statTile(
      BuildContext ctx, String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(ctx)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(ctx)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.textTertiary, letterSpacing: 1)),
        ],
      ),
    );
  }
}

// ─── MEASUREMENTS TAB ─────────────────────────────────────────────────────────

class _MeasurementsTab extends ConsumerWidget {
  const _MeasurementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(measurementProvider.notifier).latest;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GlowButton(
                label: 'ADD MEASUREMENTS',
                icon: Icons.add,
                width: double.infinity,
                onTap: () => _showAddMeasurementSheet(context, ref),
              ),
              const SizedBox(height: 16),
              if (latest != null) ...[
                Text('LATEST MEASUREMENTS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary, letterSpacing: 2)),
                const SizedBox(height: 10),
                GlassCard(
                  child: Column(
                    children: latest.toMeasurementMap().entries
                        .where((e) => e.value != null)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  Text(
                                    e.key == 'Body Fat %'
                                        ? '${e.value!.toStringAsFixed(1)}%'
                                        : '${e.value!.toStringAsFixed(1)} cm',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                            color: AppTheme.neonBlue),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      AppConstants.emptyMeasurementsMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  void _showAddMeasurementSheet(BuildContext context, WidgetRef ref) {
    final controllers = <String, TextEditingController>{
      for (final m in AppConstants.bodyMeasurements)
        m: TextEditingController()
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.textTertiary,
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Text('LOG MEASUREMENTS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.neonBlue)),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    ...AppConstants.bodyMeasurements.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: controllers[m],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText:
                                  '$m ${m == 'Body Fat %' ? '(%)' : '(cm)'} — optional',
                              labelStyle: const TextStyle(
                                  color: AppTheme.textTertiary),
                            ),
                          ),
                        )),
                    const SizedBox(height: 12),
                    GlowButton(
                      label: 'SAVE MEASUREMENTS',
                      width: double.infinity,
                      onTap: () async {
                        double? parse(String key) =>
                            double.tryParse(controllers[key]!.text);
                        await ref
                            .read(measurementProvider.notifier)
                            .addMeasurement(
                              date: DateTime.now(),
                              chest: parse('Chest'),
                              waist: parse('Waist'),
                              shoulders: parse('Shoulders'),
                              arms: parse('Arms'),
                              forearms: parse('Forearms'),
                              thighs: parse('Thighs'),
                              calves: parse('Calves'),
                              neck: parse('Neck'),
                              bodyFatPercentage: parse('Body Fat %'),
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PHOTOS TAB ───────────────────────────────────────────────────────────────

class _PhotosTab extends ConsumerStatefulWidget {
  const _PhotosTab();
  @override
  ConsumerState<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<_PhotosTab> {
  bool _compareMode = false;
  PhotoLogModel? _comparePhoto1;
  PhotoLogModel? _comparePhoto2;

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(photoProvider);

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: GlowButton(
                  label: 'ADD PHOTO',
                  icon: Icons.add_a_photo,
                  onTap: () => _pickPhoto(context),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _compareMode = !_compareMode;
                  _comparePhoto1 = null;
                  _comparePhoto2 = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: _compareMode
                        ? AppTheme.neonPurple.withOpacity(0.2)
                        : AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _compareMode
                          ? AppTheme.neonPurple
                          : AppTheme.glassBlue,
                    ),
                  ),
                  child: Text(
                    'COMPARE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _compareMode
                              ? AppTheme.neonPurple
                              : AppTheme.textTertiary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_compareMode && _comparePhoto1 != null && _comparePhoto2 != null)
          _buildCompareView()
        else if (photos.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                AppConstants.emptyPhotosMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) {
                final photo = photos[i];
                final isSelected = _compareMode &&
                    (_comparePhoto1?.id == photo.id ||
                        _comparePhoto2?.id == photo.id);

                return GestureDetector(
                  onTap: () {
                    if (_compareMode) {
                      setState(() {
                        if (_comparePhoto1 == null) {
                          _comparePhoto1 = photo;
                        } else if (_comparePhoto2 == null &&
                            _comparePhoto1?.id != photo.id) {
                          _comparePhoto2 = photo;
                        }
                      });
                    } else {
                      _showPhotoDetail(context, photo);
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(photo.localFilePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.darkSurface,
                            child: const Icon(Icons.broken_image,
                                color: AppTheme.textTertiary),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.neonPurple.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: AppTheme.neonPurple, width: 2),
                          ),
                          child: const Icon(Icons.check_circle,
                              color: AppTheme.neonPurple),
                        ),
                    ],
                  ),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 20),
                    duration: 200.ms);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCompareView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(AppUtils.formatDate(_comparePhoto1!.date),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_comparePhoto1!.localFilePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Text(AppUtils.formatDate(_comparePhoto2!.date),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_comparePhoto2!.localFilePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Add Photo'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              child: const Text('Camera')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              child: const Text('Gallery')),
        ],
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    await ref.read(photoProvider.notifier).addPhoto(
          sourcePath: picked.path,
          date: DateTime.now(),
        );
  }

  void _showPhotoDetail(BuildContext context, PhotoLogModel photo) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(photo.localFilePath)),
            ),
            const SizedBox(height: 8),
            Text(AppUtils.formatDate(photo.date),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(photoProvider.notifier).deletePhoto(photo.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete, color: AppTheme.dangerRed),
              label: const Text('Delete',
                  style: TextStyle(color: AppTheme.dangerRed)),
            ),
          ],
        ),
      ),
    );
  }
}
