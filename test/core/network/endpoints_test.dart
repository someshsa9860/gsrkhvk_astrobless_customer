import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/network/endpoints.dart';

void main() {
  group('Endpoints.auth', () {
    test('sendPhoneOtp path is correct', () {
      expect(Endpoints.auth.sendPhoneOtp, '/auth/phone/send-otp');
    });

    test('verifyPhoneOtp path is correct', () {
      expect(Endpoints.auth.verifyPhoneOtp, '/auth/phone/verify-otp');
    });

    test('emailSignup path is correct', () {
      expect(Endpoints.auth.emailSignup, '/auth/email/signup');
    });

    test('verifyEmailOtp path is correct', () {
      expect(Endpoints.auth.verifyEmailOtp, '/auth/email/verify-otp');
    });

    test('emailLogin path is correct', () {
      expect(Endpoints.auth.emailLogin, '/auth/email/login');
    });

    test('googleLogin path is correct', () {
      expect(Endpoints.auth.googleLogin, '/auth/google');
    });

    test('refresh path is correct', () {
      expect(Endpoints.auth.refresh, '/auth/refresh');
    });

    test('logout path is correct', () {
      expect(Endpoints.auth.logout, '/auth/logout');
    });
  });

  group('Endpoints.astrologers', () {
    test('list path is correct', () {
      expect(Endpoints.astrologers.list, '/astrologers');
    });

    test('detail interpolates id correctly', () {
      expect(Endpoints.astrologers.detail('abc-123'), '/astrologers/abc-123');
    });
  });

  group('Endpoints.wallet', () {
    test('balance path is correct', () {
      expect(Endpoints.wallet.balance, '/wallet');
    });

    test('transactions path is correct', () {
      expect(Endpoints.wallet.transactions, '/wallet/transactions');
    });

    test('topup path is correct', () {
      expect(Endpoints.wallet.topup, '/wallet/topup');
    });

    test('providers path is correct', () {
      expect(Endpoints.wallet.providers, '/wallet/providers');
    });
  });

  group('Endpoints.kundli', () {
    test('profiles path is correct', () {
      expect(Endpoints.kundli.profiles, '/kundli/profiles');
    });

    test('createProfile path is correct', () {
      expect(Endpoints.kundli.createProfile, '/kundli/profiles');
    });

    test('deleteProfile interpolates id correctly', () {
      expect(Endpoints.kundli.deleteProfile('profile-1'), '/kundli/profiles/profile-1');
    });

    test('report interpolates profileId correctly', () {
      expect(Endpoints.kundli.report('profile-1'), '/kundli/profiles/profile-1/report');
    });
  });

  group('Endpoints.ai', () {
    test('chatStream path is correct', () {
      expect(Endpoints.ai.chatStream, '/ai/chat/stream');
    });
  });

  group('Endpoints.consultations', () {
    test('list path is correct', () {
      expect(Endpoints.consultations.list, '/consultations');
    });

    test('request path is correct', () {
      expect(Endpoints.consultations.request, '/consultations/request');
    });

    test('detail interpolates id correctly', () {
      expect(Endpoints.consultations.detail('c-1'), '/consultations/c-1');
    });

    test('messages interpolates id correctly', () {
      expect(Endpoints.consultations.messages('c-1'), '/consultations/c-1/messages');
    });

    test('end interpolates id correctly', () {
      expect(Endpoints.consultations.end('c-1'), '/consultations/c-1/end');
    });
  });

  group('Endpoints.notifications', () {
    test('list path is correct', () {
      expect(Endpoints.notifications.list, '/notifications');
    });

    test('markRead interpolates id correctly', () {
      expect(Endpoints.notifications.markRead('n-1'), '/notifications/n-1/read');
    });

    test('markAllRead path is correct', () {
      expect(Endpoints.notifications.markAllRead, '/notifications/read-all');
    });

    test('registerFcmToken path is correct', () {
      expect(Endpoints.notifications.registerFcmToken, '/notifications/fcm-token');
    });
  });

  group('Endpoints.public', () {
    test('banners path is correct', () {
      expect(Endpoints.public.banners, '/banners');
    });

    test('trendingAstrologers path is correct', () {
      expect(Endpoints.public.trendingAstrologers, '/astrologers/trending');
    });

    test('stories path is correct', () {
      expect(Endpoints.public.stories, '/stories');
    });

    test('learningVideos path is correct', () {
      expect(Endpoints.public.learningVideos, '/learning-videos');
    });

    test('todayHoroscope interpolates sign correctly', () {
      expect(Endpoints.public.todayHoroscope('aries'), '/horoscopes/today/aries');
    });

    test('weeklyHoroscope interpolates sign correctly', () {
      expect(Endpoints.public.weeklyHoroscope('leo'), '/horoscopes/weekly/leo');
    });

    test('monthlyHoroscope interpolates sign correctly', () {
      expect(Endpoints.public.monthlyHoroscope('scorpio'), '/horoscopes/monthly/scorpio');
    });
  });
}
