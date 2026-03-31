import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle({Function(String)? onError}) async {
    try {
      print("Attempting Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return null;
      }
      print("Google User acquired: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Google Auth acquired.");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in to Firebase...");
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print("Firebase User authenticated: ${user.uid}");
        await _createUserInFirestore(user);
        print("Firestore User document ensured.");
      }
      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      if (onError != null) onError(e.toString());
      return null;
    }
  }

  Future<void> _createUserInFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'email': user.email,
        'wallet_balance': 0,
        'total_earned': 0,
        'ads_watched_today': 0,
        'last_ad_watched_time': null,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
