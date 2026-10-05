import '../widgets/mood_surface.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_preferences.dart';
import '../services/preferences_service.dart';
import '../widgets/mood2go_wordmark.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  static const darkGreen = Color(0xFF244638);
  static const lightGreen = Color(0xFFE4F2E8);

  late final PreferencesService service;
  String mood = 'Relaxed';
  String planType = 'Both';
  String venueType = 'No preference';
  String budget = 'Medium';
  String duration = '2–3 hours';
  double groupSize = 1;
  final Set<String> cuisines = {};
  final Set<String> dietaryNeeds = {'None'};
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    service = PreferencesService(Supabase.instance.client);
    final saved = service.getCurrentPreferences();
    if (saved != null) {
      mood = saved.mood;
      planType = saved.planType;
      venueType = saved.venueType;
      budget = saved.budget;
      duration = saved.duration;
      groupSize = saved.groupSize.toDouble();
      cuisines.addAll(saved.cuisines);
      dietaryNeeds
        ..clear()
        ..addAll(saved.dietaryNeeds.isEmpty ? {'None'} : saved.dietaryNeeds);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> savePreferences() async {
    if (cuisines.isEmpty) {
      showMessage('Choose at least one cuisine.');
      return;
    }

    setState(() => isSaving = true);
    try {
      await service.save(
        UserPreferences(
          mood: mood,
          planType: planType,
          venueType: venueType,
          budget: budget,
          duration: duration,
          groupSize: groupSize.round(),
          cuisines: cuisines.toList(),
          dietaryNeeds: dietaryNeeds.toList(),
        ),
      );
      if (mounted) context.go('/home');
    } on AuthException catch (error) {
      if (mounted) showMessage(error.message);
    } catch (error) {
      if (mounted) showMessage('Could not save your preferences. Try again.');
      debugPrint('Preference save error: $error');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing =
        GoRouterState.of(context).uri.queryParameters['edit'] == 'true';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Mood2GoWordmark(fontSize: 20),
        actions: [
          if (editing)
            IconButton(
              onPressed: () => context.go('/home'),
              tooltip: 'Close',
              icon: const Icon(Icons.close_rounded, color: darkGreen),
            ),
        ],
      ),
      body: MoodSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MoodAccent(
                  icon: Icons.tune_rounded,
                  label: 'MAKE IT YOURS',
                ),
                Text(
                  editing ? 'Update your preferences' : 'Let’s get to know you',
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your answers help Mood2GO find better places and activities for you.',
                  style: TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                _ChoiceSection(
                  title: 'How are you feeling?',
                  options: const ['Relaxed', 'Energetic', 'Social', 'Curious'],
                  selected: mood,
                  onSelected: (value) => setState(() => mood = value),
                ),
                _ChoiceSection(
                  title: 'What are you looking for?',
                  options: const ['Food', 'Activity', 'Both'],
                  selected: planType,
                  onSelected: (value) => setState(() => planType = value),
                ),
                _ChoiceSection(
                  title: 'Indoor or outdoor?',
                  options: const ['Indoor', 'Outdoor', 'No preference'],
                  selected: venueType,
                  onSelected: (value) => setState(() => venueType = value),
                ),
                _ChoiceSection(
                  title: 'What is your budget?',
                  options: const ['Low', 'Medium', 'High'],
                  selected: budget,
                  onSelected: (value) => setState(() => budget = value),
                ),
                _ChoiceSection(
                  title: 'How much time do you have?',
                  options: const [
                    'Under 1 hour',
                    '1–2 hours',
                    '2–3 hours',
                    'All day',
                  ],
                  selected: duration,
                  onSelected: (value) => setState(() => duration = value),
                ),
                _SectionCard(
                  title: 'How many people?',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Group size',
                            style: TextStyle(color: Color(0xFF718078)),
                          ),
                          Text(
                            groupSize.round().toString(),
                            style: const TextStyle(
                              color: darkGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: groupSize,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: darkGreen,
                        onChanged: (value) => setState(() => groupSize = value),
                      ),
                    ],
                  ),
                ),
                _MultiChoiceSection(
                  title: 'Which cuisines do you enjoy?',
                  options: const [
                    'Turkish',
                    'Italian',
                    'Asian',
                    'Mexican',
                    'Mediterranean',
                    'Desserts',
                  ],
                  selected: cuisines,
                  onChanged: (value, selected) {
                    setState(() {
                      selected ? cuisines.add(value) : cuisines.remove(value);
                    });
                  },
                ),
                _MultiChoiceSection(
                  title: 'Any dietary needs?',
                  options: const [
                    'None',
                    'Vegetarian',
                    'Vegan',
                    'Gluten-free',
                    'Halal',
                  ],
                  selected: dietaryNeeds,
                  onChanged: (value, selected) {
                    setState(() {
                      if (value == 'None' && selected) {
                        dietaryNeeds
                          ..clear()
                          ..add('None');
                      } else {
                        dietaryNeeds.remove('None');
                        selected
                            ? dietaryNeeds.add(value)
                            : dietaryNeeds.remove(value);
                        if (dietaryNeeds.isEmpty) dietaryNeeds.add('None');
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: isSaving ? null : savePreferences,
                    style: FilledButton.styleFrom(
                      backgroundColor: darkGreen,
                      disabledBackgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            editing
                                ? 'Save changes'
                                : 'Show my recommendations',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return ChoiceChip(
            label: Text(option),
            selected: selected == option,
            onSelected: (_) => onSelected(option),
            selectedColor: _PreferencesPageState.lightGreen,
            side: const BorderSide(color: Color(0xFFDCE7DF)),
            labelStyle: const TextStyle(color: _PreferencesPageState.darkGreen),
          );
        }).toList(),
      ),
    );
  }
}

class _MultiChoiceSection extends StatelessWidget {
  const _MultiChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final void Function(String value, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (isSelected) => onChanged(option, isSelected),
            selectedColor: _PreferencesPageState.lightGreen,
            checkmarkColor: _PreferencesPageState.darkGreen,
            side: const BorderSide(color: Color(0xFFDCE7DF)),
            labelStyle: const TextStyle(color: _PreferencesPageState.darkGreen),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08244638),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE1E9E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _PreferencesPageState.darkGreen,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
