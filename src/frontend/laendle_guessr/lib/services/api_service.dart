import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger.dart';

class ApiService{
  static final ApiService _instance = ApiService._internal('http://10.0.2.2:8080');

  factory ApiService(String baseURL) {
    _instance.baseURL = baseURL;
    return _instance;
  }

  ApiService._internal(this.baseURL);

  static ApiService get instance => _instance;

  String baseURL;

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseURL/$endpoint');
    AppLogger().log('GET $url');
    try {
      final response = await http.get(url);
      AppLogger().log('GET $url - Status: \\${response.statusCode}');
      return response;
    } catch (e) {
      AppLogger().log('GET $url - Fehler: $e');
      rethrow;
    }
  }


  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseURL/$endpoint');
    AppLogger().log('POST $url - Body: $data');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      AppLogger().log('POST $url - Status: \\${response.statusCode}');
      return response;
    } catch (e) {
      AppLogger().log('POST $url - Fehler: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseURL/$endpoint');
    AppLogger().log('PUT $url - Body: $data');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      AppLogger().log('PUT $url - Status: \\${response.statusCode}');
      return response;
    } catch (e) {
      AppLogger().log('PUT $url - Fehler: $e');
      rethrow;
    }
  }
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseURL/$endpoint');
    return await http.delete(url);
  }
}