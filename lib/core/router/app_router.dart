import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_notifier.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/email_auth_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/kundli/domain/kundli_models.dart';
import '../../features/kundli/presentation/kundli_list_screen.dart';
import '../../features/kundli/presentation/add_kundli_screen.dart';
import '../../features/kundli/presentation/kundli_report_screen.dart';
import '../../features/kundli/presentation/kundli_match_screen.dart';
import '../../features/horoscope/presentation/horoscope_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/astrologers/presentation/astrologer_list_screen.dart';
import '../../features/astrologers/presentation/astrologer_profile_screen.dart';
import '../../features/consultations/presentation/chat_screen.dart';
import '../../features/consultations/presentation/call_screen.dart';
import '../../features/consultations/presentation/chat_list_screen.dart';
import '../../features/consultations/presentation/call_list_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/puja/presentation/puja_list_screen.dart';
import '../../features/astromall/presentation/astromall_screen.dart';
import '../../features/support/presentation/support_screen.dart';
import '../../features/support/presentation/ticket_detail_screen.dart';
import '../../features/addresses/presentation/address_list_screen.dart';
import '../../features/addresses/presentation/add_address_screen.dart';
import '../../features/addresses/domain/address_models.dart';
import '../../features/referral/presentation/referral_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isUnknown = authState == AuthState.unknown;
      final isAuth = authState == AuthState.authenticated;
      final loc = state.matchedLocation;

      // Still initialising — stay on splash
      if (isUnknown) return loc == AppRoutes.splash ? null : AppRoutes.splash;

      final isAuthRoute = loc.startsWith('/auth');
      final isSplash = loc == AppRoutes.splash;

      // Not logged in → always go to phone auth
      if (!isAuth && (isSplash || !isAuthRoute)) return AppRoutes.authPhone;

      // Logged in → send away from auth/splash to home
      if (isAuth && (isAuthRoute || isSplash)) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.authPhone, builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(
        path: AppRoutes.authOtp,
        builder: (_, s) {
          final extra = s.extra as Map<String, dynamic>;
          return OtpScreen(
            identifier: extra['phone'] as String,
            type: extra['type'] as String? ?? 'phone',
          );
        },
      ),
      GoRoute(path: AppRoutes.authEmail, builder: (_, __) => const EmailAuthScreen()),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.chat, builder: (_, __) => const ChatListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.call, builder: (_, __) => const CallTabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryScreen()),
          ]),
        ],
      ),

      GoRoute(path: AppRoutes.aiChat, builder: (_, __) => const AiChatScreen()),
      GoRoute(path: AppRoutes.horoscope, builder: (_, __) => const HoroscopeScreen()),
      GoRoute(path: AppRoutes.kundliList, builder: (_, __) => const KundliListScreen()),
      GoRoute(path: AppRoutes.kundliAdd, builder: (_, __) => const AddKundliScreen()),
      GoRoute(
        path: '/kundli/:id/edit',
        builder: (_, s) {
          // profile is passed via extra; if missing, fall back to add screen
          final profile = s.extra;
          return AddKundliScreen(
            profile: profile is KundliProfile ? profile : null,
          );
        },
      ),
      GoRoute(
        path: '/kundli/:id/report',
        builder: (_, s) => KundliReportScreen(profileId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.kundliMatch,
        builder: (_, __) => const KundliMatchScreen(),
      ),
      GoRoute(path: AppRoutes.wallet, builder: (_, __) => const WalletScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: AppRoutes.profileEdit, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.astrologers, builder: (_, __) => const AstrologerListScreen()),
      GoRoute(
        path: '/astrologers/:id',
        builder: (_, s) => AstrologerProfileScreen(
            astrologerId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/chat/:id',
        builder: (_, s) => ConsultationChatScreen(
            consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/call/:id',
        builder: (_, s) => ConsultationCallScreen(
            consultationId: s.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.puja, builder: (_, __) => const PujaListScreen()),
      GoRoute(path: AppRoutes.astromall, builder: (_, __) => const AstromallScreen()),
      GoRoute(path: AppRoutes.support, builder: (_, __) => const SupportScreen()),
      GoRoute(
        path: '/support/tickets/:id',
        builder: (_, s) => TicketDetailScreen(ticketId: s.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.addresses, builder: (_, __) => const AddressListScreen()),
      GoRoute(path: AppRoutes.addressAdd, builder: (_, __) => const AddAddressScreen()),
      GoRoute(
        path: '/addresses/:id/edit',
        builder: (_, s) {
          final address = s.extra;
          return AddAddressScreen(
            existing: address is CustomerAddress ? address : null,
          );
        },
      ),
      GoRoute(path: AppRoutes.referral, builder: (_, __) => const ReferralScreen()),
    ],
  );
});
