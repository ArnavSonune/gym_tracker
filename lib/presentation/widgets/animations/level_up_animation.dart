import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();

  // static show() lives here (public class) so callers can use LevelUpAnimation.show()
  static void show(
    BuildContext context, {
    required int newLevel,
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
        child: LevelUpAnimation(
          newLevel: newLevel,
          onComplete: () {
            entry.remove();
            onComplete?.call();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _LevelUpAnimationState extends State<LevelUpAnimation> {
  @override
  void initState() {
    super.initState();
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();
    // Auto-dismiss after animation completes
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rank = AppUtils.getRank(widget.newLevel);
    final rankColor = AppTheme.getRankColor(rank);

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "LEVEL UP!" text
            Text(
              'LEVEL UP!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.neonBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(
                  duration: 1500.ms,
                  color: AppTheme.neonBlue,
                ),

            const SizedBox(height: 40),

            // Level circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.neonBlue,
                    AppTheme.neonPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 3,
                          ),
                    ),
                    Text(
                      '${widget.newLevel}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 72,
                          ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.0, 1.0),
                  delay: 300.ms,
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.3),
                ),

            const SizedBox(height: 40),

            // Rank badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: rankColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.military_tech,
                    color: rankColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$rank-RANK HUNTER',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 400.ms)
                .slideY(
                  begin: 0.5,
                  end: 0,
                  delay: 800.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 24),

            // Motivational message
            Text(
              'Your power continues to grow, Hunter!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 400.ms),

            const SizedBox(height: 40),

            // Tap to continue hint
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
    );
  }
}

