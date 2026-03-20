import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';
import '../providers/shared_preference_provider.dart';
import 'add_screen.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';
import 'login_screen.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  List<Artwork> _artworks = [];
  List<Artwork> _filtered = [];
  bool _loading = true;
  String? _username;
  int? _userId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // TODO [ADD]: dispose controller mới ở đây (nếu có)
    // Ví dụ: _priceController.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_artworks);
      } else {
        _filtered = _artworks
            .where(
              (a) =>
          a.title.toLowerCase().contains(query) ||
              a.artist.toLowerCase().contains(query),
          // TODO [ADD]: Thêm trường mới vào điều kiện tìm kiếm
          // Ví dụ: || a.category.toLowerCase().contains(query)
          // Ví dụ: || a.year.toString().contains(query)
        )
            .toList();
      }
    });
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    _userId = getSessionUserId(prefs);
    _username = getSessionUsername(prefs);

    // [FIX] tránh loading mãi nếu chưa có user
    if (_userId == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    final list = await DatabaseHelper.instance.getArtworksByUser(_userId!);

    if (mounted) {
      setState(() {
        _artworks = list;
        _filtered = list;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    clearSession(prefs);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _deleteArtwork(Artwork artwork) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: const Text('Are you sure you want to delete this artwork?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
      if (mounted) {
        setState(() {
          _artworks.removeWhere((a) => a.id == artwork.id);
          _filtered.removeWhere((a) => a.id == artwork.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artwork deleted successfully')),
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
          'Art Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/banner.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome ${_username ?? "User"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _onSearch(value);
              setState(() {}); // [FIX] refresh suffixIcon clear
            },
            decoration: InputDecoration(
              hintText: 'Search by title or artist...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                  setState(() {}); // [FIX]
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Result count
          if (!_loading && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_filtered.length} result${_filtered.length == 1 ? '' : 's'} found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  _searchController.text.isNotEmpty
                      ? 'No artworks match "${_searchController.text}"'
                      : 'No artworks yet. Tap + to add one!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Column(
              children: [
                // ================== LIST VIEW ==================

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final a = _filtered[i];
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
                        leading: const Icon(
                          Icons.palette_outlined,
                          color: Colors.grey,
                          size: 26,
                        ),
                        title: Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${a.artist} - ${a.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          // TODO [ADD]: Hiển thị trường mới trong subtitle ListTile (nếu cần)
                          // Ví dụ: + '\nPrice: \$${a.price?.toString() ?? 'N/A'}',
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(artworkId: a.id!),
                            ),
                          );
                          _load();
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditScreen(artworkId: a.id!),
                                  ),
                                );
                                _load();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () => _deleteArtwork(a),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ================== GRID VIEW ==================
                // GridView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemCount: _filtered.length,
                //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2,
                //     crossAxisSpacing: 12,
                //     mainAxisSpacing: 12,
                //     childAspectRatio: 0.82,
                //   ),
                //   itemBuilder: (context, i) {
                //     final a = _filtered[i];
                //     return Container(
                //       padding: const EdgeInsets.all(12),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //       child: InkWell(
                //         borderRadius: BorderRadius.circular(14),
                //         onTap: () async {
                //           await Navigator.of(context).push(
                //             MaterialPageRoute(
                //               builder: (_) => DetailScreen(artworkId: a.id!),
                //             ),
                //           );
                //           _load();
                //         },
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               a.title,
                //               maxLines: 1,
                //               overflow: TextOverflow.ellipsis,
                //               style: const TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //             const SizedBox(height: 6),
                //             Text(
                //               'Artist: ${a.artist}',
                //               maxLines: 1,
                //               overflow: TextOverflow.ellipsis,
                //               style: const TextStyle(fontSize: 12),
                //             ),
                //             Text(
                //               'Year: ${a.year}',
                //               style: const TextStyle(fontSize: 12),
                //             ),
                //
                //             // TODO [ADD]: Thêm field mới vào card GridView nếu cần
                //             // Ví dụ:
                //             // Text(
                //             //   'Category: ${a.category}',
                //             //   maxLines: 1,
                //             //   overflow: TextOverflow.ellipsis,
                //             //   style: const TextStyle(fontSize: 12),
                //             // ),
                //
                //             const Spacer(),
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               children: [
                //                 IconButton(
                //                   icon: const Icon(
                //                     Icons.edit_outlined,
                //                     color: Colors.grey,
                //                   ),
                //                   onPressed: () async {
                //                     await Navigator.of(context).push(
                //                       MaterialPageRoute(
                //                         builder: (_) =>
                //                             EditScreen(artworkId: a.id!),
                //                       ),
                //                     );
                //                     _load();
                //                   },
                //                 ),
                //                 IconButton(
                //                   icon: const Icon(
                //                     Icons.delete_outline,
                //                     color: Colors.grey,
                //                   ),
                //                   onPressed: () => _deleteArtwork(a),
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddScreen()));
          _load();
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Artwork', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}