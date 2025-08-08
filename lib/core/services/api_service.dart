import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/environment.dart';

class ApiService {
  final baseUrl = Environment.baseUrl;

  Future<List<dynamic>> fetchPerumahan() async {
    final url = Uri.parse('$baseUrl/mobile/api/perumahan');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); // asumsi response berupa list
    } else {
      throw Exception('Failed to load data');
    }
  }
}
