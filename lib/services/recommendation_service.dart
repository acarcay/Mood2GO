import '../data/demo_venues.dart';
import '../models/user_preferences.dart';

class VenueRecommendation {
  const VenueRecommendation(this.venue, this.score, this.reasons);
  final DemoVenue venue;
  final int score;
  final List<String> reasons;
}

class RecommendationService {
  List<VenueRecommendation> rank(UserPreferences preferences) {
    final results = <VenueRecommendation>[];
    const budgets = {'Low': 0, 'Medium': 1, 'High': 2};
    final timeLimit =
        const {
          'Under 1 hour': 59,
          '1–2 hours': 120,
          '2–3 hours': 180,
          'All day': 1440,
        }[preferences.duration] ??
        180;
    for (final venue in demoVenues) {
      final food = venue.type == 'restaurant' || venue.type == 'cafe';
      if (preferences.planType == 'Food' && !food) continue;
      if (preferences.planType == 'Activity' && food) continue;
      if (venue.capacity < preferences.groupSize) continue;
      if (venue.minutes > timeLimit) continue;
      if (budgets[venue.budget]! > (budgets[preferences.budget] ?? 1)) continue;
      if (food &&
          preferences.dietaryNeeds
              .where((diet) => diet != 'None')
              .any((diet) => !venue.diets.contains(diet))) {
        continue;
      }
      var score = 0;
      final reasons = <String>[];
      if (venue.moods.contains(preferences.mood)) {
        score += 40;
        reasons.add('Fits your ${preferences.mood.toLowerCase()} mood');
      }
      if (preferences.venueType != 'No preference' &&
          venue.setting == preferences.venueType) {
        score += 25;
        reasons.add('${venue.setting} setting');
      }
      if (venue.cuisines.any(preferences.cuisines.contains)) {
        score += 20;
        reasons.add('Cuisine you enjoy');
      }
      score += 15;
      reasons.add('Within your budget and available time');
      if (preferences.groupSize > 1) {
        reasons.add('Space for ${preferences.groupSize} people');
      }
      results.add(VenueRecommendation(venue, score, reasons));
    }
    results.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      return scoreOrder != 0 ? scoreOrder : a.venue.id.compareTo(b.venue.id);
    });
    return results;
  }
}
