import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/user_model.dart';
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
        title: Text('MORE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonBlue, letterSpacing: 2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonBlue,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: AppTheme.textTertiary,
          tabs: const [
            Tab(text: 'ACHIEVEMENTS'),
            Tab(text: 'PROFILE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AchievementsTab(),
          _ProfileTab(),
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
  bool _pickingPhoto = false;

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

  Future<void> _pickProfilePhoto() async {
    setState(() => _pickingPhoto = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null && mounted) {
        await ref.read(userProvider.notifier).updateProfilePhoto(picked.path);
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Future<void> _removeProfilePhoto() async {
    await ref.read(userProvider.notifier).updateProfilePhoto(null);
  }

  Widget _buildAvatar(UserModel user) {
    final hasPhoto = user.profilePhotoPath != null &&
        user.profilePhotoPath!.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasPhoto
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.neonBlue, AppTheme.neonPurple]),
              boxShadow: AppTheme.glowShadow(blurRadius: 20),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? _buildPhotoWidget(user.profilePhotoPath!)
                : Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'H',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ),
        // Camera badge
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.darkBackground, width: 2),
            ),
            child: _pickingPhoto
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.camera_alt, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoWidget(String path) {
    // Web uses data URLs; mobile uses file paths
    if (path.startsWith('data:') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    try {
      return Image.file(File(path), fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.person, color: Colors.white, size: 44);
    }
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 16),

          // Profile card with photo
          GlassCard(
            child: Column(
              children: [
                _buildAvatar(user),
                if (user.profilePhotoPath != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _removeProfilePhoto,
                    child: Text(
                      'Remove photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.dangerRed,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (_editingName)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: AppTheme.neonBlue),
                        onPressed: () {
                          ref
                              .read(userProvider.notifier)
                              .updateName(_nameCtrl.text.trim());
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
                        color: AppTheme.getRankColor(
                            AppUtils.getRank(user.currentLevel)),
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
                _profileStat(context, 'Best Streak',
                    '${ref.watch(streakProvider).highestStreak} days'),
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

