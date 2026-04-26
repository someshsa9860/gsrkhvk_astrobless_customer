import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'core/cache/cache_service.dart';
import 'core/config/firebase_options.dart';
import 'core/theme/app_colors.dart';
import 'core/storage/storage_service.dart';
import 'features/wallet/data/wallet_repository.dart';
import 'app.dart';

// Global container lets top-level handlers (FCM, background isolates) invalidate
// providers without needing a BuildContext.
final _container = ProviderContainer();

final _localNotifications = FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  'astrobless_high',
  'Astrobless Notifications',
  description: 'Chat messages, billing alerts, and wallet updates',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initLocalNotifications() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _localNotifications.initialize(
    const InitializationSettings(
        android: androidSettings, iOS: iosSettings),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
}

void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  if (notification != null) {
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  final type = message.data['type'] as String?;
  switch (type) {
    case 'walletUpdated':
      _container.invalidate(walletProvider);
    case 'consultationRequest':
      Get.showSnackbar(GetSnackBar(
        title: notification?.title ?? 'Incoming Consultation',
        message: notification?.body ?? 'An astrologer wants to connect with you.',
        duration: const Duration(seconds: 6),
        icon: const Icon(Icons.phone_callback_rounded, color: Colors.white),
        backgroundColor: AppColors.primaryDark,
      ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _initLocalNotifications();
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await CacheService.init();
  await StorageService.init();

  runApp(UncontrolledProviderScope(container: _container, child: const App()));
}
