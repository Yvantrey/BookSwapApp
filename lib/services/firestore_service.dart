import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/user_profile.dart';
import '../models/chat.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Book>> getBooks() {
    return _db.collection('books')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Book.fromMap(doc.data());
          }).toList();
        });
  }

  Stream<List<Book>> getUserBooks(String userId) => _db.collection('books')
      .where('ownerId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList());

  Future<void> addBook(Book book) async {
    await _db.collection('books').doc(book.id).set(book.toMap());
  }

  Future<void> updateBook(Book book) => _db.collection('books').doc(book.id).update(book.toMap());

  Future<void> deleteBook(String bookId) => _db.collection('books').doc(bookId).delete();

  Future<void> createSwapOffer(SwapOffer offer) async {
    await _db.collection('swaps').doc(offer.id).set(offer.toMap());
  }

  Future<void> updateSwapOfferStatus(String offerId, String status) async {
    await _db.collection('swaps').doc(offerId).update({'status': status});
  }

  Stream<List<SwapOffer>> getUserSwapOffers(String userId) {
    return _db.collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .asyncMap((requestedSnapshot) async {
      final requestedOffers = requestedSnapshot.docs.map((doc) => SwapOffer.fromMap(doc.data())).toList();
      
      final receivedSnapshot = await _db.collection('swaps')
          .where('ownerId', isEqualTo: userId)
          .get();
      final receivedOffers = receivedSnapshot.docs.map((doc) => SwapOffer.fromMap(doc.data())).toList();
      
      return [...requestedOffers, ...receivedOffers];
    });
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Chat>> getUserChats(String userId) {
    return _db.collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs.map((doc) => Chat.fromMap(doc.data())).toList();
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return chats;
        });
  }

  Stream<List<Message>> getChatMessages(String chatId) => _db.collection('messages')
      .where('chatId', isEqualTo: chatId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList().reversed.toList());

  Future<String> createOrGetChat(String userId1, String userId2, String bookId) async {
    final participants = [userId1, userId2]..sort();
    final chatQuery = await _db.collection('chats')
        .where('participants', isEqualTo: participants)
        .where('bookId', isEqualTo: bookId)
        .get();
    
    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    }
    
    final chatId = DateTime.now().millisecondsSinceEpoch.toString();
    final chat = Chat(
      id: chatId,
      participants: participants,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      bookId: bookId,
    );
    
    await _db.collection('chats').doc(chatId).set(chat.toMap());
    return chatId;
  }

  Future<void> sendMessage(Message message) async {
    await _db.collection('messages').doc(message.id).set(message.toMap());
    await _db.collection('chats').doc(message.chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
    });
  }
}