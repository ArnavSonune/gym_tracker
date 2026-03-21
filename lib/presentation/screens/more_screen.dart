import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/glow_button.dart';
import 'settings_screen.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});
  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('MORE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonBlue, letterSpacing: 2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonBlue,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: AppTheme.textTertiary,
          tabs: const [
            Tab(text: 'CALCULATORS'),
            Tab(text: 'ACHIEVEMENTS'),
            Tab(text: 'PROFILE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CalculatorsTab(),
          _AchievementsTab(),
          _ProfileTab(),
        ],
      ),
    );
  }
}

// ─── CALCULATORS TAB ──────────────────────────────────────────────────────────

class _CalculatorsTab extends StatefulWidget {
  const _CalculatorsTab();
  @override
  State<_CalculatorsTab> createState() => _CalculatorsTabState();
}

class _CalculatorsTabState extends State<_CalculatorsTab> {
  // Shared inputs
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  bool _isMale = true;
  String _activityLevel = AppConstants.activityMultipliers.keys.first;
  String _goal = 'Maintenance';

  // Results
  double? _bmr, _tdee, _bmi, _protein;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final age = int.tryParse(_ageCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final height = double.tryParse(_heightCtrl.text);

    if (age == null || weight == null || height == null) return;

    final bmr = AppUtils.calculateBMR(
      weightKg: weight,
      heightCm: height,
      age: age,
      isMale: _isMale,
    );
    final actMultiplier =
        AppConstants.activityMultipliers[_activityLevel] ?? 1.2;

    setState(() {
      _bmr = bmr;
      _tdee = AppUtils.calculateTDEE(bmr: bmr, activityMultiplier: actMultiplier);
      _bmi = AppUtils.calculateBMI(weightKg: weight, heightCm: height);
      _protein = AppUtils.calculateProtein(weightKg: weight, goal: _goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Panel
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SYSTEM INPUTS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary, letterSpacing: 2)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                            labelText: 'Age',
                            labelStyle: TextStyle(color: AppTheme.textTertiary)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            labelStyle: TextStyle(color: AppTheme.textTertiary)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      labelStyle: TextStyle(color: AppTheme.textTertiary)),
                ),
                const SizedBox(height: 14),

                // Gender Toggle
                Row(
                  children: [
                    Text('Gender: ',
                        style: Theme.of(context).textTheme.bodySmall),
                    _genderBtn('Male', true),
                    const SizedBox(width: 8),
                    _genderBtn('Female', false),
                  ],
                ),
                const SizedBox(height: 12),

                // Activity Level
                DropdownButtonFormField<String>(
                  initialValue: _activityLevel,
                  dropdownColor: AppTheme.darkSurface,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Activity Level',
                      labelStyle: TextStyle(color: AppTheme.textTertiary)),
                  items: AppConstants.activityMultipliers.keys
                      .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(k,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setState(() => _activityLevel = v!),
                ),
                const SizedBox(height: 12),

                // Goal
                DropdownButtonFormField<String>(
                  initialValue: _goal,
                  dropdownColor: AppTheme.darkSurface,
                  decoration: const InputDecoration(
                      labelText: 'Goal',
                      labelStyle: TextStyle(color: AppTheme.textTertiary)),
                  items: ['Cutting', 'Maintenance', 'Bulking']
                      .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary))))
                      .toList(),
                  onChanged: (v) => setState(() => _goal = v!),
                ),
                const SizedBox(height: 16),

                GlowButton(
                  label: 'CALCULATE',
                  width: double.infinity,
                  icon: Icons.calculate,
                  onTap: _calculate,
                ),
              ],
            ),
          ),

          if (_bmr != null) ...[
            const SizedBox(height: 16),
            Text('SYSTEM CALCULATIONS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textTertiary, letterSpacing: 2)),
            const SizedBox(height: 10),
            _resultPanel('BMR', '${_bmr!.toStringAsFixed(0)} kcal/day',
                'Basal Metabolic Rate — calories at rest', AppTheme.neonBlue),
            const SizedBox(height: 8),
            _resultPanel('TDEE', '${_tdee!.toStringAsFixed(0)} kcal/day',
                'Total Daily Energy Expenditure', AppTheme.neonPurple),
            const SizedBox(height: 8),
            _resultPanel(
              'BMI',
              '${_bmi!.toStringAsFixed(1)} — ${AppUtils.getBMICategory(_bmi!)}',
              'Body Mass Index',
              _bmi! < 18.5 || _bmi! >= 30 ? AppTheme.warningOrange : AppTheme.successGreen,
            ),
            const SizedBox(height: 8),
            _resultPanel(
              'PROTEIN TARGET',
              '${_protein!.toStringAsFixed(0)}g/day',
              'Recommended daily protein for $_goal',
              AppTheme.accentGold,
            ),
            const SizedBox(height: 8),
            GlassCard(
              borderColor: AppTheme.neonBlue.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CALORIE PLANNER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  _caloriePlanRow(context, 'Maintenance', _tdee!, AppTheme.neonBlue),
                  _caloriePlanRow(context, 'Cut (−500)',
                      _tdee! - 500, AppTheme.dangerRed),
                  _caloriePlanRow(context, 'Lean Bulk (+250)',
                      _tdee! + 250, AppTheme.successGreen),
                  _caloriePlanRow(context, 'Bulk (+500)',
                      _tdee! + 500, AppTheme.warningOrange),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _genderBtn(String label, bool male) {
    final selected = _isMale == male;
    return GestureDetector(
      onTap: () => setState(() => _isMale = male),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonBlue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.neonBlue : AppTheme.textTertiary.withOpacity(0.3),
          ),
        ),
        child: Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? AppTheme.neonBlue : AppTheme.textTertiary)),
      ),
    );
  }

  Widget _resultPanel(
      String label, String value, String subtitle, Color color) {
    return GlassCard(
      borderColor: color.withOpacity(0.3),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textTertiary, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _caloriePlanRow(
      BuildContext ctx, String label, double cals, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
          Text('${cals.toStringAsFixed(0)} kcal',
              style: Theme.of(ctx)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── ACHIEVEMENTS TAB ─────────────────────────────────────────────────────────

class _AchievementsTab extends ConsumerWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Progress overview
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$unlocked',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppTheme.accentGold)),
                        Text('Unlocked',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppTheme.glassWhite),
                    Column(
                      children: [
                        Text('${achievements.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppTheme.textSecondary)),
                        Text('Total',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppTheme.glassWhite),
                    Column(
                      children: [
                        Text(
                            achievements.isEmpty
                                ? '0%'
                                : '${(unlocked / achievements.length * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppTheme.neonBlue)),
                        Text('Complete',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ...achievements.map((a) {
                final rarityColor = _rarityColor(a.rarity);
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  borderColor: a.isUnlocked
                      ? rarityColor.withOpacity(0.4)
                      : AppTheme.glassBlue,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: a.isUnlocked
                              ? rarityColor.withOpacity(0.2)
                              : AppTheme.glassWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: a.isUnlocked
                              ? AppTheme.glowShadow(
                                  color: rarityColor, blurRadius: 12)
                              : null,
                        ),
                        child: Icon(
                          _iconFromName(a.iconName),
                          color: a.isUnlocked
                              ? rarityColor
                              : AppTheme.textTertiary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(a.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: a.isUnlocked
                                              ? AppTheme.textPrimary
                                              : AppTheme.textTertiary,
                                        )),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rarityColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(a.rarity.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                              color: rarityColor,
                                              fontSize: 9,
                                              letterSpacing: 1)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(a.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: a.isUnlocked
                                          ? AppTheme.textSecondary
                                          : AppTheme.textTertiary,
                                    )),
                            if (a.isUnlocked && a.unlockedAt != null)
                              Text(
                                'Unlocked ${AppUtils.formatRelativeDate(a.unlockedAt!)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: rarityColor),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (a.isUnlocked)
                            const Icon(Icons.check_circle,
                                color: AppTheme.successGreen, size: 20)
                          else
                            const Icon(Icons.lock_outline,
                                color: AppTheme.textTertiary, size: 20),
                          const SizedBox(height: 4),
                          Text('+${a.xpReward}xp',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.accentGold)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'rare':
        return AppTheme.neonBlue;
      case 'epic':
        return AppTheme.neonPurple;
      case 'legendary':
        return AppTheme.accentGold;
      default:
        return AppTheme.successGreen;
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'directions_run':
        return Icons.directions_run;
      case 'repeat':
        return Icons.repeat;
      case 'flag':
        return Icons.flag;
      case 'bolt':
        return Icons.bolt;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'photo_camera':
        return Icons.photo_camera;
      default:
        return Icons.star;
    }
  }
}

// ─── PROFILE TAB ──────────────────────────────────────────────────────────────

class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();
  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  final _nameCtrl = TextEditingController();
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameCtrl.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create your Hunter profile',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Hunter Name'),
              ),
            ),
            const SizedBox(height: 16),
            GlowButton(
              label: 'START JOURNEY',
              onTap: () {
                if (_nameCtrl.text.trim().isNotEmpty) {
                  ref.read(userProvider.notifier).createUser(_nameCtrl.text.trim());
                }
              },
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Settings button
          GlowButton(
            label: 'SETTINGS',
            icon: Icons.settings,
            width: double.infinity,
            outlined: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Profile card
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [AppTheme.neonBlue, AppTheme.neonPurple]),
                    boxShadow: AppTheme.glowShadow(blurRadius: 20),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'H',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_editingName)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: AppTheme.neonBlue),
                        onPressed: () {
                          ref.read(userProvider.notifier).updateName(_nameCtrl.text.trim());
                          setState(() => _editingName = false);
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _editingName = true),
                        child: const Icon(Icons.edit,
                            size: 18, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  '${AppUtils.getRankTitle(user.currentLevel)}  •  Level ${user.currentLevel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getRankColor(AppUtils.getRank(user.currentLevel)),
                      ),
                ),
                const SizedBox(height: 4),
                Text('${user.totalXP} total XP',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats summary
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HUNTER RECORD',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary, letterSpacing: 2)),
                const SizedBox(height: 12),
                _profileStat(context, 'Member Since',
                    AppUtils.formatDate(user.createdAt)),
                _profileStat(context, 'Total Workouts',
                    '${ref.watch(workoutProvider.notifier).totalWorkouts}'),
                _profileStat(context, 'Total Cardio Sessions',
                    '${ref.watch(cardioProvider.notifier).totalCardio}'),
                _profileStat(context, 'Total Sets',
                    '${ref.watch(workoutProvider.notifier).totalSets}'),
                _profileStat(context, 'Total Volume',
                    '${(ref.watch(workoutProvider.notifier).totalVolume / 1000).toStringAsFixed(1)}k kg'),
                _profileStat(context, 'Best Streak',
                    '${ref.watch(streakProvider).highestStreak} days'),
                _profileStat(context, 'Achievements',
                    '${ref.watch(achievementProvider.notifier).unlockedCount}/${ref.watch(achievementProvider.notifier).totalCount}'),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _profileStat(BuildContext ctx, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(ctx)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppTheme.neonBlue)),
        ],
      ),
    );
  }
}
