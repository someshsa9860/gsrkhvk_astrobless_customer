import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/kundli_models.dart';

/// Repository for Kundli (Vedic birth chart) profiles and reports.
///
/// All requests require a valid JWT and go through [ApiClient].
/// Path strings live in [Endpoints.kundli].
class KundliRepository {
  KundliRepository(this._client);
  final ApiClient _client;

  /// Lists all saved Kundli profiles for the current customer.
  Future<List<KundliProfile>> fetchProfiles() async {
    final list = await _client.fetchKundliProfiles();
    return list.map((e) => KundliProfile.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Creates a new Kundli profile from birth details.
  Future<KundliProfile> createProfile({
    required String name,
    required String dateOfBirth,
    String? timeOfBirth,
    required String placeOfBirth,
    required double lat,
    required double lng,
  }) async {
    final data = await _client.createKundliProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      timeOfBirth: timeOfBirth,
      placeOfBirth: placeOfBirth,
      lat: lat,
      lng: lng,
    );
    return KundliProfile.fromJson(data);
  }

  /// Deletes a Kundli profile by [id].
  Future<void> deleteProfile(String id) async {
    await _client.deleteKundliProfile(id);
  }

  /// Fetches (or generates) the full Kundli report for profile [profileId].
  Future<KundliReport> fetchReport(String profileId) async {
    final data = await _client.fetchKundliReport(profileId);
    return KundliReport.fromJson(data);
  }
}

final kundliRepositoryProvider = Provider<KundliRepository>((ref) {
  return KundliRepository(ref.read(apiClientProvider));
});

final kundliProfilesProvider = FutureProvider<List<KundliProfile>>((ref) {
  return ref.read(kundliRepositoryProvider).fetchProfiles();
});

final kundliReportProvider =
    FutureProvider.family<KundliReport, String>((ref, profileId) {
  return ref.read(kundliRepositoryProvider).fetchReport(profileId);
});
