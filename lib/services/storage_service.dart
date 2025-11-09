import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadBookImage(File imageFile, String bookId) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final fileExists = await imageFile.exists();
        if (!fileExists) {
          return null;
        }
        
        final fileSize = await imageFile.length();
        if (fileSize == 0 || fileSize > 10 * 1024 * 1024) {
          return null;
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = _storage.ref().child('book_images').child('${bookId}_$timestamp.jpg');
        
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'bookId': bookId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );
        
        final uploadTask = ref.putFile(imageFile, metadata);
        final snapshot = await uploadTask.timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw Exception('Upload timeout after 5 minutes');
          },
        );
        
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        if (downloadUrl.isNotEmpty && downloadUrl.startsWith('https://')) {
          return downloadUrl;
        } else {
          throw Exception('Invalid download URL received: $downloadUrl');
        }
        
      } catch (e) {
        retryCount++;
        
        if (e is FirebaseException) {
          if (e.code == 'unauthorized' || e.code == 'invalid-argument') {
            break;
          }
        }
        
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    
    return null;
  }

  Future<void> deleteBookImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      return;
    }
  }
}