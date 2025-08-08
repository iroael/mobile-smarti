// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      try {
        // Simulasi delay login dengan username/password
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Implement actual username/password login logic here
        // For now, we'll just simulate a successful login

        if (mounted) {
          _showSuccessSnackBar('Login berhasil!');
          // Navigation akan dihandle otomatis oleh AuthWrapper
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Login gagal: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    HapticFeedback.lightImpact();

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (mounted) {
        final user = ref.read(authNotifierProvider).user;
        _showSuccessSnackBar(
          'Login dengan Google berhasil! Selamat datang ${user?.displayName ?? 'User'}',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login dengan Google gagal';

        // Handle specific Firebase Auth errors
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'account-exists-with-different-credential':
              errorMessage = 'Akun sudah terdaftar dengan metode login berbeda';
              break;
            case 'invalid-credential':
              errorMessage = 'Kredensial tidak valid';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Google Sign-In belum diaktifkan';
              break;
            case 'user-disabled':
              errorMessage = 'Akun telah dinonaktifkan';
              break;
            case 'user-not-found':
              errorMessage = 'Akun tidak ditemukan';
              break;
            case 'wrong-password':
              errorMessage = 'Password salah';
              break;
            case 'network-request-failed':
              errorMessage = 'Tidak ada koneksi internet';
              break;
            default:
              errorMessage = 'Terjadi kesalahan: ${e.message}';
          }
        }

        _showErrorSnackBar(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50), // Solid green background
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Logo dengan animasi
                        Hero(
                          tag: 'logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.webp',
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: 80,
                                  color: theme.primaryColor,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Selamat Datang',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Login Petugas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Form Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Username Field
                                  TextFormField(
                                    controller: _usernameController,
                                    enabled: !isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      hintText: 'Masukkan username',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Username tidak boleh kosong';
                                      }
                                      if (value.length < 3) {
                                        return 'Username minimal 3 karakter';
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: !isLoading,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Masukkan password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      }
                                      if (value.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted:
                                        (_) =>
                                            isLoading ? null : _handleLogin(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Remember Me & Forgot Password
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged:
                                            isLoading
                                                ? null
                                                : (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                        activeColor: theme.primaryColor,
                                      ),
                                      const Text('Ingat saya'),
                                      const Spacer(),
                                      TextButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () {
                                                  // TODO: Handle forgot password
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Fitur lupa password akan segera hadir',
                                                      ),
                                                    ),
                                                  );
                                                },
                                        child: Text(
                                          'Lupa Password?',
                                          style: TextStyle(
                                            color:
                                                isLoading
                                                    ? Colors.grey
                                                    : theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                      child:
                                          isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : const Text(
                                                'Masuk',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'atau',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Google Login Button
                                  SizedBox(
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          isLoading ? null : _handleGoogleLogin,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              isLoading
                                                  ? Colors.grey[300]!
                                                  : Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon:
                                          isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Image.asset(
                                                'assets/images/google_logo.png',
                                                height: 20,
                                                width: 20,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const Icon(
                                                    Icons.login,
                                                    size: 20,
                                                    color: Colors.red,
                                                  );
                                                },
                                              ),
                                      label: Text(
                                        'Masuk dengan Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isLoading
                                                  ? Colors.grey[400]
                                                  : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          // TODO: Navigate to register screen
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Halaman registrasi akan segera hadir',
                                              ),
                                            ),
                                          );
                                        },
                                child: Text(
                                  'Daftar',
                                  style: TextStyle(
                                    color:
                                        isLoading ? Colors.grey : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
