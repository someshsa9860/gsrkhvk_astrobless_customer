import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/puja_models.dart';

class PujaRepository {
  PujaRepository(this._client);
  final ApiClient _client;

  Future<List<PujaBooking>> fetchBookings() async {
    final list = await _client.fetchPujaBookings();
    return list
        .map((e) => PujaBooking.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final pujaRepositoryProvider = Provider<PujaRepository>(
  (ref) => PujaRepository(ref.read(apiClientProvider)),
);

final pujaBookingsProvider = FutureProvider<List<PujaBooking>>((ref) {
  return ref.read(pujaRepositoryProvider).fetchBookings();
});
