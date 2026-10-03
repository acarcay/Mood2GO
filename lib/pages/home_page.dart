import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const darkGreen = Color(0xFF244638);
  static const lightGreen = Color(0xFFE4F2E8);

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Kullanıcı';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'moduna göre',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        foregroundColor: darkGreen,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            tooltip: 'Çıkış yap',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, $name',
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: Color(0xFF718078), fontSize: 15),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: darkGreen,
                      size: 32,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sana uygun önerileri hazırlayalım.',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bir sonraki adımda tercihlerini belirleyeceğiz.',
                      style: TextStyle(
                        color: Color(0xFF718078),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
