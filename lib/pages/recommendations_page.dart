import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_preferences.dart';
import '../services/preferences_service.dart';
import '../services/recommendation_service.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key, this.preferences});
  final UserPreferences? preferences;

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  UserPreferences? _preferences;
  final _saved = <String>{};
  bool _savedOnly = false;

  @override
  void initState() {
    super.initState();
    _preferences =
        widget.preferences ??
        PreferencesService(Supabase.instance.client).getCurrentPreferences();
  }

  void _changeMood(String mood) {
    final p = _preferences!;
    setState(
      () => _preferences = UserPreferences(
        mood: mood,
        planType: p.planType,
        venueType: p.venueType,
        budget: p.budget,
        duration: p.duration,
        groupSize: p.groupSize,
        cuisines: p.cuisines,
        dietaryNeeds: p.dietaryNeeds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _preferences;
    final results = p == null
        ? <VenueRecommendation>[]
        : RecommendationService()
              .rank(p)
              .where((r) => !_savedOnly || _saved.contains(r.venue.id))
              .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('For your mood')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'A plan that feels like you',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Fictional demo places • Free recommendations'),
                  const SizedBox(height: 20),
                  if (p != null) ...[
                    const Text('Your mood today'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final mood in [
                          'Relaxed',
                          'Energetic',
                          'Social',
                          'Curious',
                        ])
                          ChoiceChip(
                            label: Text(mood),
                            selected: p.mood == mood,
                            onSelected: (_) => _changeMood(mood),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${p.planType} · ${p.budget} budget · ${p.duration} · ${p.groupSize} people',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Changing today’s mood only affects this screen.',
                    ),
                    const SizedBox(height: 12),
                    FilterChip(
                      label: Text('Saved this visit (${_saved.length})'),
                      selected: _savedOnly,
                      onSelected: (v) => setState(() => _savedOnly = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (results.isEmpty)
                    Text(
                      p == null
                          ? 'Complete your preferences to see recommendations.'
                          : _savedOnly
                          ? 'No saved matches for this mood. Switch off the filter to explore.'
                          : 'No demo places fit all your limits. Try adjusting your preferences.',
                    ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.push('/preferences?edit=true');
                      if (!mounted) return;
                      setState(
                        () => _preferences =
                            widget.preferences ??
                            PreferencesService(Supabase.instance.client)
                                .getCurrentPreferences(),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('Edit preferences'),
                  ),
                  for (final result in results)
                    Card(
                      margin: const EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    result.venue.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                IconButton(
                                  tooltip: _saved.contains(result.venue.id)
                                      ? 'Unsave place'
                                      : 'Save place',
                                  icon: Icon(
                                    _saved.contains(result.venue.id)
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                  onPressed: () => setState(() {
                                    if (!_saved.add(result.venue.id)) {
                                      _saved.remove(result.venue.id);
                                    }
                                  }),
                                ),
                              ],
                            ),
                            Text(result.venue.area),
                            const SizedBox(height: 12),
                            Text(result.venue.description),
                            const SizedBox(height: 12),
                            Text(
                              '${result.venue.setting} · ${result.venue.budget} budget · ${result.venue.minutes} min',
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Why it fits',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (final reason in result.reasons)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('• $reason'),
                              ),
                            if (result.venue.diets.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Demo dietary options: ${result.venue.diets.join(', ')}. Allergen safety is not verified.',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
