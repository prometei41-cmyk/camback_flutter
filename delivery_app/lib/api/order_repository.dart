import 'dart:convert';
import 'package:delivery_app/api/api_client.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  final ApiClient api = ApiClient();

  Future<Map<String, dynamic>> createOrder(
    String token, {
    required int addressId,
    required String comment,
    required String paymentMethod,
    required String deliveryTime,
    required String promoCode,
    required List<Map<String, dynamic>> items,
    required double totalPrice,
  }) async {
    final response = await api.post('/api/orders/create/', {
      'address_id': addressId,
      'comment': comment,
      'payment_method': paymentMethod,
      'delivery_time': deliveryTime,
      'promo_code': promoCode,
      'items': items,
      'total_price': totalPrice,
    });

    print("=== CREATE ORDER ===");
    print("DATA = ${jsonEncode({
      'address_id': addressId,
      'comment': comment,
      'payment_method': paymentMethod,
      'delivery_time': deliveryTime,
      'promo_code': promoCode,
      'items': items,
      'total_price': totalPrice,
    })}");


    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getOrderHistory(String token) async {
    final response = await api.get('/api/orders/history/');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Ошибка загрузки истории заказов");
    }
  }
  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final response = await api.get("/api/orders/$id/");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    print("❌ Ошибка загрузки заказа: ${response.statusCode}");
    return null;
  }
}
