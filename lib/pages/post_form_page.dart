import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';
import '../services/category_service.dart';
import '../services/post_service.dart';

class PostFormPage extends StatefulWidget {
  final PostModel? existingPost; // null = mode tambah, ada isi = mode edit

  const PostFormPage({super.key, this.existingPost});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late Future<List<CategoryModel>> _futureCategories;
  int? _selectedCategoryId;
  bool _isSubmitting = false;
  File? _selectedImage; // dipakai kalau bukan web
  Uint8List? _selectedImageBytes; // dipakai kalau web
  String? _selectedImageName;

  bool get _hasImage =>
      kIsWeb ? _selectedImageBytes != null : _selectedImage != null;
  bool get _isEdit => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryService.getAllCategories();

    final existing = widget.existingPost;
    if (existing != null) {
      _titleController.text = existing.title;
      _contentController.text = existing.content;
      _selectedCategoryId = existing.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null;
        });
      }
    }
  }

  InputDecoration _inputStyle(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnack('Pilih kategori terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        await PostService.updatePost(
          id: widget.existingPost!.id,
          title: _titleController.text,
          content: _contentController.text,
          categoryId: _selectedCategoryId!,
          imageFile: _selectedImage,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
        if (!mounted) return;
        _showSnack('Artikel berhasil diperbarui!');

        final categories = await _futureCategories;
        final categoryName = categories
            .firstWhere((c) => c.id == _selectedCategoryId,
                orElse: () => categories.first)
            .name;

        final updated = PostModel(
          id: widget.existingPost!.id,
          title: _titleController.text,
          slug: widget.existingPost!.slug,
          content: _contentController.text,
          thumbnail: widget.existingPost!.thumbnail, // thumbnail baru butuh refetch, dipertahankan dulu
          categoryId: _selectedCategoryId!,
          categoryName: categoryName,
          createdAt: widget.existingPost!.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );

        if (!mounted) return;
        Navigator.pop(context, updated); // balik ke detail page, bawa data baru
        return;
      } else {
        await PostService.createPost(
          title: _titleController.text,
          content: _contentController.text,
          categoryId: _selectedCategoryId!,
          imageFile: _selectedImage,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
        if (!mounted) return;
        _showSnack('Artikel berhasil dibuat!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Artikel' : 'Tulis Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Area pilih gambar
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[300]!),
                    image: !_hasImage
                        ? (_isEdit && widget.existingPost!.thumbnail != null
                            ? DecorationImage(
                                image: NetworkImage(widget.existingPost!.thumbnail!),
                                fit: BoxFit.cover,
                              )
                            : null)
                        : (kIsWeb
                            ? DecorationImage(
                                image: MemoryImage(_selectedImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )),
                  ),
                  child: !_hasImage && !(_isEdit && widget.existingPost!.thumbnail != null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: Colors.grey[500]),
                            const SizedBox(height: 8),
                            Text('Tambahkan Gambar',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                onPressed: () => setState(() {
                                  _selectedImage = null;
                                  _selectedImageBytes = null;
                                  _selectedImageName = null;
                                }),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 22),

              _sectionLabel('JUDUL ARTIKEL'),
              TextFormField(
                controller: _titleController,
                decoration: _inputStyle('Judul', hint: 'Masukkan judul artikel'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _sectionLabel('KATEGORI'),
              FutureBuilder<List<CategoryModel>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Gagal memuat kategori: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: _inputStyle('Pilih kategori'),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              _sectionLabel('ISI ARTIKEL'),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: _inputStyle('Tulis isi artikel di sini...'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi artikel tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Simpan Artikel',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}