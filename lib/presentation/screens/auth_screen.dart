import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/database_helper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _loginUserCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regUserCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();

  bool _loginPassVisible = false;
  bool _regPassVisible = false;
  bool _regConfirmVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _gymExperienceLevel = 0; // selected on register tab

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _errorMessage = null));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _regUserCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    final username = _loginUserCtrl.text.trim();
    final password = _loginPassCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await DatabaseHelper.loginUser(
      username: username,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      context.go('/home');
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<void> _register() async {
    final username = _regUserCtrl.text.trim();
    final password = _regPassCtrl.text;
    final confirm = _regConfirmCtrl.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await DatabaseHelper.registerUser(
      username: username,
      password: password,
      gymExperienceLevel: _gymExperienceLevel,
    );

    // Seed default data for brand-new accounts
    if (error == null) await DatabaseHelper.seedDefaultDataIfNeeded();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      context.go('/home');
    }
  }

  // ── Shared text field builder ─────────────────────────────────────────────
  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? visible,
    VoidCallback? onToggleVisible,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmit,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure && !(visible ?? false),
      textInputAction: action,
      onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.neonBlue, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (visible ?? false)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                onPressed: onToggleVisible,
              )
            : null,
        filled: true,
        fillColor: AppTheme.darkerSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neonBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neonBlue.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.neonBlue, width: 1.5),
        ),
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _submitButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonBlue,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── Logo ──────────────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppTheme.glowShadow(blurRadius: 24),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 44,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 16),

              Text(
                'SYSTEM: HUNTER',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.neonBlue,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),

              Text(
                'Your journey is saved. Your progress is yours.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 36),

              // ── Tab bar ───────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkerSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonBlue.withOpacity(0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.neonBlue.withOpacity(0.5), width: 1),
                  ),
                  labelColor: AppTheme.neonBlue,
                  unselectedLabelColor: AppTheme.textTertiary,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  tabs: const [
                    Tab(text: 'LOGIN'),
                    Tab(text: 'REGISTER'),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 28),

              // ── Error banner ──────────────────────────────────────────────
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.dangerRed.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.dangerRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.dangerRed,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2),

              // ── Tab views ─────────────────────────────────────────────────
              SizedBox(
                height: 560,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    // ── LOGIN TAB ──────────────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(
                          ctrl: _loginUserCtrl,
                          label: 'Username',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _loginPassCtrl,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscure: true,
                          visible: _loginPassVisible,
                          onToggleVisible: () => setState(
                              () => _loginPassVisible = !_loginPassVisible),
                          action: TextInputAction.done,
                          onSubmit: _login,
                        ),
                        const SizedBox(height: 24),
                        _submitButton('LOGIN', _login),
                      ],
                    ),

                    // ── REGISTER TAB ───────────────────────────────────────
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field(
                            ctrl: _regUserCtrl,
                            label: 'Username',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            ctrl: _regPassCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: true,
                            visible: _regPassVisible,
                            onToggleVisible: () => setState(
                                () => _regPassVisible = !_regPassVisible),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            ctrl: _regConfirmCtrl,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscure: true,
                            visible: _regConfirmVisible,
                            onToggleVisible: () => setState(
                                () => _regConfirmVisible = !_regConfirmVisible),
                            action: TextInputAction.done,
                            onSubmit: _register,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'GYM EXPERIENCE',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            AppConstants.gymExperienceLevels.length,
                            (i) {
                              final selected = _gymExperienceLevel == i;
                              final colors = [
                                AppTheme.successGreen,
                                AppTheme.neonBlue,
                                AppTheme.neonPurple,
                                AppTheme.accentGold,
                              ];
                              final c = colors[i];
                              return GestureDetector(
                                onTap: () => setState(() => _gymExperienceLevel = i),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? c.withOpacity(0.12)
                                        : AppTheme.darkerSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? c
                                          : AppTheme.neonBlue.withOpacity(0.2),
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.fitness_center,
                                          color: selected
                                              ? c
                                              : AppTheme.textTertiary,
                                          size: 14),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          AppConstants.gymExperienceLevels[i],
                                          style: TextStyle(
                                            color: selected
                                                ? c
                                                : AppTheme.textSecondary,
                                            fontSize: 13,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        Icon(Icons.check_circle,
                                            color: c, size: 14),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _submitButton('CREATE ACCOUNT', _register),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Your data is stored locally on this device.\nNo internet connection required.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

