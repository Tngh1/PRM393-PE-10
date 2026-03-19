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

  // [ADD] Thêm field mới vào Artwork constructor: price: artwork.price
  // [REASON] Để truyền đủ dữ liệu khi tạo mới artwork (nếu có logic đặc biệt)
  // [IMPACT] Nếu không thêm, field mới sẽ bị null khi tạo mới (trừ khi UI đã set)
  // [CHECK] Thường KHÔNG cần sửa vì UI đã truyền đủ trong constructor
  Future<void> addArtwork(Artwork artwork, int userId) async {
    final artworkWithUserId = Artwork(
      id: artwork.id,
      title: artwork.title,
      artist: artwork.artist,
      year: artwork.year,
      category: artwork.category,
      description: artwork.description,
      createdBy: userId,
      // [ADD] Thêm field mới: price: artwork.price
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

  Future<void> deleteArtwork(int id) async {
    DatabaseHelper.instance.deleteArtwork(id);
    ref.invalidateSelf();
    await future;
  }

  Future<Artwork?> getArtworkById(int id) async {
    return DatabaseHelper.instance.getArtworkById(id);
  }
}