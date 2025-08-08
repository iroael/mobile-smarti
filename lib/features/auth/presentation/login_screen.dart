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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      try {
        // Set loading state
        ref.read(authNotifierProvider.notifier).setLoading(true);

        // Call login method with username and password
        await ref
            .read(authNotifierProvider.notifier)
            .signInWithUsernamePassword(
              _usernameController.text.trim(),
              _passwordController.text,
            );

        if (mounted) {
          final user = ref.read(authNotifierProvider).user;
          _showSuccessSnackBar(
            'Login berhasil! Selamat datang ${user?.displayName ?? 'User'}',
          );

          // Save remember me preference if needed
          if (_rememberMe) {
            // TODO: Save remember me to secure storage
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Login gagal';

          // Handle specific error messages
          if (e.toString().contains('invalid-credentials')) {
            errorMessage = 'Username atau password salah';
          } else if (e.toString().contains('user-not-found')) {
            errorMessage = 'Username tidak ditemukan';
          } else if (e.toString().contains('wrong-password')) {
            errorMessage = 'Password salah';
          } else if (e.toString().contains('too-many-requests')) {
            errorMessage = 'Terlalu banyak percobaan login. Coba lagi nanti';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Tidak ada koneksi internet';
          } else {
            errorMessage = 'Terjadi kesalahan: ${e.toString()}';
          }

          _showErrorSnackBar(errorMessage);
        }
      } finally {
        if (mounted) {
          ref.read(authNotifierProvider.notifier).setLoading(false);
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
            case 'popup-closed-by-user':
              errorMessage = 'Login dibatalkan oleh user';
              break;
            case 'cancelled-popup-request':
              return; // Don't show error for cancelled popup
            default:
              errorMessage = 'Terjadi kesalahan: ${e.message}';
          }
        } else if (e.toString().contains('network')) {
          errorMessage = 'Tidak ada koneksi internet';
        }

        _showErrorSnackBar(errorMessage);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    // Show dialog for forgot password
    final email = await _showForgotPasswordDialog();
    if (email != null && email.isNotEmpty) {
      try {
        // TODO: Implement forgot password logic
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        if (mounted) {
          _showSuccessSnackBar('Email reset password telah dikirim ke $email');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal mengirim email reset password');
        }
      }
    }
  }

  Future<String?> _showForgotPasswordDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Masukkan email Anda untuk reset password:'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'contoh@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Kirim'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Logo dengan animasi
                          Hero(
                            tag: 'logo',
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 25,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.webp',
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.electrical_services,
                                          size: 80,
                                          color: theme.primaryColor,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title with animation
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Selamat Datang',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pencatatan Meteran Listrik',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 48),

                          // Form Card
                          Card(
                            elevation: 16,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Form Title
                                    Text(
                                      'Masuk Akun',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 32),

                                    // Username Field
                                    TextFormField(
                                      controller: _usernameController,
                                      enabled: !isLoading,
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        hintText: 'Masukkan username',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: isLoading ? Colors.grey : null,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor:
                                            isLoading
                                                ? Colors.grey[50]
                                                : Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Username tidak boleh kosong';
                                        }
                                        if (value.length < 3) {
                                          return 'Username minimal 3 karakter';
                                        }
                                        if (value.contains(' ')) {
                                          return 'Username tidak boleh mengandung spasi';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: isLoading ? Colors.grey : null,
                                      ),
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
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: isLoading ? Colors.grey : null,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color:
                                                isLoading ? Colors.grey : null,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor:
                                            isLoading
                                                ? Colors.grey[50]
                                                : Colors.grey[50],
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
                                      style: TextStyle(
                                        color: isLoading ? Colors.grey : null,
                                      ),
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
                                        Text(
                                          'Ingat saya',
                                          style: TextStyle(
                                            color:
                                                isLoading ? Colors.grey : null,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed:
                                              isLoading
                                                  ? null
                                                  : _handleForgotPassword,
                                          child: Text(
                                            'Lupa Password?',
                                            style: TextStyle(
                                              color:
                                                  isLoading
                                                      ? Colors.grey
                                                      : theme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 28),

                                    // Login Button
                                    SizedBox(
                                      height: 56,
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
                                          elevation: 6,
                                          shadowColor: theme.primaryColor
                                              .withOpacity(0.3),
                                        ),
                                        child:
                                            isLoading
                                                ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Masuk...',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
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
                                      height: 56,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : _handleGoogleLogin,
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
                                                  height: 24,
                                                  width: 24,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.login,
                                                      size: 24,
                                                      color: Colors.blue,
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

                          const Spacer(flex: 2),

                          // Footer
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Belum punya akun? ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
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
                                                  SnackBar(
                                                    content: const Text(
                                                      'Fitur registrasi akan segera hadir',
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                  ),
                                                );
                                              },
                                      child: Text(
                                        'Daftar',
                                        style: TextStyle(
                                          color:
                                              isLoading
                                                  ? Colors.grey
                                                  : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // App version or copyright
                                Text(
                                  '© 2024 Pencatatan Meteran Listrik v1.0',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
