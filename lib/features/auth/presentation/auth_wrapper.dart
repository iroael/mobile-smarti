// lib/features/auth/presentation/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_service.dart';
import 'login_screen.dart';
import '../../home/presentation/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF4CAF50),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is signed in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // If user is not signed in, show login screen
        return const LoginScreen();
      },
    );
  }
}

// Alternative wrapper for specific use cases
class ConditionalAuthWrapper extends StatelessWidget {
  final Widget authenticatedWidget;
  final Widget unauthenticatedWidget;
  final Widget? loadingWidget;

  const ConditionalAuthWrapper({
    super.key,
    required this.authenticatedWidget,
    required this.unauthenticatedWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return authenticatedWidget;
        }

        return unauthenticatedWidget;
      },
    );
  }
}
