import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_notifier.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/email_auth_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/kundli/presentation/kundli_list_screen.dart';
import '../../features/kundli/presentation/add_kundli_screen.dart';
import '../../features/kundli/presentation/kundli_report_screen.dart';
import '../../features/horoscope/presentation/horoscope_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/astrologers/presentation/astrologer_list_screen.dart';
import '../../features/astrologers/presentation/astrologer_profile_screen.dart';
import '../../features/consultations/presentation/chat_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isUnknown = authState == AuthState.unknown;
      final isAuth = authState == AuthState.authenticated;
      final loc = state.matchedLocation;

      if (isUnknown) return loc == '/splash' ? null : '/splash';

      final isAuthRoute = loc.startsWith('/auth');
      if (!isAuth && !isAuthRoute && loc != '/splash') return '/auth/phone';
      if (isAuth && (isAuthRoute || loc == '/splash')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, s) => OtpScreen(
          phone: (s.extra as Map<String, dynamic>)['phone'] as String,
        ),
      ),
      GoRoute(path: '/auth/email', builder: (_, __) => const EmailAuthScreen()),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/call', builder: (_, __) => const CallTabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          ]),
        ],
      ),

      GoRoute(path: '/ai-chat', builder: (_, __) => const AiChatScreen()),
      GoRoute(path: '/horoscope', builder: (_, __) => const HoroscopeScreen()),
      GoRoute(path: '/kundli', builder: (_, __) => const KundliListScreen()),
      GoRoute(path: '/kundli/add', builder: (_, __) => const AddKundliScreen()),
      GoRoute(
        path: '/kundli/:id/report',
        builder: (_, s) => KundliReportScreen(profileId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/astrologers', builder: (_, __) => const AstrologerListScreen()),
      GoRoute(
        path: '/astrologers/:id',
        builder: (_, s) => AstrologerProfileScreen(astrologerId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/chat/:id',
        builder: (_, s) => ConsultationChatScreen(consultationId: s.pathParameters['id']!),
      ),
    ],
  );
});

// Placeholder screens for tab branches
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF0D0B1E),
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Chat consultations coming soon')),
      );
}

class CallTabScreen extends StatelessWidget {
  const CallTabScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF0D0B1E),
        appBar: AppBar(title: const Text('Call')),
        body: const Center(child: Text('Call astrologers coming soon')),
      );
}
