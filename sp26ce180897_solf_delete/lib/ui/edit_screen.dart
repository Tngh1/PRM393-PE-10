// ============================================================
// 💾 HƯỚNG DẪN THÊM TRƯỜNG MỚI VÀO EDIT SCREEN
// ============================================================
// KHI THÊM TRƯỜNG MỚI VÀO ARTWORK:
//
// 1. CONTROLLER - Khai báo controller:
//    Thêm: final _newController = TextEditingController();
//
// 2. LOAD - Gán giá trị từ artwork:
//    Thêm: _newController.text = artwork.newField ?? '';
//
// 3. DISPOSE - Giải phóng bộ nhớ:
//    Thêm: _newController.dispose();
//
// 4. WIDGET - Thêm form field vào build():
//    Thêm: _buildField(_newController, 'Label', Icons.icon, ...)
//
// 5. SUBMIT - Truyền vào constructor:
//    Thêm: newField: _newController.text.trim(),
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';

class EditScreen extends ConsumerStatefulWidget {
  final int artworkId;

  const EditScreen({super.key, required this.artworkId});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Painting';
  bool _isLoading = false;
  Artwork? _artwork;

  // TODO [ADD]: Khai báo controller mới cho trường mới
  // Ví dụ: final _priceController = TextEditingController();
  // Ví dụ: final _imageUrlController = TextEditingController();

  final _categories = [
    'Painting', 'Sculpture', 'Photography', 'Digital Art',
    'Drawing', 'Print', 'Installation', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await DatabaseHelper.instance.getArtworkById(widget.artworkId);
    if (a != null && mounted) {
      setState(() {
        _artwork = a;
        _titleController.text = a.title;
        _artistController.text = a.artist;
        _yearController.text = a.year.toString();
        _descriptionController.text = a.description;
        _selectedCategory = a.category;
        // TODO [ADD]: Gán giá trị trường mới từ artwork vào controller
        // Ví dụ: _priceController.text = a.price?.toString() ?? '';
        // Ví dụ: _imageUrlController.text = a.imageUrl ?? '';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    // TODO [ADD]: dispose controller mới ở đây
    // Ví dụ: _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_artwork == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Artwork')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        title: const Text('Edit Artwork', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Artwork', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                const SizedBox(height: 16),
                _buildField(_titleController, 'Title', Icons.text_fields, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 16),
                _buildField(_artistController, 'Artist', Icons.person_outline, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 16),
                _buildField(_yearController, 'Year', Icons.calendar_today, keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Required';
                    final y = int.tryParse(v!);
                    return (y == null || y < 0 || y > 2100) ? 'Invalid year' : null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedCategory = v!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildField(_descriptionController, 'Description', Icons.align_horizontal_left, maxLines: 4,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
                // TODO [ADD]: Thêm widget nhập liệu cho trường mới vào đây
                // Ví dụ: _buildField(_priceController, 'Price', Icons.attach_money, keyboardType: TextInputType.number, ...)
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Update Artwork', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _artwork == null) return;
    setState(() => _isLoading = true);
    try {
      final u = Artwork(
        id: widget.artworkId,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        createdBy: _artwork!.createdBy,
        // TODO [ADD]: Truyền trường mới vào Artwork constructor
        // Ví dụ: price: double.tryParse(_priceController.text.trim()),
        // Ví dụ: imageUrl: _imageUrlController.text.trim(),
      );
      await DatabaseHelper.instance.updateArtwork(u);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artwork updated successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
