// lib/features/auth/data/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/models/user_model.dart';
import '../domain/models/auth_state.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Auth Stream Provider for listening to auth changes
final authStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Auth Repository Class
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with username/password (using email as username for Firebase)
  Future<UserCredential> signInWithUsernamePassword(
    String username,
    String password,
  ) async {
    try {
      // For demo purposes, we'll use predefined credentials
      // In production, you might want to map username to email or use custom auth

      // Demo credentials
      final Map<String, String> demoUsers = {
        'admin': 'admin@smarti.com',
        'petugas1': 'petugas1@smarti.com',
        'petugas2': 'petugas2@smarti.com',
        'operator': 'operator@smarti.com',
      };

      final email = demoUsers[username.toLowerCase()];
      if (email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Username tidak ditemukan',
        );
      }

      // Try to sign in with email and password
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Username tidak ditemukan');
        case 'wrong-password':
          throw Exception('Password salah');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan login. Coba lagi nanti');
        case 'network-request-failed':
          throw Exception('Tidak ada koneksi internet');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login Google dibatalkan');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Akun sudah terdaftar dengan metode login berbeda');
        case 'invalid-credential':
          throw Exception('Kredensial tidak valid');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In belum diaktifkan');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'network-request-failed':
          throw Exception('Tidak ada koneksi internet');
        default:
          throw Exception('Login Google gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  // Convert Firebase User to UserModel
  UserModel? _userFromFirebase(User? firebaseUser) {
    if (firebaseUser == null) return null;

    // Extract username from email (before @)
    String? username;
    if (firebaseUser.email != null) {
      username = firebaseUser.email!.split('@').first;
    }

    return UserModel(
      id: firebaseUser.uid,
      username: username ?? 'user',
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? username ?? 'User',
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  // Get user model from current user
  UserModel? getCurrentUserModel() {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }
}

// Auth Notifier Class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  // Initialize and listen to auth changes
  void _init() {
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        final userModel = _repository.getCurrentUserModel();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: userModel,
          error: null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          error: null,
          isLoading: false,
        );
      }
    });
  }

  // Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading, error: null);
  }

  // Sign in with username and password
  Future<void> signInWithUsernamePassword(
    String username,
    String password,
  ) async {
    try {
      setLoading(true);

      final credential = await _repository.signInWithUsernamePassword(
        username,
        password,
      );
      final userModel = _repository._userFromFirebase(credential.user);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userModel,
        error: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);

      final credential = await _repository.signInWithGoogle();
      final userModel = _repository._userFromFirebase(credential.user);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userModel,
        error: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      setLoading(true);

      await _repository.signOut();

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      setLoading(true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setLoading(false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Helper providers for easy access
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});
