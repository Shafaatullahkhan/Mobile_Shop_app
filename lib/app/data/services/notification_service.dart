import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  late FirebaseMessaging _messaging;

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get Token
      // String? token = await _messaging.getToken();
      // print('FCM Token: $token');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground messages
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle message clicks
      });
    }
  }
}
