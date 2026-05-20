import 'dart:convert';
import 'package:http/http.dart' as http;

class FiasService {
  static const _token = 'ТВОЙ_DADATA_TOKEN';

  Future<List<String>> suggestHouses(String street, String query) async {
    if (street.isEmpty || query.isEmpty) return [];

    final url = Uri.parse(
      'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $_token',
      },
      body: jsonEncode({
        'query': '$street $query',
        'count': 10,
        'from_bound': {'value': 'house'},
        'to_bound': {'value': 'house'},
      }),
    );

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final suggestions = data['suggestions'] as List;

    return suggestions
        .map((s) => s['data']['house'] ?? '')
        .where((h) => h.toString().isNotEmpty)
        .cast<String>()
        .toList();
  }
}
