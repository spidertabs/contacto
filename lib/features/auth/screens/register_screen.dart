// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../../../shared/widgets/fingerprint_button.dart';
import '../../../shared/theme/app_theme.dart';
import '../../contacts/screens/contact_list_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isRegistering = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _checkRegistrationStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistrationStatus() async {
    final registered = await _authService.isAppRegistered();
    if (!mounted) return;
    if (registered) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    final supported = await _authService.isDeviceBiometricSupported();
    if (!supported) {
      return _setError('This device does not support fingerprint authentication.');
    }

    final enrolled = await _authService.isFingerprintEnrolled();
    if (!enrolled) {
      return _setError(
          'No fingerprint enrolled. Please add one in your device Settings.');
    }

    final authenticated = await _authService.authenticate(
      reason: 'Scan your fingerprint to register with Contacto.',
    );

    if (!mounted) return;
    if (authenticated) {
      await _authService.completeRegistration();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ContactListScreen()));
    } else {
      _setError('Fingerprint not recognised. Please try again.');
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ContactoTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ContactoTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/icons/icon.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 28),
                  const Text('Contacto',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: ContactoTheme.textPrimary,
                          letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your contacts, locked by your fingerprint.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: ContactoTheme.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  // Feature card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ContactoTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Column(children: [
                      _InfoRow(
                          icon: Icons.lock_outline, text: 'No passwords — ever.'),
                      SizedBox(height: 14),
                      _InfoRow(
                          icon: Icons.phone_android_outlined,
                          text: 'Data stays only on your device.'),
                      SizedBox(height: 14),
                      _InfoRow(
                          icon: Icons.touch_app_outlined,
                          text: 'One tap to unlock your contacts.'),
                    ]),
                  ),
                  const SizedBox(height: 40),

                  if (_errorMessage != null) ...[
                    _ErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 20),
                  ],

                  FingerprintButton(
                    onPressed: _handleRegister,
                    isLoading: _isRegistering,
                    label: 'Register with Fingerprint',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ContactoTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: ContactoTheme.primary),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, color: ContactoTheme.textPrimary, height: 1.4)),
      ),
    ]);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: ContactoTheme.error, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  color: ContactoTheme.error, fontSize: 13)),
        ),
      ]),
    );
  }
}