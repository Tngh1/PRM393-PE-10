import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/artwork.dart';
import '../models/user.dart';

class DatabaseHelper {
  static const _databaseName = 'art_gallery_provider.db';
  static const _databaseVersion = 1; // TĂNG VERSION KHI THAY ĐỔI CẤU TRÚC DB

  // ============================================================
  // 💾 HƯỚNG DẪN THAY ĐỔI DATABASE
  // ============================================================
  // KHI CẦN THAY ĐỔI DATABASE (đổi bảng, thêm cột mới):
  //
  // 1. THÊM CỘT MỚI VÀO BẢNG HIỆN CÓ:
  //    - Sử dụng _onUpgrade() bên dưới
  //    - Uncomment và sửa câu lệnh ALTER TABLE
  //    - Tăng _databaseVersion lên 1 đơn vị
  //
  // 2. TẠO BẢNG MỚI:
  //    - Thêm vào _onCreate()
  //    - Khai báo tên bảng dưới đây
  //
  // 3. SAU KHI THAY ĐỔI DATABASE:
  //    - Cập nhật Model tương ứng (user.dart, artwork.dart)
  //    - Cập nhật UI screens nếu cần hiển thị thêm trường mới
  //
  // ============================================================

  static const userTable = 'users';
  static const artworkTable = 'artworks';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    print('DB PATH: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  // ============================================================
  // 💾 HƯỚNG DẪN THAY ĐỔI BẢNG TRONG DATABASE
  // ============================================================
  // KHI CẦN THÊM/TRƯỜNG MỚI VÀO BẢNG:
  //
  // CÁCH 1 - THÊM CỘT MỚI (Dùng cho app đã có trên máy người dùng):
  //   Sử dụng _onUpgrade() bên dưới
  //   Ví dụ: await db.execute('ALTER TABLE $userTable ADD COLUMN phone TEXT');
  //   ⚠️ NHỚ: Tăng _databaseVersion từ 1 lên 2
  //
  // CÁCH 2 - TẠO BẢNG MỚI HOẶC SỬA LẠI TOÀN BỘ (Dùng khi chưa release):
  //   Sửa trực tiếp trong _onCreate() bên dưới
  //   Thêm cột mới vào câu lệnh CREATE TABLE
  //
  // CÁC BƯỚC KHI THAY ĐỔI:
  //   1. Thêm cột vào đây (database_helper.dart)
  //   2. Thêm field vào Model (user.dart, artwork.dart)
  //   3. Cập nhật UI nếu cần hiển thị/nhập liệu thêm
  // ============================================================

  Future<void> _onCreate(Database db, int version) async {
    // 👉 THÊM CỘT MỚI VÀO BẢNG USERS: Thêm vào đây, ví dụ: phone TEXT
    // TODO [ADD]: Thêm cột mới vào bảng USERS trong _onCreate
    // Ví dụ: phone TEXT
    // Ví dụ: avatarUrl TEXT
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
        -- 👉 THÊM CỘT MỚI: ví dụ: , phone TEXT
      )
    ''');

    // 👉 THÊM CỘT MỚI VÀO BẢNG ARTWORKS: Thêm vào đây, ví dụ: price REAL
    // TODO [ADD]: Thêm cột mới vào bảng ARTWORKS trong _onCreate
    // Ví dụ: price REAL
    // Ví dụ: imageUrl TEXT
    await db.execute('''
      CREATE TABLE $artworkTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        year INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        createdBy INTEGER NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES $userTable(id)
        -- 👉 THÊM CỘT MỚI: ví dụ: , price REAL
      )
    ''');
  }

  // 👉 THÊM CỘT MỚI KHI APP ĐÃ CÓ SẴN (Migration):
  // Uncomment và sửa các dòng dưới đây khi cần thêm cột vào bảng đã tồn tại
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // TODO [ADD]: Thêm câu lệnh ALTER TABLE cho bảng USERS khi cần
      // Ví dụ: await db.execute('ALTER TABLE $userTable ADD COLUMN phone TEXT');
      // TODO [ADD]: Thêm câu lệnh ALTER TABLE cho bảng ARTWORKS khi cần
      // Ví dụ: await db.execute('ALTER TABLE $artworkTable ADD COLUMN price REAL');
      // Ví dụ: await db.execute('ALTER TABLE $artworkTable ADD COLUMN imageUrl TEXT');
    }
    if (oldVersion < 3) {
      // TODO [ADD]: Thêm migration cho phiên bản tiếp theo
      // Ví dụ: await db.execute('CREATE TABLE new_table (...)');
    }
    // print('Database upgraded from version $oldVersion to $newVersion');
  }

  // =========================
  // USER CRUD
  // =========================

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert(
      userTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final maps = await db.query(userTable, orderBy: 'id DESC');
    return maps.map((e) => User.fromJson(e)).toList();
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<bool> isUsernameExists(String username) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // =========================
  // ARTWORK CRUD
  // =========================

  Future<int> createArtwork(Artwork artwork) async {
    final db = await database;
    return await db.insert(
      artworkTable,
      artwork.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Artwork>> getArtworks() async {
    final db = await database;
    final maps = await db.query(artworkTable, orderBy: 'id DESC');
    return maps.map((e) => Artwork.fromJson(e)).toList();
  }

  Future<Artwork?> getArtworkById(int id) async {
    final db = await database;
    final maps = await db.query(
      artworkTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Artwork.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Artwork>> getArtworksByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      artworkTable,
      where: 'createdBy = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return maps.map((e) => Artwork.fromJson(e)).toList();
  }

  Future<int> updateArtwork(Artwork artwork) async {
    final db = await database;
    return await db.update(
      artworkTable,
      artwork.toJson(),
      where: 'id = ?',
      whereArgs: [artwork.id],
    );
  }

  Future<int> deleteArtwork(int id) async {
    final db = await database;
    return await db.delete(
      artworkTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
