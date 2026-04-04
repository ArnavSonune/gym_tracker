import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.width,
    this.height,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: enableBlur
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor?.withOpacity(0.15) ?? AppTheme.glassWhite,
                    backgroundColor?.withOpacity(0.02) ?? AppTheme.glassWhite.withOpacity(0.02),
                  ],
                  stops: const [0.1, 1.0],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? AppTheme.glassBlue.withOpacity(0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (borderColor ?? AppTheme.neonBlue).withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
