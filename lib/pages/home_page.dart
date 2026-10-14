import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/mood2go_wordmark.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(24),
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
                        'Your preferences are ready.',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
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

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/recommendations'),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Show my recommendations'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/discover'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Discover places'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/group-plan');
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Create New Group Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
