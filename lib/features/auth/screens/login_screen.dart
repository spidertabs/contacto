// lib/features/auth/screens/login_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../../../shared/widgets/fingerprint_button.dart';
import '../../../shared/theme/app_theme.dart';
import '../../contacts/screens/contact_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  String? _statusMessage;
  bool _isWarning = false;

  static const int _maxAttempts = 3;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));

    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLogin());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_failedAttempts >= _maxAttempts) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = null;
    });

    final authenticated = await _authService.authenticate(
      reason: 'Scan your fingerprint to access Contacto.',
    );

    if (!mounted) return;

    if (authenticated) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ContactListScreen()));
    } else {
      _failedAttempts++;
      _shakeController.forward(from: 0);
      setState(() {
        _isAuthenticating = false;
        _isWarning = _failedAttempts < _maxAttempts;
        if (_failedAttempts >= _maxAttempts) {
          _statusMessage =
              'Too many failed attempts. Please restart the app to try again.';
          _isWarning = false;
        } else {
          _statusMessage =
              'Fingerprint not recognised. ${_maxAttempts - _failedAttempts} attempt(s) remaining.';
        }
      });
    }
  }

  bool get _isLockedOut => _failedAttempts >= _maxAttempts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ContactoTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (_, child) {
                    final offset =
                        (_shakeController.isAnimating && !_isLockedOut)
                            ? 8 * (0.5 - (_shakeAnimation.value - 0.5).abs())
                            : 0.0;
                    return Transform.translate(
                        offset: Offset(offset, 0), child: child);
                  },
                  child: _isLockedOut
                      // Keep the red lock container only when locked out
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: ContactoTheme.error,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: ContactoTheme.error.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 52,
                            color: Colors.white,
                          ),
                        )
                      // Normal state: show the app logo
                      : Image.asset(
                          'assets/icons/icon.png',
                          width: 120,
                          height: 120,
                        ),
                ),
                const SizedBox(height: 28),

                Text(
                  _isLockedOut ? 'Locked Out' : 'Welcome Back',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ContactoTheme.textPrimary,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLockedOut
                      ? 'Restart the app to try again.'
                      : _isAuthenticating
                          ? 'Place your finger on the sensor…'
                          : 'Tap below to unlock your contacts.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      color: ContactoTheme.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 40),

                // Status banner
                if (_statusMessage != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isWarning
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Icon(
                        _isWarning
                            ? Icons.warning_amber_outlined
                            : Icons.lock_outline,
                        color: _isWarning
                            ? ContactoTheme.warning
                            : ContactoTheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_statusMessage!,
                            style: TextStyle(
                                color: _isWarning
                                    ? ContactoTheme.warning
                                    : ContactoTheme.error,
                                fontSize: 13)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),
                ],

                if (!_isLockedOut)
                  FingerprintButton(
                    onPressed: _isAuthenticating ? null : _handleLogin,
                    isLoading: _isAuthenticating,
                    label: _failedAttempts > 0
                        ? 'Try Again'
                        : 'Unlock with Fingerprint',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}