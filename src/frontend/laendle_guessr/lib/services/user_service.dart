import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/services/logger.dart';

/// Service für Benutzer-bezogene API-Aufrufe.
///
/// Diese Klasse kapselt alle API-Operationen rund um Benutzer (z.B. Login, User laden, Registrierung)
/// und nutzt den ApiService für die HTTP-Kommunikation mit dem Backend.
class UserService {
  final ApiService api;

  UserService._internal(this.api) {
    AppLogger().log('UserService instanziiert');
  }
  static final UserService _instance = UserService._internal(ApiService.instance);

  factory UserService() {
    return _instance;
  }

  static UserService get instance => _instance;


  Future<List<dynamic>> getAllUsers() async {
    AppLogger().log('UserService: getAllUsers() aufgerufen');
    final response = await api.get('user');
    if (response.statusCode == 200) {
      final users = jsonDecode(response.body);
      AppLogger().log('UserService: ${users.length} Benutzer erfolgreich geladen');
      return users;
    } else {
      AppLogger().log('UserService: Fehler beim Abrufen der Benutzer - Status: ${response.statusCode}');
      throw Exception('Fehler beim Abrufen der Benutzer');
    }
  }


  Future<bool> checkCredentials(String username, String password) async {
    AppLogger().log('UserService: checkCredentials() für Benutzer: $username');
    final response = await api.post('user/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      AppLogger().log('UserService: Login erfolgreich für Benutzer: $username');
      return true;
    } else {
      AppLogger().log('UserService: Login fehlgeschlagen für Benutzer: $username - Status: ${response.statusCode}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUser(String uid) async {
    AppLogger().log('UserService: getUser() für UID: $uid');
    final response = await api.get('user/$uid');
    if (response.statusCode == 200) {
      AppLogger().log('UserService: Benutzer erfolgreich geladen für UID: $uid');
      return jsonDecode(response.body);
    } else {
      AppLogger().log('UserService: Benutzer nicht gefunden für UID: $uid - Status: ${response.statusCode}');
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

    final response = await api.post('user', body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['nachricht']);
    }
  }


  Future<Map<String, dynamic>> updateUser({
    required int uid,
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

    final response = await api.put('user/$uid', body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['nachricht']);
    }
  }
  
  Future<Map<String, dynamic>> getAllTimeStats() async {
    final response = await api.get('all_time_stats/${UserManager.instance.currentUser!.uid}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return {
        'timeInSeconds': jsonResponse['timeInSeconds'],
        'steps': jsonResponse['steps'],
      };
    } else {
      throw Exception('Fehler beim Laden der All-Time-Statistiken: ${response.statusCode}');
    }
  }
}
