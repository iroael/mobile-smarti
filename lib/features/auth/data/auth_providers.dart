// lib/features/auth/data/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Auth state provider (for easier access)
final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(currentUserProvider);
});

// Auth notifier for handling auth operations
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Auth state classes
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        state = state.copyWith(user: result.user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign in was cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Email/Password Sign In
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithEmailPassword(
        email,
        password,
      );
      if (result != null) {
        state = state.copyWith(user: result.user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
