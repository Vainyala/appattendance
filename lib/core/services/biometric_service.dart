// lib/core/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check if device supports biometrics (face/fingerprint)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Get available types (face, fingerprint etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics (face preferred)
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final available = await getAvailableBiometrics();
      if (!available.contains(BiometricType.face) &&
          !available.contains(BiometricType.fingerprint)) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true, // No fallback to device PIN
        ),
      );
    } catch (e) {
      if (e.toString().contains(auth_error.notAvailable) ||
          e.toString().contains(auth_error.notEnrolled)) {
        // Handle no biometrics enrolled
      }
      return false;
    }
  }

  // Enable/disable in user model (call from UI)
  Future<void> enableBiometrics(bool enable) async {
    // Yeh DB mein save kar (niche DBHelper update mein dekh)
  }
}
