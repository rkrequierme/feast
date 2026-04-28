// lib/core/services/notification_service.dart
//
// Handles both FCM push notifications and local flutter_local_notifications.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feast/core/core.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.showLocalNotification(
    title: message.notification?.title ?? 'F.E.A.S.T.',
    body: message.notification?.body ?? '',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ─── Initialise ────────────────────────────────────────────────────────

  Future<void> init() async {
    // Local notifications setup
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Request FCM permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(
        title: message.notification?.title ?? 'F.E.A.S.T.',
        body: message.notification?.body ?? '',
      );
    });

    // Save FCM token to Firestore when user is signed in
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _saveFcmToken(user.uid);
      }
    });

    // Refresh token
    _fcm.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(uid)
            .update({'fcmToken': token});
      }
    });
  }

  // ─── Show Local Notification ────────────────────────────────────────────

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'feast_channel',
      'F.E.A.S.T. Notifications',
      channelDescription: 'Notifications from the F.E.A.S.T. app',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotif.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  // ─── Toggle Notifications ───────────────────────────────────────────────

  Future<void> setNotificationsEnabled(String uid, bool enabled) async {
    await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(uid)
        .update({'notificationsEnabled': enabled});
  }

  // ─── Save FCM Token ──────────────────────────────────────────────────────

  Future<void> _saveFcmToken(String uid) async {
    final token = await _fcm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(uid)
        .update({'fcmToken': token});
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// FCM tokens are stored in users/{uid}.fcmToken.
// The React.js admin dashboard (or Cloud Functions) should use the
// Firebase Admin SDK to send targeted FCM messages:
//   admin.messaging().send({
//     token: userDoc.fcmToken,
//     notification: { title: '...', body: '...' },
//   });
// Firestore notifications sub-collection is the persistent inbox;
// FCM is the real-time push layer.
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
