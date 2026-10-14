import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mood2go/main.dart';
import 'package:mood2go/models/user_preferences.dart';
import 'package:mood2go/pages/login_page.dart';
import 'package:mood2go/pages/register_page.dart';
import 'package:mood2go/pages/home_page.dart';
import 'package:mood2go/pages/preferences_page.dart';
import 'package:mood2go/pages/discovery_page.dart';
import 'package:mood2go/pages/recommendations_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (call) async => call.method == 'getAll' ? <String, Object>{} : true,
        );
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'layout-test-key',
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());

  final pages = <String, Widget>{
    'welcome': const WelcomePage(),
    'login': const LoginPage(),
    'register': const RegisterPage(),
    'home': const HomePage(),
    'discovery': const DiscoveryPage(),
    'recommendations': const RecommendationsPage(
      preferences: UserPreferences(
        mood: 'Relaxed',
        planType: 'Both',
        venueType: 'Outdoor',
        budget: 'High',
        duration: 'All day',
        groupSize: 2,
        cuisines: ['Turkish'],
        dietaryNeeds: ['None'],
      ),
    ),
    'preferences': const PreferencesPage(),
  };
  for (final size in [const Size(320, 568), const Size(1440, 900)]) {
    for (final page in pages.entries) {
      testWidgets('${page.key} fits ${size.width} wide with enlarged text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final router = GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => page.value)],
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        router.dispose();
      });
    }
  }
}
