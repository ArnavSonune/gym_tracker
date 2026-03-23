import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/achievement_model.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/glow_button.dart';
import '../widgets/common/app_snackbar.dart';
import '../widgets/animations/xp_gain_popup.dart';
import '../widgets/animations/level_up_animation.dart';
import '../widgets/animations/achievement_popup.dart';

class WorkoutLogScreen extends ConsumerStatefulWidget {
  const WorkoutLogScreen({super.key});
  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('TRAINING LOG',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonBlue, letterSpacing: 2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonBlue,
          indicatorWeight: 2,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: AppTheme.textTertiary,
          tabs: const [
            Tab(text: 'STRENGTH'),
            Tab(text: 'CARDIO'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabController.index == 0
            ? _showStrengthForm(context)
            : _showCardioForm(context),
        backgroundColor: AppTheme.neonBlue,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0 ? 'LOG WORKOUT' : 'LOG CARDIO',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StrengthHistoryTab(),
          _CardioHistoryTab(),
        ],
      ),
    );
  }

  void _showStrengthForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _StrengthLogForm(),
    );
  }

  void _showCardioForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CardioLogForm(),
    );
  }
}

// ─── STRENGTH HISTORY TAB ─────────────────────────────────────────────────────

class _StrengthHistoryTab extends ConsumerStatefulWidget {
  const _StrengthHistoryTab();
  @override
  ConsumerState<_StrengthHistoryTab> createState() => _StrengthHistoryTabState();
}

class _StrengthHistoryTabState extends ConsumerState<_StrengthHistoryTab> {
  final _searchCtrl = TextEditingController();
  String? _selectedMuscle;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(filteredWorkoutsProvider);

    return Column(
      children: [
        // Search + Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (v) => ref
                      .read(workoutSearchQueryProvider.notifier)
                      .state = v,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showMuscleFilter(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedMuscle != null
                        ? AppTheme.neonBlue.withOpacity(0.2)
                        : AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMuscle != null
                          ? AppTheme.neonBlue
                          : AppTheme.glassBlue,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: _selectedMuscle != null
                        ? AppTheme.neonBlue
                        : AppTheme.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_selectedMuscle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.neonBlue.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedMuscle!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppTheme.neonBlue)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedMuscle = null);
                          ref
                              .read(workoutMuscleFilterProvider.notifier)
                              .state = null;
                        },
                        child: const Icon(Icons.close,
                            size: 14, color: AppTheme.neonBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Workout List
        Expanded(
          child: workouts.isEmpty
              ? Center(
                  child: Text(
                    'No workouts found.\nTap + to log your first set!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return _WorkoutListItem(
                      workout: workouts[index],
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showMuscleFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Filter by Muscle',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Muscles'),
                  onTap: () {
                    setState(() => _selectedMuscle = null);
                    ref.read(workoutMuscleFilterProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                ...AppConstants.muscleGroups.map((m) => ListTile(
                      title: Text(m),
                      trailing: _selectedMuscle == m
                          ? const Icon(Icons.check, color: AppTheme.neonBlue)
                          : null,
                      onTap: () {
                        setState(() => _selectedMuscle = m);
                        ref.read(workoutMuscleFilterProvider.notifier).state = m;
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── WORKOUT LIST ITEM ────────────────────────────────────────────────────────

class _WorkoutListItem extends ConsumerWidget {
  final WorkoutModel workout;
  final int index;
  const _WorkoutListItem({required this.workout, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(workout.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.darkSurface,
            title: const Text('Delete Workout?'),
            content: Text('${workout.exerciseName} on ${AppUtils.formatDate(workout.date)}'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete',
                      style: TextStyle(color: AppTheme.dangerRed))),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(workoutProvider.notifier).deleteWorkout(workout.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.dangerRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppTheme.dangerRed),
      ),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 10),
        onTap: () => _showEditForm(context, ref),
        child: Row(
          children: [
            // Muscle icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppTheme.neonPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.exerciseName,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${workout.muscleGroup} · ${AppUtils.formatDate(workout.date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.totalSets} sets · ${workout.totalReps} reps · Max ${workout.maxWeight}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neonBlue,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${workout.totalVolume.toStringAsFixed(0)} kg',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.neonBlue,
                      ),
                ),
                Text('volume',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: index * 40),
            duration: 300.ms,
          ),
    );
  }

  void _showEditForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StrengthLogForm(existingWorkout: workout),
    );
  }
}

// ─── STRENGTH LOG FORM ────────────────────────────────────────────────────────

class _StrengthLogForm extends ConsumerStatefulWidget {
  final WorkoutModel? existingWorkout;
  const _StrengthLogForm({this.existingWorkout});
  @override
  ConsumerState<_StrengthLogForm> createState() => _StrengthLogFormState();
}

class _StrengthLogFormState extends ConsumerState<_StrengthLogForm> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMuscle = AppConstants.muscleGroups.first;
  final _exerciseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_SetEntry> _sets = [_SetEntry()];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingWorkout != null) {
      final w = widget.existingWorkout!;
      _selectedDate = w.date;
      _selectedMuscle = w.muscleGroup;
      _exerciseCtrl.text = w.exerciseName;
      _notesCtrl.text = w.notes ?? '';
      _sets.clear();
      _sets.addAll(w.sets.map((s) => _SetEntry(
            reps: s.reps.toString(),
            weight: s.weight.toString(),
          )));
    }
  }

  @override
  void dispose() {
    _exerciseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingWorkout != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textTertiary,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? 'EDIT WORKOUT' : 'LOG WORKOUT',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.neonBlue)),
                  if (isEditing)
                    GestureDetector(
                      onTap: () async {
                        await ref.read(workoutProvider.notifier)
                            .deleteWorkout(widget.existingWorkout!.id);
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Icon(Icons.delete_outline,
                          color: AppTheme.dangerRed),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // Date Picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.darkerSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBlue),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.neonBlue, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEE, MMM dd yyyy').format(_selectedDate),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Muscle Group
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMuscle,
                    dropdownColor: AppTheme.darkSurface,
                    decoration: const InputDecoration(
                        labelText: 'Muscle Group',
                        labelStyle: TextStyle(color: AppTheme.textTertiary)),
                    items: AppConstants.muscleGroups
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMuscle = v!),
                  ),
                  const SizedBox(height: 12),

                  // Exercise Name
                  TextField(
                    controller: _exerciseCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                      hintText: 'e.g. Bench Press',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SETS',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              letterSpacing: 2, color: AppTheme.textTertiary)),
                      GestureDetector(
                        onTap: () => setState(() => _sets.add(_SetEntry())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.neonBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppTheme.neonBlue.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14, color: AppTheme.neonBlue),
                              SizedBox(width: 4),
                              Text('Add Set',
                                  style: TextStyle(
                                      color: AppTheme.neonBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Set Headers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 36),
                        Expanded(
                            child: Text('REPS',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppTheme.textTertiary))),
                        Expanded(
                            child: Text('WEIGHT (kg)',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppTheme.textTertiary))),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._sets.asMap().entries.map((entry) {
                    final i = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text('${i + 1}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppTheme.neonBlue)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: set.repsCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                    hintText: '0',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: set.weightCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                    hintText: '0.0',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: _sets.length > 1
                                ? GestureDetector(
                                    onTap: () =>
                                        setState(() => _sets.removeAt(i)),
                                    child: const Icon(Icons.remove_circle_outline,
                                        color: AppTheme.dangerRed, size: 20),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Notes
                  TextField(
                    controller: _notesCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GlowButton(
                    label: isEditing ? 'UPDATE WORKOUT' : 'SAVE WORKOUT',
                    width: double.infinity,
                    isLoading: _isLoading,
                    onTap: _saveWorkout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.neonBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveWorkout() async {
    if (_exerciseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an exercise name')));
      return;
    }

    final validSets = _sets
        .where((s) =>
            int.tryParse(s.repsCtrl.text) != null &&
            double.tryParse(s.weightCtrl.text) != null)
        .toList();

    if (validSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one valid set')));
      return;
    }

    setState(() => _isLoading = true);

    final sets = validSets.asMap().entries.map((e) => WorkoutSetModel(
          setNumber: e.key + 1,
          reps: int.parse(e.value.repsCtrl.text),
          weight: double.parse(e.value.weightCtrl.text),
        )).toList();

    if (widget.existingWorkout != null) {
      // ── EDIT PATH ──────────────────────────────────────────────────────────
      // Update the existing workout, then fall through to the single pop below.
      final updated = widget.existingWorkout!.copyWith(
        date: _selectedDate,
        muscleGroup: _selectedMuscle,
        exerciseName: _exerciseCtrl.text.trim(),
        sets: sets,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ref.read(workoutProvider.notifier).updateWorkout(updated);
      // Falls through to the single Navigator.pop() at the bottom ↓
    } else {
      // ── NEW WORKOUT PATH ───────────────────────────────────────────────────
      final workout = await ref.read(workoutProvider.notifier).addWorkout(
        date: _selectedDate,
        muscleGroup: _selectedMuscle,
        exerciseName: _exerciseCtrl.text.trim(),
        sets: sets,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      // Award XP and check level up
      final didLevelUp = await ref
          .read(userProvider.notifier)
          .addXPAndCheckLevelUp(workout.xpEarned);

      // Record streak
      await ref.read(streakProvider.notifier).recordWorkout(_selectedDate);

      // Check first-workout achievement
      final achievement = await ref
          .read(achievementProvider.notifier)
          .tryUnlock(AppConstants.firstWorkoutAchievement);

      setState(() => _isLoading = false);

      if (!mounted) return;

      // ── CRITICAL FIX: close the bottom sheet ONCE, then return early. ──
      // Previously there was a second Navigator.pop() after this else-block
      // which fired unconditionally, causing "popped the last page" crash /
      // blank screen. The return below prevents that second pop from ever
      // being reached on the new-workout path.
      Navigator.pop(context);

      // ── OVERLAY ANIMATIONS (wired up — were previously just snackbars) ──
      // Capture context-dependent objects before any async gaps.
      final overlayContext = context;
      final newLevel = ref.read(userProvider)?.currentLevel ?? 1;

      // 1. XP gain floats up immediately
      XPGainPopup.show(overlayContext, workout.xpEarned);

      // 2. Level-up fullscreen overlay after XP animation settles
      if (didLevelUp) {
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            LevelUpAnimation.show(overlayContext, newLevel: newLevel);
          }
        });
      }

      // 3. Achievement overlay after level-up (or after XP if no level-up)
      if (achievement != null) {
        Future.delayed(Duration(milliseconds: didLevelUp ? 5200 : 1600), () {
          if (mounted) {
            AchievementUnlockPopup.show(
              overlayContext,
              achievement: achievement,
            );
          }
        });
      }

      return; // ← EXIT EARLY — prevents the pop below from firing twice.
    }

    // ── SINGLE POP for the edit path only ─────────────────────────────────
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }
}

// ─── CARDIO HISTORY TAB ───────────────────────────────────────────────────────

class _CardioHistoryTab extends ConsumerWidget {
  const _CardioHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardioList = ref.watch(cardioProvider);
    if (cardioList.isEmpty) {
      return Center(
        child: Text(
          'No cardio sessions logged.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: cardioList.length,
      itemBuilder: (context, i) {
        final c = cardioList[i];
        return Dismissible(
          key: Key(c.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) =>
              ref.read(cardioProvider.notifier).deleteCardio(c.id),
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: AppTheme.dangerRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: AppTheme.dangerRed),
          ),
          child: GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_run,
                      color: AppTheme.successGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.cardioType,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(AppUtils.formatDate(c.date),
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        AppUtils.formatDuration(c.durationMinutes) +
                            (c.distanceKm != null
                                ? ' · ${c.distanceKm!.toStringAsFixed(1)} km'
                                : ''),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.successGreen),
                      ),
                    ],
                  ),
                ),
                if (c.caloriesBurned != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${c.caloriesBurned}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppTheme.warningOrange)),
                      Text('kcal',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ).animate().fadeIn(
                delay: Duration(milliseconds: i * 40), duration: 300.ms),
        );
      },
    );
  }
}

// ─── CARDIO LOG FORM ──────────────────────────────────────────────────────────

class _CardioLogForm extends ConsumerStatefulWidget {
  const _CardioLogForm();
  @override
  ConsumerState<_CardioLogForm> createState() => _CardioLogFormState();
}

class _CardioLogFormState extends ConsumerState<_CardioLogForm> {
  DateTime _selectedDate = DateTime.now();
  String _cardioType = AppConstants.cardioTypes.first;
  final _durationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _caloriesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text('LOG CARDIO',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.successGreen)),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.darkerSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBlue),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.neonBlue, size: 18),
                          const SizedBox(width: 10),
                          Text(
                              DateFormat('EEE, MMM dd yyyy')
                                  .format(_selectedDate),
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _cardioType,
                    dropdownColor: AppTheme.darkSurface,
                    decoration: const InputDecoration(
                        labelText: 'Cardio Type',
                        labelStyle: TextStyle(color: AppTheme.textTertiary)),
                    items: AppConstants.cardioTypes
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setState(() => _cardioType = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes) *',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _distanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Distance (km) — optional',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Calories burned — optional',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Notes — optional',
                      labelStyle: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlowButton(
                    label: 'SAVE CARDIO',
                    color: AppTheme.successGreen,
                    width: double.infinity,
                    isLoading: _isLoading,
                    onTap: _saveCardio,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: AppTheme.neonBlue)),
          child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveCardio() async {
    final duration = int.tryParse(_durationCtrl.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid duration')));
      return;
    }
    setState(() => _isLoading = true);
    final cardio = await ref.read(cardioProvider.notifier).addCardio(
      date: _selectedDate,
      cardioType: _cardioType,
      durationMinutes: duration,
      distanceKm: double.tryParse(_distanceCtrl.text),
      caloriesBurned: int.tryParse(_caloriesCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    
    // Award XP and check level up
    final didLevelUp = await ref
        .read(userProvider.notifier)
        .addXPAndCheckLevelUp(cardio.xpEarned);
    
    await ref.read(streakProvider.notifier).recordWorkout(_selectedDate);

    // Check 10 cardio achievement
    final cardioCount = ref.read(cardioProvider.notifier).totalCardio;
    final achievement = cardioCount >= 10
        ? await ref
            .read(achievementProvider.notifier)
            .tryUnlock(AppConstants.tenCardioAchievement)
        : null;
    
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);

      final overlayContext = context;
      final newLevel = ref.read(userProvider)?.currentLevel ?? 1;

      // 1. XP gain popup
      XPGainPopup.show(overlayContext, cardio.xpEarned);

      // 2. Level-up overlay
      if (didLevelUp) {
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            LevelUpAnimation.show(overlayContext, newLevel: newLevel);
          }
        });
      }

      // 3. Achievement overlay
      if (achievement != null) {
        Future.delayed(Duration(milliseconds: didLevelUp ? 5200 : 1600), () {
          if (mounted) {
            AchievementUnlockPopup.show(
              overlayContext,
              achievement: achievement,
            );
          }
        });
      }
    }
  }
}

// ─── HELPER: Set Entry ────────────────────────────────────────────────────────

class _SetEntry {
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;
  _SetEntry({String reps = '', String weight = ''})
      : repsCtrl = TextEditingController(text: reps),
        weightCtrl = TextEditingController(text: weight);
}
