// lib/features/auth/auth_service.dart
import 'package:local_auth/local_auth.dart';
import '../../data/database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final DatabaseHelper _db = DatabaseHelper();

  /// Returns true if the device hardware supports biometrics.
  Future<bool> isDeviceBiometricSupported() async {
    return await _auth.isDeviceSupported();
  }

  /// Returns true if the user has at least one fingerprint enrolled.
  Future<bool> isFingerprintEnrolled() async {
    final enrolled = await _auth.getAvailableBiometrics();
    return enrolled.isNotEmpty;
  }

  /// Triggers the system biometric prompt.
  /// Returns true on successful authentication.
  Future<bool> authenticate({required String reason}) async {
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

  /// Checks if the app has been registered (fingerprint setup completed).
  Future<bool> isAppRegistered() async {
    return await _db.isRegistered();
  }

  /// Marks registration as complete in the local DB.
  Future<void> completeRegistration() async {
    await _db.setRegistered();
  }
}
