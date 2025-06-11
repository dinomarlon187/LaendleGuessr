import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService{
  static final ApiService _instance = ApiService._internal('http://127.0.0.1:8080');

  factory ApiService(String baseURL) {
    _instance.baseURL = baseURL;
    return _instance;
  }

  ApiService._internal(this.baseURL);

  static ApiService get instance => _instance;

  String baseURL;

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseURL/$endpoint');
    return await http.get(url);
  }


  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseURL/$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseURL/$endpoint');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseURL/$endpoint');
    return await http.delete(url);
  }
}