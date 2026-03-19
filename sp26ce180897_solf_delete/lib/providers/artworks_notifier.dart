// ============================================================
// 💾 HƯỚNG DẪN THÊM TRƯỜNG MỚI VÀO ARTWORKS NOTIFIER
// ============================================================
// Khi thêm trường mới vào Artwork model:
// Thường KHÔNG cần sửa provider vì dùng toJson/fromJson tự động
// Chỉ sửa nếu có logic xử lý đặc biệt với field mới
// ============================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';

part 'artworks_notifier.g.dart';

@riverpod
class ArtworksNotifier extends _$ArtworksNotifier {
  @override
  Future<List<Artwork>> build() async {
    return DatabaseHelper.instance.getArtworks();
  }

  // TODO [ADD]: Khi thêm trường mới vào Artwork, thường KHÔNG cần sửa
  // Vì UI đã truyền đủ dữ liệu trong Artwork constructor
  // Chỉ sửa nếu có logic xử lý đặc biệt
  Future<void> addArtwork(Artwork artwork, int userId) async {
    final artworkWithUserId = Artwork(
      id: artwork.id,
      title: artwork.title,
      artist: artwork.artist,
      year: artwork.year,
      category: artwork.category,
      description: artwork.description,
      createdBy: userId,
      isDeleted: artwork.isDeleted,
      deletedAt: artwork.deletedAt,
      // TODO [ADD]: Thêm field mới vào Artwork constructor
      // Ví dụ: price: artwork.price,
    );
    await DatabaseHelper.instance.createArtwork(artworkWithUserId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateArtwork(Artwork artwork) async {
    DatabaseHelper.instance.updateArtwork(artwork);
    ref.invalidateSelf();
    await future;
  }

  // =========================
  // 🔐 SOFT DELETE METHODS
  // =========================

  /// 🔐 XÓA MỀM: Đánh dấu isDeleted = 1
  /// [REASON] Để lưu lại artwork, cho phép khôi phục sau
  /// [IMPACT] Nếu dùng hard delete, sẽ mất dữ liệu vĩnh viễn
  Future<void> softDeleteArtwork(int id) async {
    DatabaseHelper.instance.softDeleteArtwork(id);
    ref.invalidateSelf();
    await future;
  }

  /// 🔐 XÓA MỀM: Alias cho softDeleteArtwork (tương thích ngược)
  /// [REASON] Để các màn hình gọi deleteArtwork() vẫn hoạt động
  /// [IMPACT] Nếu không có, code cũ sẽ gọi hard delete
  Future<void> deleteArtwork(int id) async {
    DatabaseHelper.instance.softDeleteArtwork(id);
    ref.invalidateSelf();
    await future;
  }

  /// 🔐 KHÔI PHỤC: Đánh dấu isDeleted = 0
  /// [REASON] Để khôi phục artwork đã xóa mềm
  /// [IMPACT] Nếu không có, không thể khôi phục đã xóa
  Future<void> restoreArtwork(int id) async {
    DatabaseHelper.instance.restoreArtwork(id);
    ref.invalidateSelf();
    await future;
  }

  /// 🔐 XÓA VĨNH VIỄN: Xóa khỏi database
  /// [REASON] Để xóa vĩnh viễn artwork đã xóa mềm
  /// [IMPACT] Hành động này KHÔNG THỂ HOÀN TÁC
  Future<void> permanentDeleteArtwork(int id) async {
    DatabaseHelper.instance.permanentDeleteArtwork(id);
    ref.invalidateSelf();
    await future;
  }

  /// 🔐 EMPTY TRASH: Xóa vĩnh viễn tất cả đã xóa mềm
  /// [REASON] Để xóa tất cả artwork trong trash
  /// [IMPACT] Hành động này KHÔNG THỂ HOÀN TÁC
  Future<void> emptyTrash(int userId) async {
    DatabaseHelper.instance.emptyTrash(userId);
    ref.invalidateSelf();
    await future;
  }

  Future<Artwork?> getArtworkById(int id) async {
    return DatabaseHelper.instance.getArtworkById(id);
  }
}
