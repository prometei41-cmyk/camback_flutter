import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../features/notifications/api/notification_repository.dart';
import '../features/order/presentation/order_details_screen.dart';
import '../api/order_repository.dart';
import '../main.dart'; // здесь лежит navigatorKey

class PushService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  // --------------------------
  // ИНИЦИАЛИЗАЦИЯ
  // --------------------------
  static Future<void> initialize() async {
    // Разрешения
    await _messaging.requestPermission();

    // Локальные уведомления
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          _handleClick(jsonDecode(payload));
        }
      },
    );

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleForeground(message);
    });

    // Background → App opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleClick(message.data);
    });

    // Terminated
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleClick(initial.data);
    }
  }

  // --------------------------
  // FOREGROUND
  // --------------------------
  static void _handleForeground(RemoteMessage message) async {
    final title = message.notification?.title ?? "Уведомление";
    final body = message.notification?.body ?? "";
    final data = message.data;

    // Сохраняем на сервере
    try {
      await NotificationRepository().createNotification(
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      // Если не удалось сохранить, продолжаем
      print("Failed to save notification: $e");
    }

    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "high_importance_channel",
          "High Importance Notifications",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(data),
    );
  }


  // --------------------------
  // CLICK HANDLER (универсальный)
  // --------------------------
  static Future<void> _handleClick(Map<String, dynamic> data) async {
    final orderId = data["order_id"];
    if (orderId == null) return;

    print("🔥 CLICK HANDLER STARTED");
    print("🔥 DATA = $data");

    // Загружаем заказ
    final repo = OrderRepository();
    final order = await repo.getOrderById(orderId);
    if (order == null) return;

    // Навигация через navigatorKey
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }
}
