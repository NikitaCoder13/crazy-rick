import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static Future<Map<String, dynamic>> getCharacters(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/character?page=$page'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load characters');
    }
  }

  static Future<Map<String, dynamic>> getEpisodes(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/episode?page=$page'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load episodes');
    }
  }
}
