import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../widgets/cross_platform_image.dart';
import '../services/permission_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _swapForController = TextEditingController();
  String _condition = 'Good';
  String _category = 'General';
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];
  final List<String> _categories = ['General', 'Textbooks', 'Fiction', 'Non-Fiction', 'Science', 'Mystery and Thriller', 'Literature', 'Technology', 'Other'];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
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
                  labelText: 'Swap for (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'What book do you want in exchange? (Leave blank for any book)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Book Cover (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  if (_selectedImage != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedImage!.path.startsWith('https://')
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                                          Text('Sample Cover', style: TextStyle(color: Colors.grey[600])),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : CrossPlatformImage(
                                  imageSource: _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, size: 50, color: Colors.red),
                                      Text('Error loading image', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                            const Text('Tap to add book cover', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() => _selectedImage = null),
                              child: const Text('Skip for now', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addBook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Post Book', style: TextStyle(fontSize: 16)),
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
                  await _selectImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.collections),
                title: const Text('Sample Photos'),
                onTap: () async {
                  Navigator.pop(context);
                  await _showSamplePhotos();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _takePhotoWithCamera();
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

  Future<void> _selectImageFromGallery() async {
    try {
      final hasPermission = await PermissionService.requestStoragePermission();
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
      

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        
        if (exists && size > 0) {
          setState(() {
            _selectedImage = file;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image selected successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selected image file is invalid or empty'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final hasPermission = await PermissionService.requestCameraPermission();
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
      

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        
        if (exists && size > 0) {
          setState(() {
            _selectedImage = file;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo captured successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Captured photo file is invalid or empty'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSamplePhotos() async {
    final sampleImages = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=600&fit=crop',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Sample Cover'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: sampleImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImage = File(sampleImages[index]);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sample cover selected!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sampleImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: Colors.grey[600]),
                              Text('Nature ${index + 1}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      condition: _condition,
      category: _category,
      swapFor: _swapForController.text.trim(),
      imageUrl: '',
      ownerId: currentUserId,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<BookProvider>().addBook(book, imageFile: _selectedImage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book posted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting book: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}