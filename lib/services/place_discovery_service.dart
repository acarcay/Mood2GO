import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/discovered_place.dart';

typedef DiscoveryInvoker = Future<FunctionResponse> Function(
  Map<String, dynamic> body,
);

class PlaceDiscoveryService {
  PlaceDiscoveryService(this._client, {this.invoke});

  static const maxResults = 10;
  final SupabaseClient _client;
  final DiscoveryInvoker? invoke;

  Future<PlaceDiscoveryResult> search({
    required String query,
    double? latitude,
    double? longitude,
    double radiusMeters = 5000,
    String? placeType,
    int pageSize = maxResults,
    String? pageToken,
    bool openNow = false,
  }) async {
    if (pageToken != null) {
      throw const PlaceDiscoveryException(
        'Each search is limited to 10 places.',
      );
    }
    final body = <String, dynamic>{
      'query': query.trim(),
      'pageSize': maxResults,
      'openNow': openNow,
      'placeType': ?placeType,
    };
    try {
      final response = await (invoke != null
          ? invoke!(body)
          : _client.functions.invoke('discover-places', body: body));
      if (response.status < 200 || response.status >= 300) {
        throw _error(response.data);
      }
      if (response.data is! Map) {
        throw const PlaceDiscoveryException('Unexpected search response.');
      }
      return PlaceDiscoveryResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on FunctionException catch (error) {
      throw _error(error.details);
    }
  }

  PlaceDiscoveryException _error(dynamic data) {
    final message = data is Map ? data['error'] : null;
    return PlaceDiscoveryException(
      message is String ? message : 'Live search is unavailable. The discover-places function must be deployed and configured.',
    );
  }
}

class PlaceDiscoveryException implements Exception {
  const PlaceDiscoveryException(this.message);
  final String message;

  @override
  String toString() => message;
}
