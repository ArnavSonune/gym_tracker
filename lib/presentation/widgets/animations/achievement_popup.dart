import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/achievement_model.dart';

class AchievementUnlockPopup extends StatefulWidget {
  final AchievementModel achievement;
  final VoidCallback onComplete;

  const AchievementUnlockPopup({
    super.key,
    required this.achievement,
    required this.onComplete,
  });

  static void show(
    BuildContext context, {
    required AchievementModel achievement,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          entry.remove();
          onComplete?.call();
        },
        child: AchievementUnlockPopup(
          achievement: achievement,
          onComplete: () {
            entry.remove();
            onComplete?.call();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<AchievementUnlockPopup> createState() => _AchievementUnlockPopupState();
}

class _AchievementUnlockPopupState extends State<AchievementUnlockPopup> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) widget.onComplete();
    });
  }

  Color get rarityColor {
    switch (widget.achievement.rarity) {
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

  IconData get achievementIcon {
    switch (widget.achievement.iconName) {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "ACHIEVEMENT UNLOCKED" header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rarityColor, width: 1.5),
                ),
                child: Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: rarityColor,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: 32),

              // Achievement card
              Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rarityColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            rarityColor,
                            rarityColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rarityColor.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        achievementIcon,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.3),
                        ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.achievement.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      widget.achievement.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: rarityColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.diamond, color: rarityColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            widget.achievement.rarity.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: rarityColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    // XP reward
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '+${widget.achievement.xpReward} XP',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 400.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          delay: 1000.ms,
                          duration: 300.ms,
                        ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 32),

              // Tap to continue
              Text(
                'TAP TO CONTINUE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                      letterSpacing: 2,
                    ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .fadeIn(delay: 2000.ms, duration: 500.ms)
                  .then()
                  .fadeOut(duration: 1000.ms)
                  .then()
                  .fadeIn(duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

}
