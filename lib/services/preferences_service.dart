import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_preferences.dart';

class PreferencesService {
  PreferencesService(this._client);

  final SupabaseClient _client;

  UserPreferences? getCurrentPreferences() {
    final data = _client.auth.currentUser?.userMetadata?['preferences'];
    if (data is! Map) return null;
    return UserPreferences.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> save(UserPreferences preferences) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('You must be signed in.');
    }

    final currentMetadata = Map<String, dynamic>.from(
      currentUser.userMetadata ?? const {},
    );

    await _client.auth.updateUser(
      UserAttributes(
        data: {
          ...currentMetadata,
          'preferences': preferences.toJson(),
          'preferences_completed': true,
        },
      ),
    );
  }
}
