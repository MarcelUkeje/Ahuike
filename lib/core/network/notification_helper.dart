import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showPaymentWarning() async {
    const androidDetails = AndroidNotificationDetails(
      'payment_warning_channel',
      'Payment Warnings',
      channelDescription: 'Alerts when payment time is running out',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _plugin.show(
      0,
      'Payment Expiring Soon!',
      'You have 1 minute left to complete your payment before the slot is released.',
      details,
    );
  }
}
