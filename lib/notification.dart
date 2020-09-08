import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  BehaviorSubject<Map<String, dynamic>> notificationSubject =
      BehaviorSubject<Map<String, dynamic>>();
  Future<void> init() async {
    if (!_initialized) {
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          notificationSubject.add({'type': 'Active App', 'value': message});
        },
        onLaunch: (Map<String, dynamic> message) async {
          notificationSubject.add({'type': 'Terminated App', 'value': message});
        },
        onResume: (Map<String, dynamic> message) async {
          notificationSubject.add({'type': 'Inactive App', 'value': message});
        },
      );

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  Future<void> createChannel() async {
    var notificationPlugin = FlutterLocalNotificationsPlugin();
    var notificationChannel = AndroidNotificationChannel(
        'test_push_notification',
        "Test Push Notification",
        "Channel to test push notification",
        importance: Importance.High);
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
  }
}
