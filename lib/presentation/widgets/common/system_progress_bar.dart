import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SystemProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double height;
  final String? label;
  final String? valueLabel;
  final bool animated;

  const SystemProgressBar({
    super.key,
    required this.progress,
    this.foregroundColor,
    this.backgroundColor,
    this.height = 10,
    this.label,
    this.valueLabel,
    this.animated = true,
  });

  @override
  State<SystemProgressBar> createState() => _SystemProgressBarState();
}

class _SystemProgressBarState extends State<SystemProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.animated) _controller.forward();
  }

  @override
  void didUpdateWidget(SystemProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fgColor = widget.foregroundColor ?? AppTheme.neonBlue;
    final bgColor = widget.backgroundColor ?? AppTheme.glassWhite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (widget.valueLabel != null)
                  Text(
                    widget.valueLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: fgColor,
                        ),
                  ),
              ],
            ),
          ),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (context, _) {
            final value = widget.animated
                ? _progressAnim.value.clamp(0.0, 1.0)
                : widget.progress.clamp(0.0, 1.0);
            return Stack(
              children: [
                // Background track
                Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
                // Foreground fill
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(widget.height / 2),
                      gradient: LinearGradient(
                        colors: [
                          fgColor.withOpacity(0.7),
                          fgColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: fgColor.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
