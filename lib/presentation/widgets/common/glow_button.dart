import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final bool outlined;

  const GlowButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.width,
    this.height = 52,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.neonBlue;
    final textColor = widget.textColor ??
        (widget.outlined ? color : Colors.black);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(12),
            border: widget.outlined
                ? Border.all(color: color, width: 1.5)
                : null,
            boxShadow: widget.outlined
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
