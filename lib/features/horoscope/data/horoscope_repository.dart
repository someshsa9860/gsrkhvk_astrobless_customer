import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/horoscope_models.dart';

class HoroscopeRepository {
  HoroscopeRepository(this._client);
  final ApiClient _client;

  Future<HoroscopeData?> fetchDaily(String sign) async {
    final data = await _client.fetchDailyHoroscope(sign);
    return data != null ? HoroscopeData.fromJson(data) : null;
  }

  Future<HoroscopeData?> fetchWeekly(String sign) async {
    final data = await _client.fetchWeeklyHoroscope(sign);
    return data != null ? HoroscopeData.fromJson(data) : null;
  }

  Future<HoroscopeData?> fetchMonthly(String sign) async {
    final data = await _client.fetchMonthlyHoroscope(sign);
    return data != null ? HoroscopeData.fromJson(data) : null;
  }

  Future<HoroscopeData?> fetchYearly(String sign) async {
    final data = await _client.fetchYearlyHoroscope(sign);
    return data != null ? HoroscopeData.fromJson(data) : null;
  }
}

final horoscopeRepositoryProvider = Provider<HoroscopeRepository>((ref) {
  return HoroscopeRepository(ref.read(apiClientProvider));
});

// sign = 'aries' | 'taurus' | ...
// period = 'daily' | 'weekly' | 'yearly'
final horoscopeProvider =
    FutureProvider.family<HoroscopeData?, (String sign, String period)>((ref, args) {
  final repo = ref.read(horoscopeRepositoryProvider);
  final (sign, period) = args;
  return switch (period) {
    'weekly' => repo.fetchWeekly(sign),
    'yearly' => repo.fetchYearly(sign),
    _ => repo.fetchDaily(sign),
  };
});
