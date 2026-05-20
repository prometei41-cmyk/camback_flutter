import 'dart:convert';
import 'package:http/http.dart' as http;

import '../features/profile/models/address_model.dart';
import 'api_client.dart';

class AddressRepository {
  // ============================
  // GET LIST
  // ============================
  Future<List<AddressModel>> getAddresses(String token) async {
    final api = ApiClient();  // Используем ApiClient
    final response = await api.get('/api/addresses/');  // Без токена в параметре, ApiClient добавит его сам

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.map((item) => AddressModel.fromJson(item)).toList();
    } else {
      throw Exception('Invalid response format');
    }
  }

  // ============================
  // CREATE
  // ============================
  Future<AddressModel> createAddress(
      String token, Map<String, dynamic> addressData) async {
    final api = ApiClient();
    final response = await api.post('/api/addresses/', addressData);

    final decoded = jsonDecode(response.body);
    return AddressModel.fromJson(decoded);
  }

  // ============================
  // UPDATE
  // ============================
  Future<AddressModel> updateAddress(
      String token, int addressId, Map<String, dynamic> addressData) async {
    final api = ApiClient();
    final response = await api.patch('/api/addresses/$addressId/', addressData);

    final decoded = jsonDecode(response.body);
    return AddressModel.fromJson(decoded);
  }

  // ============================
  // DELETE
  // ============================
  Future<void> deleteAddress(String token, int addressId) async {
    final api = ApiClient();
    await api.delete('/api/addresses/$addressId/');
  }

  // ============================
  // SET DEFAULT
  // ============================
  Future<bool> setDefault(String token, int addressId) async {
    final api = ApiClient();
    final response = await api.post('/api/addresses/$addressId/set_default/', {});

    return response.statusCode == 200;
  }

  // ============================
  // SEARCH STREETS
  // ============================
  Future<List<Map<String, dynamic>>> searchStreets(String query) async {
    final api = ApiClient();
    final response = await api.get('/api/addresses/search_streets/?q=$query');

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    } else {
      return [];
    }
  }

  // ============================
  // SEARCH HOUSES
  // ============================
  Future<List<String>> searchHouses(String street, String query) async {
    final api = ApiClient();
    final response = await api.get('/api/addresses/search_houses/?street=$street&q=$query');

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return List<String>.from(decoded);
    } else {
      return [];
    }
  }

  // ============================
  // SEARCH ENTRANCES
  // ============================
  Future<List<String>> searchEntrances(
      String street, String house, String query) async {
    final api = ApiClient();
    final response = await api.get('/api/addresses/search_entrances/?street=$street&house=$house&q=$query');

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return List<String>.from(decoded);
    } else {
      return [];
    }
  }
}
