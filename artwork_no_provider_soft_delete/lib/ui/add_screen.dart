import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/artwork.dart';
import '../providers/shared_preference_provider.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Painting';
  bool _isLoading = false;

  // TODO [ADD]: Khai báo controller mới cho trường mới
  // Ví dụ: final _priceController = TextEditingController();
  // Ví dụ: final _imageUrlController = TextEditingController();

  final _categories = [
    'Painting', 'Sculpture', 'Photography', 'Digital Art',
    'Drawing', 'Print', 'Installation', 'Other',
  ];

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        title: const Text('Add Artwork', style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text('New Artwork', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                const SizedBox(height: 16),
                _buildField(_titleController, 'Title', Icons.text_fields, validator: (v) => v?.isEmpty == true ? 'Title is required' : null),
                const SizedBox(height: 16),
                _buildField(_artistController, 'Artist', Icons.person_outline, validator: (v) => v?.isEmpty == true ? 'Artist is required' : null),
                const SizedBox(height: 16),
                _buildField(_yearController, 'Year', Icons.calendar_today, keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Year is required';
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
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                _buildField(_descriptionController, 'Description', Icons.align_horizontal_left, maxLines: 4,
                  validator: (v) => v?.isEmpty == true ? 'Description is required' : null),
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
                        : const Text('Save Artwork', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final userId = getSessionUserId(prefs);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final artwork = Artwork(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        createdBy: userId,
        // TODO [ADD]: Truyền trường mới vào Artwork constructor
        // Ví dụ: price: double.tryParse(_priceController.text.trim()),
        // Ví dụ: imageUrl: _imageUrlController.text.trim(),
      );
      await DatabaseHelper.instance.createArtwork(artwork);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artwork added successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
