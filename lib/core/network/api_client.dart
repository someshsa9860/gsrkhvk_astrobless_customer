import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';
import 'endpoints.dart';

/// Riverpod provider for the singleton [ApiClient].
///
/// Internally wires the authenticated and public [Dio] instances created by
/// [dioProvider] and [publicDioProvider] respectively.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    authenticatedDio: ref.read(dioProvider),
    publicDio: ref.read(publicDioProvider),
  );
});

/// Central HTTP gateway for all Customer API interactions.
///
/// - **Authenticated** requests (requires JWT) use the internal `_dio`
///   instance, which carries the `Authorization` header and handles
///   transparent token refresh via [_AuthInterceptor].
///
/// - **Public** requests (no JWT needed) use `_publicDio` and are exposed
///   through the [publicGet] method.
///
/// Obtain an instance via `ref.read(apiClientProvider)`. Do not instantiate
/// directly in feature code — use the Riverpod provider.
///
/// All path strings come from [Endpoints] — never hard-code paths here.
class ApiClient {
  ApiClient({required Dio authenticatedDio, required Dio publicDio})
      : _dio = authenticatedDio,
        _publicDio = publicDio;

  final Dio _dio;
  final Dio _publicDio;

  // ─── Core HTTP helpers ────────────────────────────────────────────────────

  /// Authenticated `GET` request. Throws [DioException] on HTTP error.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<dynamic>(path, queryParameters: queryParameters);

  /// Authenticated `POST` request.
  Future<Response<dynamic>> post(String path, {dynamic data}) =>
      _dio.post<dynamic>(path, data: data);

  /// Authenticated `PATCH` request.
  Future<Response<dynamic>> patch(String path, {dynamic data}) =>
      _dio.patch<dynamic>(path, data: data);

  /// Authenticated `DELETE` request.
  Future<Response<dynamic>> delete(String path, {dynamic data}) =>
      _dio.delete<dynamic>(path, data: data);

  /// Unauthenticated `GET` request against the public API base URL.
  Future<Response<dynamic>> publicGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _publicDio.get<dynamic>(path, queryParameters: queryParameters);

  /// Authenticated streaming `POST` (Server-Sent Events / chunked transfer).
  ///
  /// Pass custom [options] (e.g. `ResponseType.stream`) as needed.
  Future<Response<dynamic>> stream(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.post<dynamic>(path, data: data, options: options);

  // ─── Convenience path accessors ──────────────────────────────────────────
  //
  // These methods pair each [Endpoints] constant with its HTTP verb and
  // expected payload, keeping feature repositories thin and free of
  // both raw Dio imports and hard-coded path strings.
  //
  // New endpoints: add a method here and a matching constant in [Endpoints].

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Sends a phone OTP (MSG91 SMS). Rate-limited 5/hr per phone.
  Future<void> sendPhoneOtp(String phone) async {
    await post(Endpoints.auth.sendPhoneOtp, data: {'phone': phone});
  }

  /// Verifies the phone OTP and returns a [LoginResult] with tokens.
  Future<Map<String, dynamic>> verifyPhoneOtp(String phone, String otp) async {
    final res = await post(
      Endpoints.auth.verifyPhoneOtp,
      data: {'phone': phone, 'otp': otp},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Begins email sign-up; the backend sends an email OTP.
  Future<void> emailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    await post(Endpoints.auth.emailSignup, data: {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  /// Verifies the email OTP sent during sign-up and returns a [LoginResult].
  Future<Map<String, dynamic>> verifyEmailOtp(
      String email, String otp) async {
    final res = await post(
      Endpoints.auth.verifyEmailOtp,
      data: {'email': email, 'otp': otp},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Authenticates with email + password after email verification.
  Future<Map<String, dynamic>> emailLogin(
      String email, String password) async {
    final res = await post(
      Endpoints.auth.emailLogin,
      data: {'email': email, 'password': password},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Authenticates via Google ID token.
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final res =
        await post(Endpoints.auth.googleLogin, data: {'idToken': idToken});
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Authenticates via Apple identity token.
  Future<Map<String, dynamic>> appleLogin({
    required String identityToken,
    required String nonce,
    String? name,
  }) async {
    final res = await post(Endpoints.auth.appleLogin, data: {
      'identityToken': identityToken,
      'nonce': nonce,
      if (name != null && name.isNotEmpty) 'name': name,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Sends an email OTP for login (separate from signup verify-otp flow).
  Future<void> sendEmailLoginOtp(String email) async {
    await post(Endpoints.auth.sendEmailLoginOtp, data: {'email': email});
  }

  /// Sends a password reset link to [email].
  Future<void> forgotPassword(String email) async {
    await post(Endpoints.auth.forgotPassword, data: {'email': email});
  }

  /// Revokes the current session (best-effort — fire and forget).
  Future<void> logout(String refreshToken) async {
    await delete(Endpoints.auth.logout, data: {'refreshToken': refreshToken});
  }

  // ─── Wallet ────────────────────────────────────────────────────────────────

  /// Fetches the current wallet balance.
  Future<Map<String, dynamic>> fetchWallet() async {
    final res = await get(Endpoints.wallet.balance);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches the wallet transaction ledger.
  Future<List<dynamic>> fetchWalletTransactions() async {
    final res = await get(Endpoints.wallet.transactions);
    final data = res.data['data'];
    // API returns { items: [...], total: N } — extract items
    if (data is Map) return (data['items'] as List<dynamic>?) ?? [];
    return data as List<dynamic>? ?? [];
  }

  /// Initiates a wallet top-up and returns the provider client payload.
  Future<Map<String, dynamic>> initiateTopup({
    required double amount,
    required String providerKey,
    required String idempotencyKey,
  }) async {
    final res = await post(Endpoints.wallet.topup, data: {
      'amount': amount,
      'providerKey': providerKey,
      'idempotencyKey': idempotencyKey,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─── Astrologers ───────────────────────────────────────────────────────────

  /// Fetches a paginated list of astrologers with optional filters.
  Future<Map<String, dynamic>> fetchAstrologers({
    String? search,
    String? specialty,
    String? language,
    bool? isOnline,
    double? minRating,
    double? maxPrice,
    String sort = 'rating',
    String order = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    final res = await get(Endpoints.astrologers.list, queryParameters: {
      if (search != null && search.isNotEmpty) 'q': search,
      if (specialty != null) 'specialty': specialty,
      if (language != null) 'language': language,
      if (isOnline != null) 'isOnline': isOnline,
      if (minRating != null) 'minRating': minRating,
      if (maxPrice != null) 'maxPrice': maxPrice,
      'sort': sort,
      'order': order,
      'page': page,
      'limit': limit,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches a single astrologer's full profile.
  Future<Map<String, dynamic>> fetchAstrologer(String id) async {
    final res = await get(Endpoints.astrologers.detail(id));
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─── Kundli ────────────────────────────────────────────────────────────────

  /// Lists all Kundli profiles for the current customer.
  Future<List<dynamic>> fetchKundliProfiles() async {
    final res = await get(Endpoints.kundli.profiles);
    return res.data['data'] as List<dynamic>? ?? [];
  }

  /// Creates a new Kundli profile.
  Future<Map<String, dynamic>> createKundliProfile({
    required String name,
    required String dateOfBirth,
    String? timeOfBirth,
    required String placeOfBirth,
    required double lat,
    required double lng,
  }) async {
    final res = await post(Endpoints.kundli.createProfile, data: {
      'label': name,
      'birthDate': dateOfBirth,
      if (timeOfBirth != null) 'birthTime': timeOfBirth,
      'birthPlace': placeOfBirth,
      'birthLat': lat,
      'birthLng': lng,
      'timezoneOffset': 5.5,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Updates an existing Kundli profile by [id].
  Future<Map<String, dynamic>> updateKundliProfile({
    required String id,
    required String name,
    required String dateOfBirth,
    String? timeOfBirth,
    required String placeOfBirth,
    required double lat,
    required double lng,
  }) async {
    final res = await patch(Endpoints.kundli.updateProfile(id), data: {
      'label': name,
      'birthDate': dateOfBirth,
      if (timeOfBirth != null) 'birthTime': timeOfBirth,
      'birthPlace': placeOfBirth,
      'birthLat': lat,
      'birthLng': lng,
      'timezoneOffset': 5.5,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Deletes a Kundli profile by [id].
  Future<void> deleteKundliProfile(String id) async {
    await delete(Endpoints.kundli.deleteProfile(id));
  }

  /// Fetches (or generates) the Kundli report for profile [profileId].
  /// In debug builds, passes ?refresh=true so the cache is always busted.
  Future<Map<String, dynamic>> fetchKundliReport(String profileId) async {
    final res = await get(
      Endpoints.kundli.report(profileId),
      queryParameters: const bool.fromEnvironment('dart.vm.product')
          ? null
          : {'refresh': 'true'},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches Ashtakvarga bindus + chart image for [profileId].
  /// [planet]: 'Sun' | 'Moon' | 'Mars' | 'Mercury' | 'Jupiter' | 'Venus' | 'Saturn' | 'total'
  Future<Map<String, dynamic>> fetchAshtakvarga(
    String profileId, {
    String planet = 'total',
  }) async {
    final res = await get(
      Endpoints.kundli.ashtakvarga(profileId),
      queryParameters: {'planet': planet},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches divisional chart planet positions for [profileId].
  /// [div]: 'D1' | 'D9' | 'D10' | etc.
  Future<Map<String, dynamic>> fetchDivisionalChart(
    String profileId, {
    String div = 'D1',
  }) async {
    final res = await get(
      Endpoints.kundli.divisional(profileId),
      queryParameters: {'div': div},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches full Vimshottari dasha hierarchy (maha + antar) for [profileId].
  Future<List<dynamic>> fetchFullDasha(String profileId) async {
    final res = await get(Endpoints.kundli.dasha(profileId));
    final data = res.data['data'];
    return data is List ? data : [];
  }

  /// Fetches specific sub-dasha levels (paryantar/sookshma/prana).
  Future<Map<String, dynamic>> fetchSpecificSubDasha(
    String profileId, {
    required String md,
    required String ad,
    required String pd,
    required String sd,
  }) async {
    final res = await get(
      Endpoints.kundli.dashaSpecific(profileId),
      queryParameters: {'md': md, 'ad': ad, 'pd': pd, 'sd': sd},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Computes Ashtakoot compatibility between two saved Kundli profiles.
  Future<Map<String, dynamic>> matchKundli({
    required String profileAId,
    required String profileBId,
  }) async {
    final res = await post(Endpoints.kundli.match, data: {
      'profileAId': profileAId,
      'profileBId': profileBId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Lists all previous Kundli match results.
  Future<List<dynamic>> fetchKundliMatches() async {
    final res = await get(Endpoints.kundli.matches);
    final data = res.data['data'];
    return data is List ? data : [];
  }

  // ─── AI Chat ───────────────────────────────────────────────────────────────

  /// Opens an SSE stream for an AI astrologer chat response.
  Future<Response<dynamic>> streamAiChat({
    required List<Map<String, String>> messages,
    String? kundliProfileId,
  }) {
    return stream(
      Endpoints.ai.chatStream,
      data: {
        'messages': messages,
        if (kundliProfileId != null) 'kundliProfileId': kundliProfileId,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  /// Fetches the current customer's full profile.
  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await get(Endpoints.profile.get);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Updates the current customer's profile fields.
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    final res = await patch(Endpoints.profile.update, data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─── Horoscopes (public) ───────────────────────────────────────────────────

  /// Fetches today's horoscope for [zodiacSign] (no auth required).
  Future<Map<String, dynamic>?> fetchDailyHoroscope(String zodiacSign) async {
    final res = await publicGet(Endpoints.public.todayHoroscope(zodiacSign));
    final data = res.data['data'];
    return data as Map<String, dynamic>?;
  }

  /// Fetches the weekly horoscope for [zodiacSign] (no auth required).
  Future<Map<String, dynamic>?> fetchWeeklyHoroscope(String zodiacSign) async {
    final res = await publicGet(Endpoints.public.weeklyHoroscope(zodiacSign));
    final data = res.data['data'];
    return data as Map<String, dynamic>?;
  }

  /// Fetches the monthly horoscope for [zodiacSign] (no auth required).
  Future<Map<String, dynamic>?> fetchMonthlyHoroscope(String zodiacSign) async {
    final res = await publicGet(Endpoints.public.monthlyHoroscope(zodiacSign));
    final data = res.data['data'];
    return data as Map<String, dynamic>?;
  }

  /// Fetches the yearly horoscope for [zodiacSign] (no auth required).
  Future<Map<String, dynamic>?> fetchYearlyHoroscope(String zodiacSign) async {
    try {
      final res = await publicGet(Endpoints.public.yearlyHoroscope(zodiacSign));
      final data = res.data['data'];
      return data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  /// Fetches the paginated in-app notification list.
  Future<List<dynamic>> fetchNotifications({int page = 1, int limit = 30}) async {
    final res = await get(Endpoints.notifications.list,
        queryParameters: {'page': page, 'limit': limit});
    return res.data['data'] as List<dynamic>? ?? [];
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(String id) async {
    await patch(Endpoints.notifications.markRead(id));
  }

  /// Marks all notifications as read.
  Future<void> markAllNotificationsRead() async {
    await post(Endpoints.notifications.markAllRead);
  }

  // ─── Consultations ─────────────────────────────────────────────────────────

  /// Ends an active consultation from the customer side.
  Future<void> endConsultation(String consultationId, {String reason = 'customerEnded'}) async {
    await post(Endpoints.consultations.end(consultationId), data: {'reason': reason});
  }

  /// Fetches the customer's consultation history.
  Future<Map<String, dynamic>> fetchConsultations({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await get(Endpoints.consultations.list, queryParameters: {
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      'page': page,
      'limit': limit,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Fetches active home-screen banners.
  Future<List<dynamic>> fetchBanners({String placement = 'home'}) async {
    final res = await publicGet(
      Endpoints.public.banners,
      queryParameters: {'placement': placement},
    );
    return res.data['data'] as List<dynamic>? ?? [];
  }

  /// Fetches trending astrologers for the home screen.
  Future<List<dynamic>> fetchTrendingAstrologers({int limit = 10}) async {
    final res = await publicGet(
      Endpoints.public.trendingAstrologers,
      queryParameters: {'limit': limit},
    );
    return res.data['data'] as List<dynamic>? ?? [];
  }

  /// Fetches the short-form stories feed.
  Future<List<dynamic>> fetchStories({int limit = 10}) async {
    final res = await publicGet(
      Endpoints.public.stories,
      queryParameters: {'limit': limit},
    );
    return res.data['data'] as List<dynamic>? ?? [];
  }

  /// Fetches the customer's puja bookings.
  Future<List<dynamic>> fetchPujaBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await get(
      Endpoints.puja.bookings,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final data = res.data['data'];
    if (data is Map) return data['items'] as List<dynamic>? ?? [];
    return data as List<dynamic>? ?? [];
  }

  /// Fetches the learning videos catalogue.
  Future<List<dynamic>> fetchLearningVideos({int limit = 8}) async {
    final res = await publicGet(
      Endpoints.public.learningVideos,
      queryParameters: {'limit': limit},
    );
    return res.data['data'] as List<dynamic>? ?? [];
  }

  // ── Addresses ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchAddresses() async {
    final res = await get(Endpoints.addresses.list);
    return (res.data['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    required String country,
    bool isDefault = false,
  }) async {
    final res = await post(Endpoints.addresses.create, data: {
      'label': label,
      'line1': line1,
      if (line2 != null) 'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'isDefault': isDefault,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAddress(String id, Map<String, dynamic> fields) async {
    final res = await patch(Endpoints.addresses.update(id), data: fields);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteAddress(String id) async {
    await delete(Endpoints.addresses.delete(id));
  }

  Future<void> setDefaultAddress(String id) async {
    await post(Endpoints.addresses.setDefault(id));
  }

  // ── Support Tickets ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchSupportTickets({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await get(Endpoints.support.list, queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchSupportTicket(String id) async {
    final res = await get(Endpoints.support.detail(id));
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSupportTicket({
    required String category,
    required String subject,
    required String description,
    String? linkedConsultationId,
  }) async {
    final res = await post(Endpoints.support.create, data: {
      'category': category,
      'subject': subject,
      'description': description,
      if (linkedConsultationId != null) 'linkedConsultationId': linkedConsultationId,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addSupportTicketMessage(String ticketId, String body) async {
    final res = await post(Endpoints.support.addMessage(ticketId), data: {'body': body});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> closeSupportTicket(String ticketId) async {
    await post(Endpoints.support.close(ticketId));
  }
}
