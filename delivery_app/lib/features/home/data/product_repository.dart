import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/api/products';

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/?q=${Uri.encodeComponent(query)}'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Search timeout'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 400) {
        return []; // Query too short
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
