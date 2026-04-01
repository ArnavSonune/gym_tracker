import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    try {
      setState(() => _status = 'Loading database...');

      // Seed default data (exercises, achievements, streak) on first launch
      await DatabaseHelper.seedDefaultDataIfNeeded();

      setState(() => _status = 'Checking session...');

      // Check for a persisted login session
      final loggedIn = DatabaseHelper.isLoggedIn();

      setState(() => _status = 'Ready!');

      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        if (loggedIn) {
          context.go('/home');   // Returning user — skip auth entirely
        } else {
          context.go('/auth');   // New user or logged-out — show login/register
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in splash screen: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                    });
                    _initAndNavigate();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppTheme.darkBackground,
              const Color(0xFF0A0E27).withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon/logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                  ),
                  boxShadow: AppTheme.glowShadow(blurRadius: 30),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 2000.ms, color: AppTheme.neonBlue),

              const SizedBox(height: 40),

              // App title
              Text(
                'SYSTEM: HUNTER',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonBlue,
                      letterSpacing: 4,
                    ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 12),

              Text(
                'Solo Leveling begins...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.neonBlue.withOpacity(0.8),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 16),

              // Status text
              Text(
                _status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
