import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadBookImage(File imageFile, String bookId) async {
    try {
      final ref = _storage.ref().child('book_images').child('$bookId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteBookImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}