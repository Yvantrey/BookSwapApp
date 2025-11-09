import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/user_profile.dart';
import '../models/chat.dart';
import '../services/firestore_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
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

  Future<void> addBook(Book book) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addBook(book);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    await _firestoreService.updateBook(book);
  }

  Future<void> deleteBook(String bookId) async {
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