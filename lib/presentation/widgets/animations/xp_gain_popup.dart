import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class XPGainPopup extends StatelessWidget {
  final int xpAmount;
  final VoidCallback? onComplete;

  const XPGainPopup({
    super.key,
    required this.xpAmount,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.neonBlue.withOpacity(0.9),
              AppTheme.neonPurple.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.glowShadow(
            color: AppTheme.neonBlue,
            blurRadius: 30,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '$xpAmount XP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      )
          .animate(
            onComplete: (_) => onComplete?.call(),
          )
          .fadeIn(duration: 200.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .shake(hz: 2, duration: 400.ms)
          .then(delay: 600.ms)
          .fadeOut(duration: 300.ms)
          .slideY(begin: 0, end: -0.3, duration: 300.ms),
    );
  }

  static void show(BuildContext context, int xp, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => XPGainPopup(
        xpAmount: xp,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}
