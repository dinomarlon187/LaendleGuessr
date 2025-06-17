import 'dart:convert';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:flutter/foundation.dart';

class QuestService{
  static final QuestService _instance = QuestService._internal(ApiService.instance);

  factory QuestService() {
    return _instance;
  }
  static QuestService get instance => _instance;

  QuestService._internal(this.api);
  
  final ApiService api;



  Future<List<Quest>> getAllQuests() async {
    final response = await api.get('all_quests');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        return [];
      }
      return jsonList.map((jsonItem) => Quest.fromJson(jsonItem)).toList();
    }
    else{
      throw Exception('Fehler beim Laden aller Quests: ${response.statusCode}');
    }
  }

  Future<List<Quest>> getAllDoneQuestsByUser(User user) async {
    final response = await api.get('all_quests_user/${user.uid}');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        return <Quest>[];
      }
      return jsonList.map((jsonItem) => Quest.fromJson(jsonItem['quest'])).toList();
    }
    else{
      throw Exception('Fehler beim Laden aller gemachten Quests eines Users: ${response.statusCode}');
    }
  }

  Future<Quest> getdailyQuest(City city) async {
    final response = await api.get('dailyquest/${city.id}');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        throw Exception('Keine Daily Quest für Stadt ${city.id} gefunden.');
      }
      final Map<String, dynamic> json = jsonList[0];
      return Quest.fromJson(json);
    } 
    else {
      throw Exception('Fehler beim Laden der Daily Quest: ${response.statusCode}');
    }
  }

  Future<Quest> getweeklyQuest() async {
    final response = await api.get('weeklyquest');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      final Map<String, dynamic> json = jsonList[0];
      return Quest.fromJson(json);
    }
    else{
      throw Exception('Fehler beim Laden der Weekly Quest: ${response.statusCode}');
    }
  }

  Future postQuestDoneByUser(int qid, int uid, int stepcount, int timeInSeconds) async {
    final json = {
      'id' : qid,
      'uid': uid,
      'steps': stepcount,
      'timeInSeconds': timeInSeconds,
    };
    final response = await api.post('quest_user', json);
    if (response.statusCode != 200){
      throw Exception('Fehler beim zuweisen eienr Quest zu einem User: ${response.statusCode}');
    }
  }

  Future<Quest?> getActiveQuestForUser(User user) async {
  final response = await api.get('activequest/${user.uid}');
  if (response.statusCode == 200) {
    if (response.body.isEmpty || response.body == 'None') {
      return null;
    }
    final Map<String, dynamic> json = jsonDecode(response.body);
    return Quest.fromJson(json);
  } else {
    throw Exception('Fehler beim Laden der aktiven Quest: ${response.statusCode}');
  }
}
  Future<Quest> getQuestById(int qid) async {
    final response = await api.get('quest/$qid');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Quest.fromJson(json);
    } else {
      throw Exception('Fehler beim Laden der Quest mit ID $qid: ${response.statusCode}');
    }

  }
  Future<void> addQuestToActive(User user, int qid) async {
    final json = {
      'uid': user.uid,
      'qid': qid,
    };
    final response = await api.post('activequest', json);
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Hinzufügen der aktiven Quest: ${response.statusCode}');
    }
  }
  Future<void> removeQuestFromActive(User user) async {
    final response = await api.delete('activequest/${user.uid}');
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Entfernen der aktiven Quest: ${response.statusCode}');
    }
  }

  Future<int> getActiveQuestDuration(User user) async {
  final response = await api.get('activequest_started/${user.uid}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    String dateString = jsonResponse['started_at'];

    DateTime startedAt = DateTime.parse(dateString); 

    return DateTime.now().difference(startedAt).inSeconds;
  } else {
    throw Exception('Fehler beim Laden der Startzeit der aktiven Quest: ${response.statusCode}');
  }
  } 

  Future<void> updateActiveQuestStepCount(User user, int steps) async{
    final Map<String, dynamic> stepCount = {
      'steps': steps,
    };
    final response = await api.put('activequest/${user.uid}/stepcount', stepCount);
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Aktualisieren der Schrittanzahl der aktiven Quest: ${response.statusCode}');
    }

  }
  Future<int> getActiveQuestStepCount(User user) async {
    final response = await api.get('activequest/${user.uid}/stepcount');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['steps'];
    } 
    return 0;
  }

  
}