import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AuthRepository {
  final ApiClient api = ApiClient();

  // -----------------------------
  // REGISTER
  // -----------------------------
  Future<void> register(String email, String password, String name) async {
    final response = await api.post('/api/auth/users/', {
      'email': email,
      'password': password,
      'name': name,
    });

    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw data['email']?[0] ?? data['password']?[0] ?? 'Ошибка регистрации';
    }

    // После регистрации — сразу логинимся
    await login(email, password);
  }

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<void> login(String email, String password) async {
    print('AFTER POST');
    final response = await api.post('/api/auth/jwt/create/', {
      'email': email,
      'password': password,
    });

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw data['detail'] ?? 'Ошибка авторизации';
    }

    final data = jsonDecode(response.body);
    final access = data['access'];
    final refresh = data['refresh'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', access);
    await prefs.setString('refresh', refresh);
  }

  // -----------------------------
  // GET PROFILE
  // -----------------------------
  Future<Map<String, dynamic>> getProfile() async {
    final response = await api.get('/api/auth/users/me/');
    final prefs = await SharedPreferences.getInstance();
    print("ACCESS TOKEN = ${prefs.getString('access')}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    }

    throw Exception('Не удалось загрузить профиль');
  }

  // -----------------------------
  // REFRESH TOKEN
  // -----------------------------
  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh');

    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/auth/jwt/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode >= 400) {
      await logout();
      return null;
    }

    final data = jsonDecode(response.body);
    final newAccess = data['access'];

    await prefs.setString('access', newAccess);

    return newAccess;
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // -----------------------------
  // CHECK LOGIN STATE
  // -----------------------------
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh') != null;
  }

  //-------------------------
  //Редактирование профиля
  //------------------------
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final response = await api.patch(
      '/api/auth/users/me/',
      data, // <-- передаём Map, НЕ строку
    );

    return response.statusCode == 200;
  }
}
