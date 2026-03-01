import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyJToken = 'jToken';
  static const String _keyToken = 'token';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  Future<void> saveAuthData(String jToken, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJToken, jToken);
    await prefs.setString(_keyToken, token);
    await prefs.setBool(_keyIsLoggedIn, true);
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
  }
}
