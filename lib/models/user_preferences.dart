class UserPreferences {
  const UserPreferences({
    required this.mood,
    required this.planType,
    required this.venueType,
    required this.budget,
    required this.duration,
    required this.groupSize,
    required this.cuisines,
    required this.dietaryNeeds,
  });

  final String mood;
  final String planType;
  final String venueType;
  final String budget;
  final String duration;
  final int groupSize;
  final List<String> cuisines;
  final List<String> dietaryNeeds;

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'plan_type': planType,
      'venue_type': venueType,
      'budget': budget,
      'duration': duration,
      'group_size': groupSize,
      'cuisines': cuisines,
      'dietary_needs': dietaryNeeds,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      mood: json['mood'] as String? ?? 'Relaxed',
      planType: json['plan_type'] as String? ?? 'Both',
      venueType: json['venue_type'] as String? ?? 'No preference',
      budget: json['budget'] as String? ?? 'Medium',
      duration: json['duration'] as String? ?? '2–3 hours',
      groupSize: json['group_size'] as int? ?? 1,
      cuisines: List<String>.from(json['cuisines'] as List? ?? const []),
      dietaryNeeds: List<String>.from(
        json['dietary_needs'] as List? ?? const [],
      ),
    );
  }
}
