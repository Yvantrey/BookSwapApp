import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    await result.user!.sendEmailVerification();
    
    final userProfile = UserProfile(
      uid: result.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(result.user!.uid).set(userProfile.toMap());
    return result;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result;
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<bool> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}