import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../providers/app_providers.dart';
import '../widgets/common/glow_button.dart';

class MuscleMapScreen extends ConsumerStatefulWidget {
  const MuscleMapScreen({super.key});

  @override
  ConsumerState<MuscleMapScreen> createState() => _MuscleMapScreenState();
}

class _MuscleMapScreenState extends ConsumerState<MuscleMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMuscle;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _showFront = _tabController.index == 0;
          _selectedMuscle = null; // Clear selection when switching views
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onMuscleTapped(String muscleName) {
    setState(() {
      _selectedMuscle = muscleName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP SECTION: Title + View Toggle ──────────────────────
            _buildTopSection(),

            // ── MAIN SECTION: Interactive Body Map ────────────────────
            Expanded(
              flex: 7,
              child: InteractiveBodyMap(
                showFront: _showFront,
                selectedMuscle: _selectedMuscle,
                onMuscleTapped: _onMuscleTapped,
              ),
            ),

            // ── BOTTOM SECTION: Muscle Info Panel ─────────────────────
            Expanded(
              flex: 3,
              child: MuscleInfoPanel(
                selectedMuscle: _selectedMuscle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neonBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'MUSCLE MAP',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neonBlue,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          // Segmented Control
          Container(
            decoration: BoxDecoration(
              color: AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.neonBlue,
                borderRadius: BorderRadius.circular(25),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: AppTheme.textTertiary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'FRONT'),
                Tab(text: 'BACK'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INTERACTIVE BODY MAP WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class InteractiveBodyMap extends StatelessWidget {
  final bool showFront;
  final String? selectedMuscle;
  final ValueChanged<String> onMuscleTapped;

  const InteractiveBodyMap({
    super.key,
    required this.showFront,
    required this.selectedMuscle,
    required this.onMuscleTapped,
  });

  // Define tap zones as rectangles (normalized 0-1 coordinates)
  // Format: 'Muscle Name': Rect(left, top, right, bottom)
  static const Map<String, Rect> _frontTapZones = {
    'Shoulders': Rect.fromLTRB(0.30, 0.15, 0.70, 0.24),
    'Chest': Rect.fromLTRB(0.32, 0.24, 0.68, 0.35),
    'Biceps': Rect.fromLTRB(0.15, 0.30, 0.30, 0.42),
    'Triceps': Rect.fromLTRB(0.70, 0.30, 0.85, 0.42),
    'Abs': Rect.fromLTRB(0.38, 0.38, 0.62, 0.52),
    'Quads': Rect.fromLTRB(0.32, 0.58, 0.68, 0.76),
    'Calves': Rect.fromLTRB(0.36, 0.82, 0.64, 0.94),
  };

  static const Map<String, Rect> _backTapZones = {
    'Traps': Rect.fromLTRB(0.32, 0.15, 0.68, 0.23),
    'Rear Delts': Rect.fromLTRB(0.25, 0.20, 0.75, 0.28),
    'Lats': Rect.fromLTRB(0.28, 0.28, 0.72, 0.42),
    'Lower Back': Rect.fromLTRB(0.35, 0.42, 0.65, 0.52),
    'Glutes': Rect.fromLTRB(0.32, 0.52, 0.68, 0.64),
    'Hamstrings': Rect.fromLTRB(0.32, 0.64, 0.68, 0.80),
    'Calves': Rect.fromLTRB(0.36, 0.82, 0.64, 0.94),
  };

  Map<String, Rect> get _currentZones => showFront ? _frontTapZones : _backTapZones;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // Body diagram background
            Center(
              child: CustomPaint(
                size: Size(width * 0.7, height * 0.95),
                painter: _BodyDiagramPainter(
                  showFront: showFront,
                  selectedMuscle: selectedMuscle,
                ),
              ),
            ),

            // Invisible tap zones overlaid on body
            ..._currentZones.entries.map((entry) {
              final muscleName = entry.key;
              final zone = entry.value;
              final isSelected = selectedMuscle == muscleName;

              return Positioned(
                left: zone.left * width,
                top: zone.top * height,
                width: (zone.right - zone.left) * width,
                height: (zone.bottom - zone.top) * height,
                child: GestureDetector(
                  onTap: () => onMuscleTapped(muscleName),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.neonBlue.withOpacity(0.3)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.neonBlue
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }),

            // Helper text at bottom
            if (selectedMuscle == null)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: AppTheme.neonBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap a muscle to view stats',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MUSCLE INFO PANEL (BOTTOM)
// ═══════════════════════════════════════════════════════════════════════════

class MuscleInfoPanel extends ConsumerWidget {
  final String? selectedMuscle;

  const MuscleInfoPanel({
    super.key,
    this.selectedMuscle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedMuscle == null) {
      return _buildEmptyState(context);
    }

    // Get muscle stats
    final stats = ref
        .read(workoutProvider.notifier)
        .getMuscleGroupStats(selectedMuscle!);
    
    final totalSessions = stats['totalSessions'] as int;
    final totalVolume = stats['totalVolume'] as double;
    final lastTrained = stats['lastTrained'] as DateTime?;
    final exercises = stats['topExercises'] as List<String>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppTheme.neonBlue.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle name
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                selectedMuscle!.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatChip(
                context,
                icon: Icons.fitness_center,
                label: '$totalSessions',
                subtitle: 'sessions',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                icon: Icons.monitor_weight,
                label: totalVolume >= 1000
                    ? '${(totalVolume / 1000).toStringAsFixed(1)}k'
                    : totalVolume.toStringAsFixed(0),
                subtitle: 'kg total',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                icon: Icons.schedule,
                label: lastTrained != null
                    ? AppUtils.formatRelativeDate(lastTrained)
                    : 'Never',
                subtitle: 'last trained',
              ),
            ],
          ),
          const Spacer(),

          // Action button
          GlowButton(
            label: 'VIEW EXERCISES',
            icon: Icons.list,
            width: double.infinity,
            onTap: () {
              // Navigate to exercises for this muscle
              // Implementation depends on your routing
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 40,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a muscle to view details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.glassBlue.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.neonBlue, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BODY DIAGRAM PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _BodyDiagramPainter extends CustomPainter {
  final bool showFront;
  final String? selectedMuscle;

  _BodyDiagramPainter({
    required this.showFront,
    this.selectedMuscle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final basePaint = Paint()
      ..color = AppTheme.glassBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = AppTheme.neonBlue.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw simplified body outline
    if (showFront) {
      _drawFrontBody(canvas, size, cx, w, h, basePaint, outlinePaint);
    } else {
      _drawBackBody(canvas, size, cx, w, h, basePaint, outlinePaint);
    }
  }

  void _drawFrontBody(Canvas canvas, Size size, double cx, double w, double h,
      Paint basePaint, Paint outlinePaint) {
    // Head
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, h * 0.08), width: w * 0.14, height: h * 0.11),
        basePaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, h * 0.08), width: w * 0.14, height: h * 0.11),
        outlinePaint);

    // Neck
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx, h * 0.15), width: w * 0.07, height: h * 0.05),
        basePaint);

    // Torso
    final torsoPath = Path()
      ..moveTo(cx - w * 0.20, h * 0.18)
      ..lineTo(cx + w * 0.20, h * 0.18)
      ..lineTo(cx + w * 0.18, h * 0.55)
      ..lineTo(cx - w * 0.18, h * 0.55)
      ..close();
    canvas.drawPath(torsoPath, basePaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Arms
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx - w * 0.28, h * 0.32),
          width: w * 0.12,
          height: h * 0.28),
      const Radius.circular(20),
    );
    canvas.drawRRect(leftArm, basePaint);
    canvas.drawRRect(leftArm, outlinePaint);

    final rightArm = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx + w * 0.28, h * 0.32),
          width: w * 0.12,
          height: h * 0.28),
      const Radius.circular(20),
    );
    canvas.drawRRect(rightArm, basePaint);
    canvas.drawRRect(rightArm, outlinePaint);

    // Legs
    final leftLeg = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx - w * 0.09, h * 0.74),
          width: w * 0.14,
          height: h * 0.38),
      const Radius.circular(15),
    );
    canvas.drawRRect(leftLeg, basePaint);
    canvas.drawRRect(leftLeg, outlinePaint);

    final rightLeg = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx + w * 0.09, h * 0.74),
          width: w * 0.14,
          height: h * 0.38),
      const Radius.circular(15),
    );
    canvas.drawRRect(rightLeg, basePaint);
    canvas.drawRRect(rightLeg, outlinePaint);
  }

  void _drawBackBody(Canvas canvas, Size size, double cx, double w, double h,
      Paint basePaint, Paint outlinePaint) {
    // Similar to front but slightly different proportions
    // (Simplified - same structure)
    _drawFrontBody(canvas, size, cx, w, h, basePaint, outlinePaint);
  }

  @override
  bool shouldRepaint(_BodyDiagramPainter oldDelegate) {
    return oldDelegate.showFront != showFront ||
        oldDelegate.selectedMuscle != selectedMuscle;
  }
}


