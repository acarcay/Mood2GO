import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mood2go/models/discovered_place.dart';
import 'package:mood2go/pages/discovery_page.dart';
import 'package:mood2go/services/place_discovery_service.dart';

class FakeDiscoveryService extends PlaceDiscoveryService {
  FakeDiscoveryService()
    : super(
        SupabaseClient(
          'https://example.supabase.co',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  int calls = 0;
  bool fail = false;
  int? requestedPageSize;
  bool fullResults = false;
  String? requestedType;
  bool requestedOpen = false;

  @override
  Future<PlaceDiscoveryResult> search({
    required String query,
    double? latitude,
    double? longitude,
    double radiusMeters = 5000,
    String? placeType,
    int pageSize = 10,
    String? pageToken,
    bool openNow = false,
  }) async {
    calls++;
    requestedPageSize = pageSize;
    requestedType = placeType;
    requestedOpen = openNow;
    if (fail) {
      throw const PlaceDiscoveryException(
        'We couldn’t load places. Please try again.',
      );
    }
    return PlaceDiscoveryResult(
      places: fullResults
          ? List.generate(
              15,
              (i) => DiscoveredPlace(
                googlePlaceId: 'place-$i',
                name: 'Place $i',
                address: 'Izmir',
                primaryType: 'cafe',
                rating: null,
                ratingCount: null,
                priceLevel: null,
                openNow: null,
                googleMapsUri: null,
                signals: const {},
              ),
            )
          : [],
      nextPageToken: null,
      sourceName: 'Google Maps',
    );
  }
}

void main() {
  test(
    'live service fixes limit at ten and never follows pagination',
    () async {
      final client = SupabaseClient(
        'https://example.invalid',
        'test',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(client.dispose);
      Map<String, dynamic>? sent;
      var calls = 0;
      final service = PlaceDiscoveryService(
        client,
        invoke: (body) async {
          calls++;
          sent = body;
          return FunctionResponse(
            status: 200,
            data: {
              'places': List.generate(
                15,
                (i) => {'googlePlaceId': '$i', 'name': 'Place $i'},
              ),
              'nextPageToken': 'ignored',
              'source': {'provider': 'Google Maps'},
              'quota': {'remaining': 898, 'limit': 900},
              'ranking': {'message': 'Jev is not connected yet.'},
            },
          );
        },
      );
      final result = await service.search(query: 'İzmir', pageSize: 100);
      expect(sent?['pageSize'], 10);
      expect(sent?['query'], 'İzmir');
      expect(result.places.length, 10);
      expect(result.nextPageToken, isNull);
      expect(result.remainingRequests, 898);
      await expectLater(
        service.search(query: 'İzmir', pageToken: 'next'),
        throwsA(isA<PlaceDiscoveryException>()),
      );
      expect(calls, 1);
    },
  );

  test('server quota error is preserved for the user', () async {
    final client = SupabaseClient(
      'https://example.invalid',
      'test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(client.dispose);
    final service = PlaceDiscoveryService(
      client,
      invoke: (_) async => throw FunctionException(
        status: 429,
        details: {'error': 'Monthly search limit reached.'},
      ),
    );
    await expectLater(
      service.search(query: 'İzmir'),
      throwsA(
        isA<PlaceDiscoveryException>().having(
          (e) => e.message,
          'message',
          'Monthly search limit reached.',
        ),
      ),
    );
  });

  testWidgets('screen shows at most ten and has no load-more action', (
    tester,
  ) async {
    final service = FakeDiscoveryService()..fullResults = true;
    await tester.pumpWidget(MaterialApp(home: DiscoveryPage(service: service)));
    await tester.enterText(find.byType(TextField), 'İzmir');
    await tester.tap(find.text('Find places'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(10));
    expect(find.text('Load more places'), findsNothing);
    expect(service.requestedPageSize, 10);
  });

  testWidgets(
    'validates search and forwards filters, then shows empty results',
    (tester) async {
      final service = FakeDiscoveryService();
      await tester.pumpWidget(
        MaterialApp(home: DiscoveryPage(service: service)),
      );
      await tester.tap(find.text('Find places'));
      await tester.pumpAndSettle();
      expect(service.calls, 0);
      expect(
        find.text('Enter a search between 2 and 160 characters.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'Cafes in Istanbul');
      await tester.tap(find.text('Cafes'));
      await tester.tap(find.text('Open now'));
      await tester.tap(find.text('Find places'));
      await tester.pumpAndSettle();
      expect(service.requestedType, 'cafe');
      expect(service.requestedOpen, isTrue);
      expect(
        find.text('No places found. Try another area or change your filters.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('failed search can be retried successfully', (tester) async {
    final service = FakeDiscoveryService()..fail = true;
    await tester.pumpWidget(MaterialApp(home: DiscoveryPage(service: service)));
    await tester.enterText(find.byType(TextField), 'Istanbul');
    await tester.tap(find.text('Find places'));
    await tester.pumpAndSettle();
    expect(
      find.text('We couldn’t load places. Please try again.'),
      findsOneWidget,
    );
    service.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(service.calls, 2);
    expect(
      find.text('We couldn’t load places. Please try again.'),
      findsNothing,
    );
  });
}
