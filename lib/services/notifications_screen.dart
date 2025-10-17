import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _fcm.getToken();
      if (token != null) {
        await saveTokenToDatabase(token);
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen(saveTokenToDatabase);
    }
  }

  Future<void> saveTokenToDatabase(String token) async {
    String? userId = _auth.currentUser?.uid;
    
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('FCM Token saved: $token');
    }
  }
}