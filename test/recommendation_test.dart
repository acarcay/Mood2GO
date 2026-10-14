import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood2go/models/user_preferences.dart';
import 'package:mood2go/services/recommendation_service.dart';
import 'package:mood2go/pages/recommendations_page.dart';

UserPreferences preferences({
  String mood = 'Relaxed',
  String plan = 'Both',
  String budget = 'High',
  String duration = 'All day',
  int group = 1,
  List<String> diets = const [],
}) => UserPreferences(
  mood: mood,
  planType: plan,
  venueType: 'No preference',
  budget: budget,
  duration: duration,
  groupSize: group,
  cuisines: const [],
  dietaryNeeds: diets,
);

void main() {
  test('mood changes top recommendation and explains it', () {
    final service = RecommendationService();
    final curious = service.rank(
      preferences(mood: 'Curious', plan: 'Activity'),
    );
    final energetic = service.rank(
      preferences(mood: 'Energetic', plan: 'Activity'),
    );
    expect(curious.first.venue.type, 'museum');
    expect(energetic.first.venue.type, 'park');
    expect(curious.first.reasons, contains('Fits your curious mood'));
  });

  test('budget, duration, capacity and diet remain hard limits', () {
    final service = RecommendationService();
    final cheap = service.rank(
      preferences(budget: 'Low', duration: 'Under 1 hour'),
    );
    expect(cheap.map((r) => r.venue.id), ['sample-cafe']);
    final group = service.rank(preferences(group: 10));
    expect(group.every((r) => r.venue.capacity >= 10), isTrue);
    final vegan = service.rank(preferences(plan: 'Food', diets: ['Vegan']));
    expect(vegan.map((r) => r.venue.id), ['sample-restaurant']);
    expect(
      service.rank(preferences(plan: 'Food', diets: ['Gluten-free'])),
      isEmpty,
    );
  });

  testWidgets('saves and unsaves venue within a visit', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationsPage(
          preferences: preferences(mood: 'Curious', plan: 'Activity'),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Save place').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved this visit (1)'));
    await tester.pumpAndSettle();
    expect(find.text('City Stories Museum'), findsOneWidget);
    expect(find.text('Quiet Grove Park'), findsNothing);
    await tester.tap(find.byTooltip('Unsave place'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No saved matches for this mood. Switch off the filter to explore.',
      ),
      findsOneWidget,
    );
  });
}
