// [CHECK] Khi thêm field mới vào User model:
// Thường KHÔNG cần sửa provider vì dùng toJson/fromJson tự động
// Chỉ sửa nếu có logic xử lý đặc biệt với field mới

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/database_helper.dart';
import '../models/user.dart';

part 'users_notifier.g.dart';

@riverpod
class UsersNotifier extends _$UsersNotifier {
  User? _currentUser;

  @override
  Future<List<User>> build() async {
    return DatabaseHelper.instance.getUsers();
  }

  User? get currentUser => _currentUser;

  // [CHECK] Khi thêm field mới vào User model:
  // Thường KHÔNG cần sửa vì dùng user.toJson() tự động
  // Chỉ sửa nếu có logic đặc biệt với field mới
  Future<User?> login(String username, String password) async {
    final user = await DatabaseHelper.instance.login(username, password);

    if (user != null) {
      _currentUser = user;
    }

    return user;
  }

  Future<void> addUser(User user) async {
    DatabaseHelper.instance.createUser(user);
    ref.invalidateSelf();
    await future;
  }

  Future<bool> isUsernameExists(String username) async {
    return await DatabaseHelper.instance.isUsernameExists(username);
  }

  void logout() {
    _currentUser = null;
  }
}