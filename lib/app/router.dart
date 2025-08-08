import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart'; // Import home screen

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
