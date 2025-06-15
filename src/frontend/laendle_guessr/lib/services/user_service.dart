import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/data_objects/user.dart';


class UserService {
  final ApiService api;

  UserService(this.api);


  Future<List<dynamic>> getAllUsers() async {
    final response = await api.get('/user');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen der Benutzer');
    }
  }


  Future<bool> checkCredentials(String username, String password) async {
    final response = await api.post('/user/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }





  Future<Map<String, dynamic>> getUser(String uid) async {
    final response = await api.get('/user/$uid');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Benutzer nicht gefunden');
    }
  }


  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required int city,
    int coins = 0,
    bool admin = false,
  }) async {
    final body = {
      'username': username,
      'password': password,
      'city': city,
      'admin': admin,
      'coins': coins,
    };

    final response = await api.post('/user', body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['nachricht']);
    }
  }


  Future<Map<String, dynamic>> updateUser({
    required String uid,
    String? username,
    String? password,
    int? coins,
    bool? admin,
    int? city,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (password != null) body['password'] = password;
    if (coins != null) body['coins'] = coins;
    if (admin != null) body['admin'] = admin;
    if (city != null) body['city'] = city;

    final response = await api.put('/user/$uid', body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['nachricht']);
    }
  }
}
