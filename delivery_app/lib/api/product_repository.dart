import 'dart:convert';
import 'package:delivery_app/api/api_client.dart';

class ProductRepository {
  final ApiClient api = ApiClient();

  Future<List<dynamic>> getCategories() async {
    final response = await api.get('/api/products/categories/');

    final data = jsonDecode(response.body);
    if (data is List) {
      return data; // сервер вернул список напрямую
    }
    if (data is Map && data['categories'] is List) {
      return data['categories']; // сервер вернул объект с ключом
    }
    return []; // сервер вернул что-то другое → возвращаем пустой список
  }

  Future<List<dynamic>> getProducts() async {
    final response = await api.get('/api/products/products/');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data;
    }
    if (data is Map && data['products'] is List) {
      return data['products'];
    }
    return [];
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await api.get('/api/products/products/$id/');
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception("Invalid product response");
  }

}
