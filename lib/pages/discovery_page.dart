import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/discovered_place.dart';
import '../services/place_discovery_service.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key, this.service});

  final PlaceDiscoveryService? service;

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final _query = TextEditingController();
  late final PlaceDiscoveryService _service;
  List<DiscoveredPlace> _places = [];
  String? _rankingMessage;
  int? _remainingRequests;
  int? _requestLimit;
  String? _error;
  String _source = 'Google Maps';
  bool _busy = false;
  bool _searched = false;
  bool _openNow = false;
  String? _type;

  @override
  void initState() {
    super.initState();
    _service =
        widget.service ?? PlaceDiscoveryService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_busy) return;
    final query = _query.text.trim();
    if (query.length < 2 || query.length > 160) {
      setState(() => _error = 'Enter a search between 2 and 160 characters.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _places = [];
      _rankingMessage = null;
      _searched = false;
    });
    try {
      final result = await _service.search(
        query: query,
        placeType: _type,
        openNow: _openNow,
        pageSize: 10,
      );
      if (!mounted) return;
      setState(() {
        final combined = result.places.take(10);
        final ids = <String>{};
        _places = combined
            .where((place) => ids.add(place.googlePlaceId))
            .toList();
        _rankingMessage = result.rankingMessage;
        _remainingRequests = result.remainingRequests;
        _requestLimit = result.requestLimit;
        _source = result.sourceName;

        _searched = true;
      });
    } on PlaceDiscoveryException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'We couldn’t load places. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _resetFilters(VoidCallback change) {
    setState(() {
      change();
      _places = [];
      _rankingMessage = null;
      _searched = false;
      _error = null;
    });
  }

  void _details(DiscoveredPlace place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(place.address),
              const SizedBox(height: 16),
              Text(_summary(place)),
              if (place.recommendation['provider'] == 'Jev') ...[
                const SizedBox(height: 16),
                Text(
                  'Jev evaluates available facts. Evidence coverage: ${place.recommendation['coverage']}% of ranking criteria.',
                ),
                for (final reason
                    in (place.recommendation['reasons'] as List? ?? []))
                  Text('• $reason'),
                const SizedBox(height: 8),
                const Text(
                  'Mood fit is an estimate. Duration, capacity and allergen safety are not verified.',
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in const {
                    'outdoorSeating': 'Outdoor seating',
                    'goodForGroups': 'Good for groups',
                    'servesVegetarianFood': 'Vegetarian options',
                    'reservable': 'Reservations available',
                  }.entries)
                    if (place.signals[entry.key] == true)
                      Chip(label: Text(entry.value)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Menu and allergen information are not available yet. Ask the venue for details.',
              ),
              if (place.googleMapsUri != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: place.googleMapsUri!),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Maps link copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy Google Maps link'),
                ),
              ],
              const SizedBox(height: 16),
              Text('Source: $_source'),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(DiscoveredPlace place) {
    final price = const {
      'PRICE_LEVEL_FREE': 'Free',
      'PRICE_LEVEL_INEXPENSIVE': '₺',
      'PRICE_LEVEL_MODERATE': '₺₺',
      'PRICE_LEVEL_EXPENSIVE': '₺₺₺',
      'PRICE_LEVEL_VERY_EXPENSIVE': '₺₺₺₺',
    }[place.priceLevel];
    return [
      if (place.primaryType != null) place.primaryType!.replaceAll('_', ' '),
      if (place.rating != null)
        '★ ${place.rating} (${place.ratingCount ?? 0} reviews)',
      ?price,
      if (place.openNow != null) place.openNow! ? 'Open now' : 'Closed now',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover places')),
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
                    'Where will your mood take you?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Search a city or neighborhood. Each search returns up to 10 real places.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _query,
                    enabled: !_busy,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Place or activity',
                      hintText: 'Cafes in Kadikoy, Istanbul',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in const <String?, String>{
                        null: 'All',
                        'restaurant': 'Restaurants',
                        'cafe': 'Cafes',
                        'park': 'Parks',
                        'museum': 'Museums',
                      }.entries)
                        ChoiceChip(
                          label: Text(entry.value),
                          selected: _type == entry.key,
                          onSelected: _busy
                              ? null
                              : (_) => _resetFilters(() => _type = entry.key),
                        ),
                      FilterChip(
                        label: const Text('Open now'),
                        selected: _openNow,
                        onSelected: _busy
                            ? null
                            : (value) => _resetFilters(() => _openNow = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _search(),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Find places'),
                  ),
                  const SizedBox(height: 24),
                  if (_busy) const Center(child: CircularProgressIndicator()),
                  if (_error != null) ...[
                    Text(_error!),
                    TextButton(
                      onPressed: _busy ? null : () => _search(),
                      child: const Text('Try again'),
                    ),
                  ],
                  if (_searched && _places.isEmpty)
                    const Text(
                      'No places found. Try another area or change your filters.',
                    ),
                  if (_remainingRequests != null) ...[
                    Text(
                      '$_remainingRequests / $_requestLimit approved searches remaining this month.',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_rankingMessage != null) ...[
                    Text(_rankingMessage!),
                    const SizedBox(height: 12),
                  ],
                  for (final place in _places)
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(place.name),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${place.address}\n${_summary(place)}'),
                              if (place.recommendation['provider'] ==
                                  'Jev') ...[
                                const SizedBox(height: 8),
                                Text(
                                  place.recommendation['score'] == null
                                      ? 'Jev: insufficient evidence to score'
                                      : 'Jev preference score: ${place.recommendation['score']}/100',
                                ),
                                for (final reason
                                    in (place.recommendation['reasons']
                                            as List? ??
                                        []))
                                  Text('• $reason'),
                              ],
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _details(place),
                      ),
                    ),
                  if (_places.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Source: $_source', textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
