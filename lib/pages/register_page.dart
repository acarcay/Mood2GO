import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const darkGreen = Color(0xFF244638);
  static const lightGreen = Color(0xFFE4F2E8);
  static const primaryGreen = Color(0xFF92C9A3);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordAgainController = TextEditingController();
  bool isPasswordHidden = true;
  bool isPasswordAgainHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordAgainController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordAgain = passwordAgainController.text;

    if ([name, email, password, passwordAgain].any((value) => value.isEmpty)) {
      showMessage('Lütfen bütün alanları doldur.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Geçerli bir e-posta adresi gir.');
      return;
    }
    if (password.length < 6) {
      showMessage('Şifre en az 6 karakter olmalı.');
      return;
    }
    if (password != passwordAgain) {
      showMessage('Girdiğin şifreler aynı değil.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (!mounted) return;
      if (response.user == null) {
        showMessage('Hesap oluşturulamadı. Tekrar deneyin.');
        return;
      }

      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go('/login');
      showMessage('Hesabın oluşturuldu. Şimdi giriş yapabilirsin.');
    } on AuthException catch (error) {
      if (!mounted) return;
      final alreadyRegistered = error.message.toLowerCase().contains(
        'already registered',
      );
      showMessage(
        alreadyRegistered ? 'Bu e-posta adresi zaten kayıtlı.' : error.message,
      );
    } catch (error) {
      if (mounted) {
        showMessage('Bir hata oluştu. İnternet bağlantını kontrol et.');
      }
      debugPrint('Kayıt hatası: $error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
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
              const SizedBox(height: 36),
              const Text(
                'Hesabını oluştur',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sana uygun öneriler hazırlayabilmemiz için hesabını oluştur.',
                style: TextStyle(
                  color: Color(0xFF718078),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              const _FieldLabel('Ad ve soyad'),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hintText: 'Adını ve soyadını gir',
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('E-posta'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'ornek@email.com',
                  icon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Şifre'),
              TextField(
                controller: passwordController,
                obscureText: isPasswordHidden,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'En az 6 karakter',
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
              const SizedBox(height: 18),
              const _FieldLabel('Şifre tekrar'),
              TextField(
                controller: passwordAgainController,
                obscureText: isPasswordAgainHidden,
                onSubmitted: (_) => register(),
                decoration: _inputDecoration(
                  hintText: 'Şifreni tekrar gir',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => isPasswordAgainHidden = !isPasswordAgainHidden,
                    ),
                    icon: Icon(
                      isPasswordAgainHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : register,
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
                          'Hesap oluştur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Zaten hesabın var mı?',
                    style: TextStyle(color: Color(0xFF718078)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Giriş yap',
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
      focusedBorder: border(primaryGreen, width: 2),
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
          color: _RegisterPageState.darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
