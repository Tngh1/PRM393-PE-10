// ============================================================
// 💾 HƯỚNG DẪN THÊM TRƯỜNG MỚI VÀO TRASH SCREEN
// ============================================================
// KHI THÊM TRƯỜNG MỚI VÀO ARTWORK:
//
// 1. SUBTITLE - Hiển thị trường mới trong ListTile subtitle:
//    Thêm dòng Text mới vào Column của subtitle
//
// 2. LOAD - Logic tải dữ liệu:
//    Thường KHÔNG cần sửa vì chỉ hiển thị dữ liệu có sẵn
//
// ⚠️ LƯU Ý: KHÔNG thay đổi các method soft delete (restore, permanentDelete, emptyTrash)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';
import '../providers/shared_preference_provider.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  List<Artwork> _deletedArtworks = [];
  bool _loading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    _userId = getSessionUserId(prefs);
    if (_userId == null) return;
    final list = await DatabaseHelper.instance.getDeletedArtworksByUser(_userId!);
    if (mounted) {
      setState(() {
        _deletedArtworks = list;
        _loading = false;
      });
    }
  }

  // 🔐 KHÔI PHỤC: Đánh dấu isDeleted = 0
  Future<void> _restoreArtwork(Artwork artwork) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Artwork'),
        content: Text('Do you want to restore "${artwork.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && artwork.id != null) {
      await DatabaseHelper.instance.restoreArtwork(artwork.id!);
      if (mounted) {
        setState(() => _deletedArtworks.removeWhere((a) => a.id == artwork.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${artwork.title}" restored successfully')),
        );
      }
    }
  }

  // 🔐 XÓA VĨNH VIỄN: Xóa khỏi database (không thể khôi phục)
  Future<void> _permanentDelete(Artwork artwork) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'Are you sure you want to permanently delete "${artwork.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && artwork.id != null) {
      await DatabaseHelper.instance.permanentDeleteArtwork(artwork.id!);
      if (mounted) {
        setState(() => _deletedArtworks.removeWhere((a) => a.id == artwork.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${artwork.title}" permanently deleted')),
        );
      }
    }
  }

  // 🔐 EMPTY TRASH: Xóa vĩnh viễn tất cả đã xóa mềm
  Future<void> _emptyTrash() async {
    if (_deletedArtworks.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash'),
        content: Text(
          'Are you sure you want to permanently delete all ${_deletedArtworks.length} items in trash? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && _userId != null) {
      await DatabaseHelper.instance.emptyTrash(_userId!);
      if (mounted) {
        setState(() => _deletedArtworks.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trash emptied successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Trash',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🔐 Nút Empty Trash - xóa vĩnh viễn tất cả
          if (_deletedArtworks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Empty Trash',
              onPressed: _emptyTrash,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _deletedArtworks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Trash is empty',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deleted artworks will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _deletedArtworks.length,
                  itemBuilder: (context, i) {
                    final a = _deletedArtworks[i];
                    final deletedDate = a.deletedAt != null
                        ? _formatDate(a.deletedAt!)
                        : 'Unknown';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade300,
                          size: 26,
                        ),
                        title: Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${a.artist} - ${a.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              // TODO [ADD]: Hiển thị trường mới trong subtitle ListTile (TrashScreen)
                              // Ví dụ: + '\nPrice: \$${a.price?.toString() ?? 'N/A'}',
                            ),
                            Text(
                              'Deleted: $deletedDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🔐 Nút Khôi phục
                            IconButton(
                              icon: Icon(
                                Icons.restore,
                                color: Colors.teal.shade400,
                              ),
                              tooltip: 'Restore',
                              onPressed: () => _restoreArtwork(a),
                            ),
                            // 🔐 Nút Xóa vĩnh viễn
                            IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade400,
                              ),
                              tooltip: 'Delete Forever',
                              onPressed: () => _permanentDelete(a),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}
