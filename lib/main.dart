import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/preferences_page.dart';
import 'services/auth_notifier.dart';
import 'widgets/mood2go_wordmark.dart';
import 'pages/group_plan_page.dart';

late final GoRouter router;
late final AuthNotifier authNotifier;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ntwnrorwpgsocgqwtklu.supabase.co',
    publishableKey: 'sb_publishable_QJTC6mOWiZF-L_pfi88VTw_KqIH4Uhy',
  );

  authNotifier = AuthNotifier(Supabase.instance.client);
  router = GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final location = state.uri.path;
      final isPublic = ['/', '/login', '/register'].contains(location);

      if (user == null) {
        return isPublic ? null : '/';
      }

      final preferencesCompleted =
          user.userMetadata?['preferences_completed'] == true;
      final editingPreferences = state.uri.queryParameters['edit'] == 'true';

      if (!preferencesCompleted && location != '/preferences') {
        return '/preferences';
      }
      if (preferencesCompleted && isPublic) {
        return '/home';
      }
      if (preferencesCompleted &&
          location == '/preferences' &&
          !editingPreferences) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => const PreferencesPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/group-plan',
        builder: (context, state) => const GroupPlanPage(),
      ),
    ],
  );

  runApp(const Mood2GoApp());
}

class Mood2GoApp extends StatelessWidget {
  const Mood2GoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mood2GO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFCFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8FC9A3),
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color primaryGreen = Color(0xFF92C9A3);
  static const Color darkGreen = Color(0xFF244638);
  static const Color lightGreen = Color(0xFFE4F2E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AppLogo(),

              const Spacer(),

              const _WelcomeVisual(),

              const SizedBox(height: 40),

              const Text(
                'Find something\nthat fits your mood.',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 38,
                  height: 1.12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Choose what you feel like doing and discover places that suit you and your friends.',
                style: TextStyle(
                  color: Color(0xFF718078),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: WelcomePage.lightGreen,
          child: Icon(
            Icons.near_me_rounded,
            color: WelcomePage.darkGreen,
            size: 21,
          ),
        ),
        SizedBox(width: 11),
        Mood2GoWordmark(),
      ],
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: WelcomePage.lightGreen,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            right: 26,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_cafe_outlined,
                color: WelcomePage.darkGreen,
                size: 23,
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            left: 26,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: WelcomePage.darkGreen,
                size: 22,
              ),
            ),
          ),

          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: WelcomePage.primaryGreen,
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(
              Icons.explore_outlined,
              color: Colors.white,
              size: 58,
            ),
          ),

          const Positioned(
            bottom: 28,
            right: 28,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: WelcomePage.primaryGreen,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}
