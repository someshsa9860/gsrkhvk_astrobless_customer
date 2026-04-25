import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/consultation_models.dart';

class ConsultationsRepository {
  ConsultationsRepository(this._client);
  final ApiClient _client;

  Future<List<Consultation>> fetchHistory({int page = 1, int limit = 20}) async {
    final data = await _client.fetchConsultations(page: page, limit: limit);
    final items = data['items'] as List<dynamic>? ?? data['consultations'] as List<dynamic>? ?? [];
    return items
        .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final consultationsRepositoryProvider = Provider<ConsultationsRepository>((ref) {
  return ConsultationsRepository(ref.read(apiClientProvider));
});

final consultationHistoryProvider = FutureProvider<List<Consultation>>((ref) {
  return ref.read(consultationsRepositoryProvider).fetchHistory();
});

/// Fetches consultations filtered to a specific [type] ('chat' or 'voice').
final consultationsByTypeProvider =
    FutureProvider.family<List<Consultation>, String>((ref, type) async {
  final data = await ref.read(apiClientProvider).fetchConsultations(
        type: type,
        limit: 30,
      );
  final items = data['items'] as List<dynamic>? ??
      data['consultations'] as List<dynamic>? ?? [];
  return items
      .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
      .toList();
});
