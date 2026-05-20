import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_client.dart';

class CartRepository {
  

  Future<List<dynamic>> getCart(String token) async {
    final api = ApiClient();
    final response = await api.get('/api/cart/');
    

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Ошибка загрузки корзины");
    }
  }

  Future<bool> addToCart(String token, int productId, int qty) async {
    final api = ApiClient();
    final response = await api.post('/api/cart/add/', {
      'product_id': productId,
      'quantity': qty,
    });
    

    return response.statusCode == 200;
  }

  Future<bool> updateItem(String token, int itemId, int qty) async {
    final api = ApiClient();
    final response = await api.patch('/api/cart/update/', {  // Используйте patch вместо put, если API поддерживает
      'item_id': itemId,
      'quantity': qty,
    });

    return response.statusCode == 200;
  }

  Future<bool> removeItem(String token, int itemId) async {
    final api = ApiClient();
    final response = await api.post('/api/cart/remove/', {
      'item_id': itemId,
    });

    return response.statusCode == 200;
  }

  Future<bool> clearCart(String token) async {
    final api = ApiClient();
    final response = await api.post('/api/cart/clear/', {});

    return response.statusCode == 200;
  }
}
