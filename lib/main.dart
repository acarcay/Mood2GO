import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/preferences_page.dart';
import 'services/auth_notifier.dart';
import 'widgets/mood2go_wordmark.dart';
import 'widgets/mood_surface.dart';

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
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFFAFCFA),
          toolbarHeight: 72,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 56),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF8FAF7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF244638),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MoodSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      color: Color(0xFF244638),
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Mood2GoWordmark(fontSize: 24),
                  ],
                ),
                const SizedBox(height: 32),
                const _WelcomeVisual(),
                const SizedBox(height: 32),
                const Text(
                  'GOOD PLANS. YOUR WAY.',
                  style: TextStyle(
                    color: Color(0xFF557360),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'A little adventure.\nA lot more you.',
                  style: TextStyle(
                    color: Color(0xFF244638),
                    fontSize: 38,
                    height: 1.12,
                    letterSpacing: -1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Find places and experiences that fit your mood. Make a day of it, together.',
                  style: TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF244638),
                    ),
                    onPressed: () => context.go('/register'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text('Get started')),
                        SizedBox(width: 14),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Already a member? Sign in',
                      style: TextStyle(color: Color(0xFF244638)),
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

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFFDDEFE2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(right: -50, top: -65, child: _ring(220)),
              Positioned(left: -75, bottom: -100, child: _ring(260)),
              Transform.rotate(
                angle: -0.10,
                child: Container(
                  width: 146,
                  height: 166,
                  decoration: BoxDecoration(
                    color: const Color(0xFF244638),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26244638),
                        blurRadius: 25,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 66,
                        color: Color(0xFFC6E6CE),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Find your happy.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 27,
                left: 18,
                child: _VisualLabel(Icons.local_cafe_outlined, 'Slow mornings'),
              ),
              const Positioned(
                bottom: 25,
                right: 16,
                child: _VisualLabel(Icons.wb_sunny_outlined, 'New memories'),
              ),
              const Positioned(
                top: 40,
                right: 25,
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF6B9B76),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFCAE3D0), width: 28),
    ),
  );
}

class _VisualLabel extends StatelessWidget {
  const _VisualLabel(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFDFEFC),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10244638),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF557360), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF244638),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
