import 'dart:convert';
import 'package:delivery_app/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _api = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _api.get('/api/users/notifications/');
    final data = jsonDecode(response.body);

    if (data is List) {
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }

    if (data is Map && data.containsKey("results")) {
      return (data["results"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    }

    throw Exception("Неизвестный формат ответа");
  }

  Future<NotificationModel> createNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    final response = await _api.post('/api/users/notifications/', {
      'title': title,
      'body': body,
      'data': data,
    });
    final decoded = jsonDecode(response.body);
    return NotificationModel.fromJson(decoded);
  }

  Future<void> markAsRead(int id) async {
    await _api.patch('/api/users/notifications/$id/', {'is_read': true});
  }

  Future<void> deleteNotification(int id) async {
    await _api.delete('/api/users/notifications/$id/');
  }
}
