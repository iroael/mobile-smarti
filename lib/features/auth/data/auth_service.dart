// lib/features/auth/data/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Regular email/password login
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Sign up with email/password
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}
