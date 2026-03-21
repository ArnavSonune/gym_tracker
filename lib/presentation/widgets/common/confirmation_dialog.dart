import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'glow_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDangerous;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDangerous = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDangerous
              ? AppTheme.dangerRed.withOpacity(0.5)
              : AppTheme.neonBlue.withOpacity(0.3),
        ),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDangerous ? AppTheme.dangerRed : AppTheme.neonBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDangerous ? AppTheme.dangerRed : AppTheme.neonBlue,
                  ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
      actions: [
        GlowButton(
          label: cancelText,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        GlowButton(
          label: confirmText,
          color: isDangerous ? AppTheme.dangerRed : AppTheme.neonBlue,
          onTap: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {},
        isDangerous: isDangerous,
        icon: icon,
      ),
    );
  }
}
