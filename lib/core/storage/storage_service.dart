import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyJToken = 'jToken';
  static const String _keyToken = 'token';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyIsOnboardingComplete = 'isOnboardingComplete';
  static const String _keyFingerprintEnabled = 'fingerprintEnabled';
  static const String _keyAppPin = 'appPin';

  Future<void> saveAuthData(String jToken, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJToken, jToken);
    await prefs.setString(_keyToken, token);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboardingComplete, true);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboardingComplete) ?? false;
  }

  Future<String?> getJToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyJToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJToken);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyIsLoggedIn);
    // Also clear PIN/fingerprint on logout to be safe
    await prefs.remove(_keyAppPin);
    await prefs.remove(_keyFingerprintEnabled);
  }

  // Fingerprint preference
  Future<void> setFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFingerprintEnabled, enabled);
  }

  Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFingerprintEnabled) ?? false;
  }

  // App PIN storage
  Future<void> setAppPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppPin, pin);
  }

  Future<String?> getAppPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppPin);
  }

  Future<void> removeAppPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppPin);
  }
}
