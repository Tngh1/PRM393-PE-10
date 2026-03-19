/// Dùng SharedPreferences (lưu session đăng nhập) - override trong main.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main');
});

// Helper session 
const _keyUserId = 'userId';
const _keyUsername = 'username';

void saveSession(SharedPreferences prefs, int userId, String username) {
  prefs.setInt(_keyUserId, userId);
  prefs.setString(_keyUsername, username);
}

void clearSession(SharedPreferences prefs) {
  prefs.remove(_keyUserId);
  prefs.remove(_keyUsername);
}

int? getSessionUserId(SharedPreferences prefs) => prefs.getInt(_keyUserId);
String? getSessionUsername(SharedPreferences prefs) => prefs.getString(_keyUsername);
