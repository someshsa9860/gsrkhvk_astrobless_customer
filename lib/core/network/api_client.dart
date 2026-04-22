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

  // ─── Wallet ────────────────────────────────────────────────────────────────

  /// Fetches the current wallet balance.
  Future<Map<String, dynamic>> fetchWallet() async {
    final res = await get(Endpoints.wallet.balance);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches the wallet transaction ledger.
  Future<List<dynamic>> fetchWalletTransactions() async {
    final res = await get(Endpoints.wallet.transactions);
    return res.data['data'] as List<dynamic>? ?? [];
  }

  // ─── Astrologers ───────────────────────────────────────────────────────────

  /// Fetches a paginated list of astrologers with optional filters.
  Future<Map<String, dynamic>> fetchAstrologers({
    String? search,
    String? specialty,
    String? language,
    bool? isOnline,
    double? minRating,
    int? maxPricePaise,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await get(Endpoints.astrologers.list, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (specialty != null) 'specialty': specialty,
      if (language != null) 'language': language,
      if (isOnline != null) 'isOnline': isOnline,
      if (minRating != null) 'minRating': minRating,
      if (maxPricePaise != null) 'maxPricePaise': maxPricePaise,
      if (sort != null) 'sort': sort,
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
      'name': name,
      'dateOfBirth': dateOfBirth,
      if (timeOfBirth != null) 'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'lat': lat,
      'lng': lng,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Deletes a Kundli profile by [id].
  Future<void> deleteKundliProfile(String id) async {
    await delete(Endpoints.kundli.deleteProfile(id));
  }

  /// Fetches (or generates) the Kundli report for profile [profileId].
  Future<Map<String, dynamic>> fetchKundliReport(String profileId) async {
    final res = await get(Endpoints.kundli.report(profileId));
    return res.data['data'] as Map<String, dynamic>;
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

  /// Fetches the learning videos catalogue.
  Future<List<dynamic>> fetchLearningVideos({int limit = 8}) async {
    final res = await publicGet(
      Endpoints.public.learningVideos,
      queryParameters: {'limit': limit},
    );
    return res.data['data'] as List<dynamic>? ?? [];
  }
}
