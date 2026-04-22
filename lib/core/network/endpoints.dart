/// Central registry of all API endpoint paths for the Customer app.
///
/// All paths are **relative** to [AppConfig.apiBaseUrl]
/// (e.g. `http://localhost:3000/v1/customer`).
///
/// Paths in [Endpoints.public] are relative to [AppConfig.publicApiBaseUrl]
/// (e.g. `http://localhost:3000/v1/public`) and must be called via
/// [ApiClient.publicGet].
///
/// Usage:
/// ```dart
/// final res = await ref.read(apiClientProvider).get(Endpoints.wallet.balance);
/// ```
library;

/// Namespaced endpoint paths for the Customer API.
abstract final class Endpoints {
  Endpoints._();

  /// Authentication routes (`/auth/*`).
  static const auth = _AuthEndpoints._();

  /// Astrologer discovery routes (`/astrologers/*`).
  static const astrologers = _AstrologerEndpoints._();

  /// Wallet and top-up routes (`/wallet/*`).
  static const wallet = _WalletEndpoints._();

  /// Kundli (birth chart) routes (`/kundli/*`).
  static const kundli = _KundliEndpoints._();

  /// AI chat routes (`/ai/*`).
  static const ai = _AiEndpoints._();

  /// Consultation routes (`/consultations/*`).
  static const consultations = _ConsultationEndpoints._();

  /// In-app notification routes (`/notifications/*`).
  static const notifications = _NotificationEndpoints._();

  /// Image upload route (`/upload/*`).
  static const uploads = _UploadEndpoints._();

  /// Unauthenticated public routes — relative to [AppConfig.publicApiBaseUrl].
  static const public = _PublicEndpoints._();
}

// ─── Auth ──────────────────────────────────────────────────────────────────

final class _AuthEndpoints {
  const _AuthEndpoints._();

  /// `POST` – Send a 6-digit OTP to [phone] via SMS (MSG91).
  /// Rate-limited: 5 per hour per phone, 20 per hour per IP.
  String get sendPhoneOtp => '/auth/phone/send-otp';

  /// `POST` – Verify phone OTP and issue [accessToken] + [refreshToken].
  String get verifyPhoneOtp => '/auth/phone/verify-otp';

  /// `POST` – Begin email sign-up. Triggers an email OTP for verification.
  String get emailSignup => '/auth/email/signup';

  /// `POST` – Verify the email OTP sent during sign-up.
  String get verifyEmailOtp => '/auth/email/verify-otp';

  /// `POST` – Resend the email verification OTP (rate-limited: 3/hr/email).
  String get resendEmailOtp => '/auth/email/resend-otp';

  /// `POST` – Log in with email + password after email verification.
  String get emailLogin => '/auth/email/login';

  /// `POST` – Initiate a password reset; sends a link to the registered email.
  String get forgotPassword => '/auth/email/forgot-password';

  /// `POST` – Complete the password reset using the token from the email link.
  String get resetPassword => '/auth/email/reset-password';

  /// `POST` – Sign in via Google ID token (Android / iOS).
  String get googleLogin => '/auth/google';

  /// `POST` – Rotate the refresh token and receive a fresh access token.
  String get refresh => '/auth/refresh';

  /// `DELETE` – Revoke the current session (server-side logout).
  String get logout => '/auth/logout';
}

// ─── Astrologers ───────────────────────────────────────────────────────────

final class _AstrologerEndpoints {
  const _AstrologerEndpoints._();

  /// `GET` – Paginated list of astrologers with search / filter support.
  /// Query params: `search`, `specialty`, `language`, `isOnline`,
  /// `minRating`, `maxPricePaise`, `sort`, `page`, `limit`.
  String get list => '/astrologers';

  /// `GET` – Full profile for a single astrologer.
  String detail(String id) => '/astrologers/$id';
}

// ─── Wallet ────────────────────────────────────────────────────────────────

final class _WalletEndpoints {
  const _WalletEndpoints._();

  /// `GET` – Current wallet balance and metadata.
  String get balance => '/wallet';

  /// `GET` – Paginated wallet transaction ledger.
  String get transactions => '/wallet/transactions';

  /// `POST` – Initiate a wallet top-up via a payment provider.
  String get topup => '/wallet/topup';

  /// `GET` – List of payment providers enabled for the current platform/region.
  String get providers => '/wallet/providers';
}

// ─── Kundli ────────────────────────────────────────────────────────────────

final class _KundliEndpoints {
  const _KundliEndpoints._();

  /// `GET` – List all saved Kundli profiles for the current customer.
  String get profiles => '/kundli/profiles';

  /// `POST` – Create a new Kundli profile (birth details).
  String get createProfile => '/kundli/profiles';

  /// `DELETE` – Delete a Kundli profile by [id].
  String deleteProfile(String id) => '/kundli/profiles/$id';

  /// `GET` – Fetch or generate a full Kundli report for profile [id].
  String report(String profileId) => '/kundli/profiles/$profileId/report';
}

// ─── AI Chat ───────────────────────────────────────────────────────────────

final class _AiEndpoints {
  const _AiEndpoints._();

  /// `POST` – Stream an AI astrologer response (Server-Sent Events / chunked).
  /// Body: `{ messages, kundliProfileId? }`. Response: `text/event-stream`.
  String get chatStream => '/ai/chat/stream';
}

// ─── Consultations ─────────────────────────────────────────────────────────

final class _ConsultationEndpoints {
  const _ConsultationEndpoints._();

  /// `GET` – Paginated list of the customer's consultations.
  /// Query params: `status`, `type`, `page`, `limit`.
  String get list => '/consultations';

  /// `POST` – Request a new chat / voice / video consultation.
  String get request => '/consultations/request';

  /// `GET` – Detail of a single consultation.
  String detail(String id) => '/consultations/$id';

  /// `GET` – Paginated chat messages for a consultation.
  String messages(String id) => '/consultations/$id/messages';

  /// `POST` – End an active consultation.
  String end(String id) => '/consultations/$id/end';
}

// ─── Notifications ─────────────────────────────────────────────────────────

final class _NotificationEndpoints {
  const _NotificationEndpoints._();

  /// `GET` – Paginated list of in-app notifications.
  String get list => '/notifications';

  /// `PATCH` – Mark a single notification as read.
  String markRead(String id) => '/notifications/$id/read';

  /// `POST` – Mark all notifications as read.
  String get markAllRead => '/notifications/read-all';

  /// `POST` – Register or refresh an FCM device token.
  String get registerFcmToken => '/notifications/fcm-token';
}

// ─── Uploads ───────────────────────────────────────────────────────────────

final class _UploadEndpoints {
  const _UploadEndpoints._();

  /// `GET` – Request a pre-signed PUT URL for direct S3 upload.
  /// Query params: `category` (profiles), `contentType` (MIME type).
  /// Returns `{ uploadUrl, tempKey, expiresIn }`.
  String get presign => '/upload/presign';

  /// `POST` – Upload an image (multipart/form-data). Legacy — kept for compat.
  String get image => '/upload/image';
}

// ─── Public (unauthenticated) ──────────────────────────────────────────────

final class _PublicEndpoints {
  const _PublicEndpoints._();

  /// `GET` – Active promotional banners.
  /// Query params: `placement` (e.g. `home`).
  String get banners => '/banners';

  /// `GET` – Top trending astrologers for home-screen showcasing.
  /// Query params: `limit`.
  String get trendingAstrologers => '/astrologers/trending';

  /// `GET` – Short-form story content feed.
  String get stories => '/stories';

  /// `GET` – Learning videos catalogue.
  String get learningVideos => '/learning-videos';

  /// `GET` – Today's horoscope for [zodiacSign].
  String todayHoroscope(String zodiacSign) => '/horoscopes/today/$zodiacSign';

  /// `GET` – Weekly horoscope for [zodiacSign].
  String weeklyHoroscope(String zodiacSign) => '/horoscopes/weekly/$zodiacSign';

  /// `GET` – Monthly horoscope for [zodiacSign].
  String monthlyHoroscope(String zodiacSign) => '/horoscopes/monthly/$zodiacSign';

  /// `GET` – Current brand theme colors.
  String get theme => '/settings/theme';
}
