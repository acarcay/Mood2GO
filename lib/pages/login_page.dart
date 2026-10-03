import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const darkGreen = Color(0xFF244638);
  static const lightGreen = Color(0xFFE4F2E8);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Enter your email and password.');
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (mounted) context.go('/home');
    } on AuthException catch (error) {
      if (!mounted) return;
      final invalidLogin = error.message.toLowerCase().contains(
        'invalid login',
      );
      showMessage(
        invalidLogin ? 'Incorrect email or password.' : error.message,
      );
    } catch (error) {
      if (mounted) {
        showMessage('Something went wrong. Check your internet connection.');
      }
      debugPrint('Sign-in error: $error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/'),
                style: IconButton.styleFrom(
                  backgroundColor: lightGreen,
                  foregroundColor: darkGreen,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to continue where you left off.',
                style: TextStyle(
                  color: Color(0xFF718078),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              const _FieldLabel('Email'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'ornek@email.com',
                  icon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Password'),
              TextField(
                controller: passwordController,
                obscureText: isPasswordHidden,
                onSubmitted: (_) => login(),
                decoration: _inputDecoration(
                  hintText: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => isPasswordHidden = !isPasswordHidden),
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      showMessage('Password reset will be available soon.'),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : login,
                  style: FilledButton.styleFrom(
                    backgroundColor: darkGreen,
                    disabledBackgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have an account?',
                    style: TextStyle(color: Color(0xFF718078)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9AA69F)),
      prefixIcon: Icon(icon, color: const Color(0xFF718078)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: border(const Color(0xFFDCE7DF)),
      enabledBorder: border(const Color(0xFFDCE7DF)),
      focusedBorder: border(const Color(0xFF92C9A3), width: 2),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _LoginPageState.darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
