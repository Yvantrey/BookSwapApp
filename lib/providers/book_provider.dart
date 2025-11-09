import 'package:flutter/material.dart';
import 'dart:io';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/user_profile.dart';
import '../models/chat.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  List<Book> _books = [];
  List<Book> _userBooks = [];
  List<SwapOffer> _userOffers = [];
  UserProfile? _userProfile;
  List<Chat> _userChats = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  List<Book> get userBooks => _userBooks;
  List<SwapOffer> get userOffers => _userOffers;
  UserProfile? get userProfile => _userProfile;
  List<Chat> get userChats => _userChats;
  bool get isLoading => _isLoading;

  void listenToBooks() {
    _firestoreService.getBooks().listen((books) {
      _books = books;
      notifyListeners();
    });
  }

  void listenToUserBooks(String userId) {
    _firestoreService.getUserBooks(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  void listenToUserOffers(String userId) {
    _firestoreService.getUserSwapOffers(userId).listen((offers) {
      _userOffers = offers;
      notifyListeners();
    });
  }

  Future<void> addBook(Book book, {File? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      String imageUrl = book.imageUrl;
      
      // Upload image to Firebase Storage if provided
      if (imageFile != null) {
        final uploadedUrl = await _storageService.uploadBookImage(imageFile, book.id);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }
      
      // Create book with uploaded image URL
      final bookWithImage = Book(
        id: book.id,
        title: book.title,
        author: book.author,
        condition: book.condition,
        category: book.category,
        imageUrl: imageUrl,
        ownerId: book.ownerId,
        status: book.status,
        createdAt: book.createdAt,
      );
      
      await _firestoreService.addBook(bookWithImage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book, {File? imageFile}) async {
    String imageUrl = book.imageUrl;
    
    // Upload new image if provided
    if (imageFile != null) {
      final uploadedUrl = await _storageService.uploadBookImage(imageFile, book.id);
      if (uploadedUrl != null) {
        // Delete old image if it exists and is from Firebase Storage
        if (book.imageUrl.isNotEmpty && book.imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
          await _storageService.deleteBookImage(book.imageUrl);
        }
        imageUrl = uploadedUrl;
      }
    }
    
    // Create updated book with new image URL
    final updatedBook = Book(
      id: book.id,
      title: book.title,
      author: book.author,
      condition: book.condition,
      category: book.category,
      imageUrl: imageUrl,
      ownerId: book.ownerId,
      status: book.status,
      createdAt: book.createdAt,
    );
    
    await _firestoreService.updateBook(updatedBook);
  }

  Future<void> deleteBook(String bookId) async {
    // Get book to delete its image
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => _userBooks.firstWhere((b) => b.id == bookId));
    
    // Delete image from storage if it exists
    if (book.imageUrl.isNotEmpty && book.imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      await _storageService.deleteBookImage(book.imageUrl);
    }
    
    await _firestoreService.deleteBook(bookId);
  }

  Future<void> createSwapOffer(SwapOffer offer) async {
    await _firestoreService.createSwapOffer(offer);
  }

  Future<void> loadUserProfile(String userId) async {
    _userProfile = await _firestoreService.getUserProfile(userId);
    notifyListeners();
  }

  void listenToUserChats(String userId) {
    _firestoreService.getUserChats(userId).listen((chats) {
      _userChats = chats;
      notifyListeners();
    });
  }

  Future<String> createChat(String otherUserId, String bookId, String currentUserId) async {
    return await _firestoreService.createOrGetChat(currentUserId, otherUserId, bookId);
  }
}