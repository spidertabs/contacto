// lib/features/auth/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final DatabaseHelper _db = DatabaseHelper();

  /// Returns true if the device hardware supports biometrics.
  /// Always returns false on web.
  Future<bool> isDeviceBiometricSupported() async {
    if (kIsWeb) return false;
    return await _auth.isDeviceSupported();
  }

  /// Returns true if the user has at least one fingerprint enrolled.
  /// Always returns false on web.
  Future<bool> isFingerprintEnrolled() async {
    if (kIsWeb) return false;
    final enrolled = await _auth.getAvailableBiometrics();
    return enrolled.isNotEmpty;
  }

  /// Triggers the system biometric prompt.
  /// On web, skips auth and returns true so the UI is accessible.
  Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isAppRegistered() async {
    return await _db.isRegistered();
  }

  Future<void> completeRegistration() async {
    await _db.setRegistered();
  }
}