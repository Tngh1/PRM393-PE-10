// Shared Preference Provider
// Provider này chỉ cung cấp SharedPreferences instance, KHÔNG chứa session logic
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preference_provider.g.dart';

// Cung cấp SharedPreferences instance
// Được override trong main.dart
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

// ============================================================
// 💾 HƯỚNG DẪN THÊM FIELD MỚI VÀO SESSION
// ============================================================
// Khi thêm trường mới vào User model và muốn lưu vào SharedPreferences:
//
// 1. Thêm key constant ở đây:
//    static const _keyNewField = 'newField';
//
// 2. Thêm getter ở đây:
//    int? get newField => _prefs.getInt(_keyNewField);
//
// 3. Thêm setter trong login():
//    await _prefs.setInt(_keyNewField, user.newField);
//
// 4. Thêm clear trong logout():
//    await _prefs.remove(_keyNewField);
// ============================================================

// ============================================================
// 🔐 SESSION HELPER - Các hàm thao tác với session
// Dùng chung cho tất cả màn hình thay vì dùng SessionManager class
// ============================================================

/// Lưu session user vào SharedPreferences
Future<void> saveSession(SharedPreferences prefs, int userId, String username) async {
  await prefs.setBool('isLoggedIn', true);
  await prefs.setInt('userId', userId);
  await prefs.setString('username', username);
}

/// Xóa session user khỏi SharedPreferences
Future<void> clearSession(SharedPreferences prefs) async {
  await prefs.remove('isLoggedIn');
  await prefs.remove('userId');
  await prefs.remove('username');
}

/// Kiểm tra user đã đăng nhập chưa
bool isLoggedIn(SharedPreferences prefs) {
  return prefs.getBool('isLoggedIn') ?? false;
}

/// Lấy userId từ session
int? getSessionUserId(SharedPreferences prefs) {
  return prefs.getInt('userId');
}

/// Lấy username từ session
String? getSessionUsername(SharedPreferences prefs) {
  return prefs.getString('username');
}
