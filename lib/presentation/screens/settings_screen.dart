import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database_helper.dart';
import '../../data/database/hive_service.dart';
import '../../data/services/backup_service.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/glow_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: Text(
          'SETTINGS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.neonBlue,
                letterSpacing: 2,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        color: AppTheme.neonBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PROFILE',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.neonBlue,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Name', user?.name ?? 'Not set'),
                _buildInfoRow('Age', user?.age?.toString() ?? 'Not set'),
                _buildInfoRow(
                  'Height',
                  user?.heightCm != null
                      ? '${user!.heightCm!.toStringAsFixed(1)} cm'
                      : 'Not set',
                ),
                _buildInfoRow(
                  'Gender',
                  user?.isMale == true ? 'Male' : 'Female',
                ),
                const SizedBox(height: 12),
                GlowButton(
                  label: 'EDIT PROFILE',
                  width: double.infinity,
                  outlined: true,
                  onTap: () => _showEditProfileDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Info
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.neonPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ABOUT',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.neonPurple,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('App Version', '1.0.0'),
                _buildInfoRow('Theme', 'Solo Leveling Dark'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data Management
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage,
                        color: AppTheme.warningOrange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'DATA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.warningOrange,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlowButton(
                  label: 'EXPORT BACKUP',
                  icon: Icons.upload_file,
                  color: AppTheme.neonBlue,
                  width: double.infinity,
                  outlined: true,
                  onTap: _exportBackup,
                ),
                const SizedBox(height: 8),
                GlowButton(
                  label: 'IMPORT BACKUP',
                  icon: Icons.download,
                  color: AppTheme.neonPurple,
                  width: double.infinity,
                  outlined: true,
                  onTap: () => _showImportDialog(context),
                ),
                const SizedBox(height: 16),
                GlowButton(
                  label: 'CLEAR ALL DATA',
                  color: AppTheme.dangerRed,
                  width: double.infinity,
                  outlined: true,
                  onTap: () => _showClearDataDialog(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will delete all workouts, progress, and achievements',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logout
          GlassCard(
            borderColor: AppTheme.dangerRed.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.logout,
                        color: AppTheme.dangerRed, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ACCOUNT',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.dangerRed,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlowButton(
                  label: 'LOG OUT',
                  color: AppTheme.dangerRed,
                  width: double.infinity,
                  outlined: true,
                  onTap: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your data stays on this device. You can log back in anytime.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Credits
          GlassCard(
            child: Column(
              children: [
                Text(
                  'Made with 💪 for Hunters',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Inspired by Solo Leveling',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neonBlue,
                ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = ref.read(userProvider);
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final ageCtrl = TextEditingController(text: user?.age?.toString() ?? '');
    final heightCtrl =
        TextEditingController(text: user?.heightCm?.toString() ?? '');
    final targetWeightCtrl =
        TextEditingController(text: user?.targetWeight?.toString() ?? '');
    bool isMale = user?.isMale ?? true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  LengthLimitingTextInputFormatter(6),
                ],
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetWeightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Target Weight (kg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await ref.read(userProvider.notifier).updateName(nameCtrl.text.trim());
              }
              await ref.read(userProvider.notifier).updateProfile(
                    age: int.tryParse(ageCtrl.text),
                    heightCm: double.tryParse(heightCtrl.text),
                    targetWeight: double.tryParse(targetWeightCtrl.text),
                    isMale: isMale,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(color: AppTheme.neonBlue)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    try {
      await BackupService.exportBackup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Import Backup',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will overwrite your current workouts, weight logs, measurements, and streak with the backup data.\n\nYour account credentials will be preserved.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _pickAndImport();
            },
            child: const Text('Choose File',
                style: TextStyle(color: AppTheme.neonPurple)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final error = await BackupService.importBackup(content);

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      } else {
        // Refresh all providers
        ref.invalidate(userProvider);
        ref.invalidate(workoutProvider);
        ref.invalidate(cardioProvider);
        ref.invalidate(weightProvider);
        ref.invalidate(measurementProvider);
        ref.invalidate(streakProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restored successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Text('Log Out?'),
          ],
        ),
        content: const Text(
          'You will be taken to the login screen.\n'
          'Your data remains safe on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.logoutUser();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.go('/auth');
              }
            },
            child: const Text(
              'LOG OUT',
              style: TextStyle(color: AppTheme.dangerRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete:\n'
          '• All workouts and cardio\n'
          '• All progress photos\n'
          '• All weight logs\n'
          '• All measurements\n'
          '• Achievement progress\n'
          '• Streak data\n\n'
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveService.clearAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('DELETE EVERYTHING',
                style: TextStyle(color: AppTheme.dangerRed)),
          ),
        ],
      ),
    );
  }
}
