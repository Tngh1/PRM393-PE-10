import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';
import '../providers/shared_preference_provider.dart';
import 'edit_screen.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int artworkId;

  const DetailScreen({super.key, required this.artworkId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  Artwork? _artwork;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await DatabaseHelper.instance.getArtworkById(widget.artworkId);
    if (mounted) setState(() {
      _artwork = a;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _artwork == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artwork Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final artwork = _artwork!;
    final prefs = ref.read(sharedPreferencesProvider);
    final currentUserId = getSessionUserId(prefs);
    final isOwner = currentUserId == artwork.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artwork Detail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(artwork.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  _row('Artist:', artwork.artist),
                  const SizedBox(height: 12),
                  _row('Year:', artwork.year.toString()),
                  const SizedBox(height: 12),
                  _row('Category:', artwork.category),
                  // TODO [ADD]: Hiển thị trường mới ở đây (Detail)
                  // Ví dụ: _row('Price:', '\$${artwork.price?.toString() ?? 'N/A'}'),
                  // Ví dụ: _row('Image URL:', artwork.imageUrl ?? 'N/A'),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(artwork.description.isEmpty ? 'No description' : artwork.description,
                      style: const TextStyle(fontSize: 16, height: 1.4)),
                ],
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditScreen(artworkId: artwork.id!)),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context, artwork),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Delete', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 95, child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 18, color: Colors.black87))),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Artwork artwork) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: const Text('Are you sure you want to delete this artwork?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && artwork.id != null) {
      await DatabaseHelper.instance.deleteArtwork(artwork.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artwork deleted successfully')));
        Navigator.pop(context);
      }
    }
  }
}
