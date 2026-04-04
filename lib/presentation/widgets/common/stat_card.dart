import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'glass_card.dart';

// ─── EMPTY STATE WIDGET ────────────────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.neonBlue.withOpacity(0.6),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2000.ms, color: AppTheme.neonBlue.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onButtonTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.glowShadow(),
                  ),
                  child: Text(
                    buttonLabel!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── STAT CARD ────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.neonBlue;
    return GlassCard(
      onTap: onTap,
      borderColor: c.withOpacity(0.3),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon — top-left
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.glowShadow(color: c, blurRadius: 10),
            ),
            child: Icon(icon, color: c, size: 16),
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.neonBlue,
                borderRadius: BorderRadius.circular(2),
                boxShadow: AppTheme.glowShadow(blurRadius: 8),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        if (actionLabel != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.neonBlue,
                  ),
            ),
          ),
      ],
    );
  }
}

// ─── SYSTEM ALERT CARD ────────────────────────────────────────────────────────

class SystemAlertCard extends StatelessWidget {
  final String message;
  final Color? color;
  final IconData? icon;

  const SystemAlertCard({
    super.key,
    required this.message,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.neonPurple;
    return GlassCard(
      borderColor: c.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.terminal,
            color: c,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}





