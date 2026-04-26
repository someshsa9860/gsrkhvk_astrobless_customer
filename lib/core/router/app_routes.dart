/// Central registry of all named navigation routes for the Customer app.
///
/// Every screen path lives here. No magic strings in widgets — always use
/// `AppRoutes.*` constants or methods when calling [GoRouter.push] / [GoRouter.go].
///
/// Parameterised routes use methods that build the path from typed arguments,
/// e.g. [AppRoutes.astrologerDetail] takes an [id] and returns the full path.
abstract final class AppRoutes {
  AppRoutes._();

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static const splash = '/splash';
  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authEmail = '/auth/email';

  // ─── Main shell tabs ─────────────────────────────────────────────────────

  static const home = '/home';
  static const chat = '/chat';
  static const call = '/call';
  static const history = '/history';

  // ─── Astrologers ─────────────────────────────────────────────────────────

  static const astrologers = '/astrologers';

  /// `/astrologers/:id`
  static String astrologerDetail(String id) => '/astrologers/$id';

  // ─── Consultations ───────────────────────────────────────────────────────

  /// `/consultation/chat/:id`
  static String consultationChat(String id) => '/consultation/chat/$id';

  /// `/consultation/call/:id`
  static String consultationCall(String id) => '/consultation/call/$id';

  // ─── Kundli ──────────────────────────────────────────────────────────────

  static const kundliList = '/kundli';
  static const kundliAdd = '/kundli/add';

  /// `/kundli/:id/edit`
  static String kundliEdit(String id) => '/kundli/$id/edit';

  /// `/kundli/:id/report`
  static String kundliReport(String id) => '/kundli/$id/report';

  static const kundliMatch = '/kundli/match';
  static const kundliMatchHistory = '/kundli/matches';

  // ─── Features ────────────────────────────────────────────────────────────

  static const horoscope = '/horoscope';
  static const aiChat = '/ai-chat';
  static const wallet = '/wallet';
  static const notifications = '/notifications';
  static const puja = '/puja';
  static const astromall = '/astromall';
  static const support = '/support';
  static const referral = '/referral';

  // ─── Profile ─────────────────────────────────────────────────────────────

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  // ─── Addresses ───────────────────────────────────────────────────────────

  static const addresses = '/addresses';
  static const addressAdd = '/addresses/add';

  /// `/addresses/:id/edit`
  static String addressEdit(String id) => '/addresses/$id/edit';

  // ─── Support Tickets ─────────────────────────────────────────────────────

  /// `/support/tickets/:id`
  static String supportTicketDetail(String id) => '/support/tickets/$id';
}
