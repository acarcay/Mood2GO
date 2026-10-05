import '../widgets/mood_surface.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/mood2go_wordmark.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const darkGreen = Color(0xFF244638);

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'User';
    final preferences = Map<String, dynamic>.from(
      user?.userMetadata?['preferences'] as Map? ?? const {},
    );
    final mood = preferences['mood'] as String? ?? 'Your mood';
    final planType = preferences['plan_type'] as String? ?? 'Your plan';
    final budget = preferences['budget'] as String? ?? 'Your budget';

    return Scaffold(
      appBar: AppBar(
        title: const Mood2GoWordmark(fontSize: 20),
        foregroundColor: darkGreen,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: MoodSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MoodAccent(
                  icon: Icons.wb_sunny_outlined,
                  label: 'A DAY THAT FEELS LIKE YOU',
                ),
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDDEFE2), Color(0xFFEDF5E6)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFCEE2D3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D244638),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: darkGreen,
                        size: 32,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your mood. Your kind of day.',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'A little snapshot of what you love. Update it whenever your mood changes.',
                        style: TextStyle(color: Color(0xFF557360), height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PreferenceTag(mood),
                          _PreferenceTag(planType),
                          _PreferenceTag('$budget budget'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/preferences?edit=true'),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Edit preferences'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkGreen,
                          side: const BorderSide(color: darkGreen),
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
    );
  }
}

class _PreferenceTag extends StatelessWidget {
  const _PreferenceTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: HomePage.darkGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
