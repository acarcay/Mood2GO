class DiscoveredPlace {
  const DiscoveredPlace({
    required this.googlePlaceId,
    required this.name,
    required this.address,
    required this.primaryType,
    required this.rating,
    required this.ratingCount,
    required this.priceLevel,
    required this.openNow,
    required this.googleMapsUri,
    required this.signals,
    this.recommendation = const {},
  });

  final String googlePlaceId;
  final String name;
  final String address;
  final String? primaryType;
  final double? rating;
  final int? ratingCount;
  final String? priceLevel;
  final bool? openNow;
  final String? googleMapsUri;
  final Map<String, dynamic> signals;
  final Map<String, dynamic> recommendation;

  factory DiscoveredPlace.fromJson(Map<String, dynamic> json) {
    return DiscoveredPlace(
      googlePlaceId: json['googlePlaceId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed place',
      address: json['address'] as String? ?? 'Address unavailable',
      primaryType: json['primaryType'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      priceLevel: json['priceLevel'] as String?,
      openNow: json['openNow'] as bool?,
      googleMapsUri: json['googleMapsUri'] as String?,
      signals: Map<String, dynamic>.from(json['signals'] as Map? ?? const {}),
      recommendation: Map<String, dynamic>.from(
        json['recommendation'] as Map? ?? const {},
      ),
    );
  }
}

class PlaceDiscoveryResult {
  const PlaceDiscoveryResult({
    required this.places,
    required this.nextPageToken,
    required this.sourceName,
    this.rankingMessage,
    this.remainingRequests,
    this.requestLimit,
  });

  final List<DiscoveredPlace> places;
  final String? nextPageToken;
  final String sourceName;
  final String? rankingMessage;
  final int? remainingRequests;
  final int? requestLimit;

  factory PlaceDiscoveryResult.fromJson(Map<String, dynamic> json) {
    final source = Map<String, dynamic>.from(
      json['source'] as Map? ?? const {},
    );
    final rawPlaces = json['places'] as List? ?? const [];
    return PlaceDiscoveryResult(
      places: rawPlaces
          .whereType<Map>()
          .map(
            (place) =>
                DiscoveredPlace.fromJson(Map<String, dynamic>.from(place)),
          )
          .take(10)
          .toList(),
      nextPageToken: null,
      sourceName: source['provider'] as String? ?? 'Google Maps',
      rankingMessage: (json['ranking'] as Map?)?['message'] as String?,
      remainingRequests: ((json['quota'] as Map?)?['remaining'] as num?)
          ?.toInt(),
      requestLimit: ((json['quota'] as Map?)?['limit'] as num?)?.toInt(),
    );
  }
}
