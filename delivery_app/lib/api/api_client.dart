import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.0.153:8000';

  Future<Map<String, String>> _authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',

    };
  }

  Future<http.Response> _request(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _authorizedHeaders();

    http.Response response;

    // --- Первый запрос ---
    response = await _send(method, url, headers, body);

    // --- Если токен истёк ---
    if (response.statusCode == 401) {
      final newToken = await AuthRepository().refreshToken();

      if (newToken == null) {
        throw Exception('SESSION_EXPIRED');
      }

      final retryHeaders = await _authorizedHeaders();
      response = await _send(method, url, retryHeaders, body);
    }

    // --- Логирование ошибок ---
    if (response.statusCode >= 400) {
      print("API ERROR ${response.statusCode}: ${response.body}");
      throw Exception("API_ERROR_${response.statusCode}");
    }

    return response;
  }

  Future<http.Response> _send(
      String method,
      Uri url,
      Map<String, String> headers,
      Map<String, dynamic>? body,
      ) {
    switch (method) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(url, headers: headers, body: jsonEncode(body));
      case 'PATCH':
        return http.patch(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported method');
    }
  }

  // --- Публичные методы ---
  Future<http.Response> get(String path) => _request('GET', path);

  Future<http.Response> post(String path, Map<String, dynamic> body) =>
      _request('POST', path, body: body);

  Future<http.Response> patch(String path, Map<String, dynamic> body) =>
      _request('PATCH', path, body: body);

  Future<http.Response> delete(String path) => _request('DELETE', path);
}
