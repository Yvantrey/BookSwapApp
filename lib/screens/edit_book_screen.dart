import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../widgets/cross_platform_image.dart';
import '../services/permission_service.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  
  const EditBookScreen({super.key, required this.book});

  @override
  EditBookScreenState createState() => EditBookScreenState();
}

class EditBookScreenState extends State<EditBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _swapForController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _condition = 'Good';
  String _category = 'General';
  File? _selectedImage;
  bool _isLoading = false;
  
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];
  final List<String> _categories = ['General', 'Textbooks', 'Fiction', 'Non-Fiction', 'Science', 'Mystery and Thriller', 'Literature', 'Technology', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book.title;
    _authorController.text = widget.book.author;
    _swapForController.text = widget.book.swapFor;
    _condition = widget.book.condition;
    _category = widget.book.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _condition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: _conditions.map((condition) => DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                )).toList(),
                onChanged: (value) => setState(() => _condition = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _swapForController,
                decoration: const InputDecoration(
                  labelText: 'Swap for (What book do you want in exchange?)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Harry Potter series, Programming books, etc.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Book Cover (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CrossPlatformImage(
                            imageSource: _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : widget.book.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CrossPlatformImage(
                                imageSource: widget.book.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                Text('Tap to change book cover', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateBook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Update Book', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final hasPermission = await PermissionService.requestStoragePermission();
                  if (!hasPermission) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Storage permission is required to select images'),
                          action: SnackBarAction(
                            label: 'Settings',
                            onPressed: PermissionService.openAppSettings,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error selecting image: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  
                  final scaffoldMessenger2 = ScaffoldMessenger.of(context);
                  final hasPermission = await PermissionService.requestCameraPermission();
                  if (!hasPermission) {
                    if (mounted) {
                      scaffoldMessenger2.showSnackBar(
                        const SnackBar(
                          content: Text('Camera permission is required to take photos'),
                          action: SnackBarAction(
                            label: 'Settings',
                            onPressed: PermissionService.openAppSettings,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger2.showSnackBar(
                        SnackBar(content: Text('Error taking photo: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening image picker: $e')),
        );
      }
    }
  }

  void _updateBook() async {
    if (_titleController.text.trim().isEmpty || _authorController.text.trim().isEmpty || _swapForController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedBook = Book(
        id: widget.book.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _condition,
        category: _category,
        swapFor: _swapForController.text.trim(),
        imageUrl: widget.book.imageUrl,
        ownerId: widget.book.ownerId,
        status: widget.book.status,
        createdAt: widget.book.createdAt,
      );

      await context.read<BookProvider>().updateBook(updatedBook, imageFile: _selectedImage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating book: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _swapForController.dispose();
    super.dispose();
  }
}