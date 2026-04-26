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

  /// Updates an existing Kundli profile and invalidates its cached report.
  Future<KundliProfile> updateProfile({
    required String id,
    required String name,
    required String dateOfBirth,
    String? timeOfBirth,
    required String placeOfBirth,
    required double lat,
    required double lng,
  }) async {
    final data = await _client.updateKundliProfile(
      id: id,
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

  /// Fetches Ashtakvarga for profile [profileId] and [planet].
  /// Returns raw data map — not cached in DB.
  Future<Map<String, dynamic>> fetchAshtakvarga(
    String profileId, {
    String planet = 'total',
  }) async {
    return _client.fetchAshtakvarga(profileId, planet: planet);
  }

  /// Fetches divisional chart planet positions — not cached in DB.
  Future<Map<String, dynamic>> fetchDivisionalChart(
    String profileId, {
    String div = 'D1',
  }) async {
    return _client.fetchDivisionalChart(profileId, div: div);
  }

  /// Fetches full Vimshottari dasha hierarchy (maha + antar) — not cached.
  Future<List<dynamic>> fetchFullDasha(String profileId) async {
    return _client.fetchFullDasha(profileId);
  }

  /// Computes Ashtakoot compatibility between two saved Kundli profiles.
  Future<KundliMatch> matchKundli({
    required String profileAId,
    required String profileBId,
  }) async {
    final data = await _client.matchKundli(
      profileAId: profileAId,
      profileBId: profileBId,
    );
    return KundliMatch.fromJson(data);
  }

  /// Lists all previous Kundli match results.
  Future<List<KundliMatch>> fetchMatches() async {
    final list = await _client.fetchKundliMatches();
    return list
        .map((e) => KundliMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches specific sub-dasha levels (paryantar/sookshma/prana) — not cached.
  Future<Map<String, dynamic>> fetchSpecificSubDasha(
    String profileId, {
    required String md,
    required String ad,
    required String pd,
    required String sd,
  }) async {
    return _client.fetchSpecificSubDasha(
      profileId,
      md: md,
      ad: ad,
      pd: pd,
      sd: sd,
    );
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

/// (profileId, planet) — planet defaults to 'total'
final kundliAshtakvargaProvider =
    FutureProvider.family<Map<String, dynamic>, (String, String)>((ref, args) {
  final (profileId, planet) = args;
  return ref.read(kundliRepositoryProvider).fetchAshtakvarga(profileId, planet: planet);
});

/// (profileId, div) — div defaults to 'D1'
final kundliDivisionalChartProvider =
    FutureProvider.family<Map<String, dynamic>, (String, String)>((ref, args) {
  final (profileId, div) = args;
  return ref.read(kundliRepositoryProvider).fetchDivisionalChart(profileId, div: div);
});

/// Full dasha hierarchy for a profile (maha + antar). Not cached.
final kundliFullDashaProvider =
    FutureProvider.family<List<dynamic>, String>((ref, profileId) {
  return ref.read(kundliRepositoryProvider).fetchFullDasha(profileId);
});

final kundliMatchesProvider = FutureProvider<List<KundliMatch>>((ref) {
  return ref.read(kundliRepositoryProvider).fetchMatches();
});

/// Specific sub-dasha levels. Args: (profileId, md, ad, pd, sd).
final kundliSpecificSubDashaProvider =
    FutureProvider.family<Map<String, dynamic>, (String, String, String, String, String)>(
        (ref, args) {
  final (profileId, md, ad, pd, sd) = args;
  return ref
      .read(kundliRepositoryProvider)
      .fetchSpecificSubDasha(profileId, md: md, ad: ad, pd: pd, sd: sd);
});
