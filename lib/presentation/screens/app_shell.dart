import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'workout_log_screen.dart';
import 'progress_hub_screen.dart';
import 'more_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkoutLogScreen(),
    ProgressHubScreen(),
    MoreScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'System'),
    _NavItem(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: 'Train'),
    _NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up, label: 'Progress'),
    _NavItem(icon: Icons.more_horiz_outlined, activeIcon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkerSurface,
        border: Border(
          top: BorderSide(
            color: AppTheme.neonBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonBlue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              return _buildNavItem(_navItems[i], i);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.neonBlue.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: AppTheme.neonBlue.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? AppTheme.neonBlue : AppTheme.textTertiary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? AppTheme.neonBlue
                        : AppTheme.textTertiary,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
            ),
          ],
        ),
      )
          .animate(target: isActive ? 1 : 0)
          .scaleXY(end: 1.05, duration: 150.ms),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
