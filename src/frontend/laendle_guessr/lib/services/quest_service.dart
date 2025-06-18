import 'dart:convert';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/services/logger.dart';
import 'package:flutter/foundation.dart';

class QuestService{
  static final QuestService _instance = QuestService._internal(ApiService.instance);

  factory QuestService() {
    return _instance;
  }
  static QuestService get instance => _instance;

  QuestService._internal(this.api) {
    AppLogger().log('QuestService instanziiert');
  }
  
  final ApiService api;



  Future<List<Quest>> getAllQuests() async {
    AppLogger().log('QuestService: getAllQuests() aufgerufen');
    final response = await api.get('all_quests');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        AppLogger().log('QuestService: Keine Quests gefunden');
        return [];
      }
      final quests = jsonList.map((jsonItem) => Quest.fromJson(jsonItem)).toList();
      AppLogger().log('QuestService: ${quests.length} Quests erfolgreich geladen');
      return quests;
    }
    else{
      AppLogger().log('QuestService: Fehler beim Laden aller Quests - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden aller Quests: ${response.statusCode}');
    }
  }

  Future<List<Quest>> getAllDoneQuestsByUser(User user) async {
    AppLogger().log('QuestService: getAllDoneQuestsByUser() für User ${user.uid}');
    final response = await api.get('all_quests_user/${user.uid}');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        AppLogger().log('QuestService: Keine erledigten Quests für User ${user.uid} gefunden');
        return <Quest>[];
      }
      final quests = jsonList.map((jsonItem) => Quest.fromJson(jsonItem['quest'])).toList();
      AppLogger().log('QuestService: ${quests.length} erledigte Quests für User ${user.uid} geladen');
      return quests;
    }
    else{
      AppLogger().log('QuestService: Fehler beim Laden erledigter Quests für User ${user.uid} - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden aller gemachten Quests eines Users: ${response.statusCode}');
    }
  }

  Future<Quest> getdailyQuest(City city) async {
    AppLogger().log('QuestService: getdailyQuest() für Stadt ${city.name} (ID: ${city.id})');
    final response = await api.get('dailyquest/${city.id}');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) {
        AppLogger().log('QuestService: Keine Daily Quest für Stadt ${city.name} gefunden');
        throw Exception('Keine Daily Quest für Stadt ${city.id} gefunden.');
      }
      final Map<String, dynamic> json = jsonList[0];
      final quest = Quest.fromJson(json);
      AppLogger().log('QuestService: Daily Quest für Stadt ${city.name} erfolgreich geladen: ${quest.questName}');
      return quest;
    } 
    else {
      AppLogger().log('QuestService: Fehler beim Laden der Daily Quest - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden der Daily Quest: ${response.statusCode}');
    }
  }

  Future<Quest> getweeklyQuest() async {
    AppLogger().log('QuestService: getweeklyQuest() aufgerufen');
    final response = await api.get('weeklyquest');
    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);
      final Map<String, dynamic> json = jsonList[0];
      AppLogger().log('QuestService: Weekly Quest erfolgreich geladen: ${json['questName']}');
      return Quest.fromJson(json);
    }
    else{
      AppLogger().log('QuestService: Fehler beim Laden der Weekly Quest - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden der Weekly Quest: ${response.statusCode}');
    }
  }

  Future postQuestDoneByUser(int qid, int uid, int stepcount, int timeInSeconds) async {
    AppLogger().log('QuestService: postQuestDoneByUser() - Quest ID: $qid, User ID: $uid, Schritte: $stepcount, Zeit: $timeInSeconds Sekunden');
    final json = {
      'id' : qid,
      'uid': uid,
      'steps': stepcount,
      'timeInSeconds': timeInSeconds,
    };
    final response = await api.post('quest_user', json);
    if (response.statusCode != 200){
      AppLogger().log('QuestService: Fehler beim Zuordnen der Quest zu User - Status: ${response.statusCode}');
      throw Exception('Fehler beim zuweisen eienr Quest zu einem User: ${response.statusCode}');
    }
    AppLogger().log('QuestService: Quest erfolgreich als erledigt markiert');
  }

  Future<Quest?> getActiveQuestForUser(User user) async {
  AppLogger().log('QuestService: getActiveQuestForUser() für User ${user.uid}');
  final response = await api.get('activequest/${user.uid}');
  if (response.statusCode == 200) {
    if (response.body.isEmpty || response.body == 'None') {
      AppLogger().log('QuestService: Keine aktive Quest für User ${user.uid} gefunden');
      return null;
    }
    final Map<String, dynamic> json = jsonDecode(response.body);
    AppLogger().log('QuestService: Aktive Quest für User ${user.uid} erfolgreich geladen: ${json['questName']}');
    return Quest.fromJson(json);
  } else {
    AppLogger().log('QuestService: Fehler beim Laden der aktiven Quest für User ${user.uid} - Status: ${response.statusCode}');
    throw Exception('Fehler beim Laden der aktiven Quest: ${response.statusCode}');
  }
}
  Future<Quest> getQuestById(int qid) async {
    AppLogger().log('QuestService: getQuestById() für Quest ID $qid');
    final response = await api.get('quest/$qid');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      AppLogger().log('QuestService: Quest mit ID $qid erfolgreich geladen');
      return Quest.fromJson(json);
    } else {
      AppLogger().log('QuestService: Fehler beim Laden der Quest mit ID $qid - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden der Quest mit ID $qid: ${response.statusCode}');
    }

  }
  Future<void> addQuestToActive(User user, int qid) async {
    AppLogger().log('QuestService: addQuestToActive() - User ID: ${user.uid}, Quest ID: $qid');
    final json = {
      'uid': user.uid,
      'qid': qid,
    };
    final response = await api.post('activequest', json);
    if (response.statusCode != 200) {
      AppLogger().log('QuestService: Fehler beim Hinzufügen der aktiven Quest - Status: ${response.statusCode}');
      throw Exception('Fehler beim Hinzufügen der aktiven Quest: ${response.statusCode}');
    }
    AppLogger().log('QuestService: Aktive Quest erfolgreich hinzugefügt');
  }
  Future<void> removeQuestFromActive(User user) async {
    AppLogger().log('QuestService: removeQuestFromActive() für User ${user.uid}');
    final response = await api.delete('activequest/${user.uid}');
    if (response.statusCode != 200) {
      AppLogger().log('QuestService: Fehler beim Entfernen der aktiven Quest - Status: ${response.statusCode}');
      throw Exception('Fehler beim Entfernen der aktiven Quest: ${response.statusCode}');
    }
    AppLogger().log('QuestService: Aktive Quest erfolgreich entfernt');
  }

  Future<int> getActiveQuestDuration(User user) async {
  AppLogger().log('QuestService: getActiveQuestDuration() für User ${user.uid}');
  final response = await api.get('activequest_started/${user.uid}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    String dateString = jsonResponse['started_at'];

    DateTime startedAt = DateTime.parse(dateString); 

    final duration = DateTime.now().difference(startedAt).inSeconds;
    AppLogger().log('QuestService: Dauer der aktiven Quest für User ${user.uid}: $duration Sekunden');
    return duration;
  } else {
    AppLogger().log('QuestService: Fehler beim Laden der Startzeit der aktiven Quest für User ${user.uid} - Status: ${response.statusCode}');
    throw Exception('Fehler beim Laden der Startzeit der aktiven Quest: ${response.statusCode}');
  }
  } 

  Future<void> updateActiveQuestStepCount(User user, int steps) async{
    AppLogger().log('QuestService: updateActiveQuestStepCount() für User ${user.uid} - Neue Schrittanzahl: $steps');
    final Map<String, dynamic> stepCount = {
      'steps': steps,
    };
    final response = await api.put('activequest/${user.uid}/stepcount', stepCount);
    if (response.statusCode != 200) {
      AppLogger().log('QuestService: Fehler beim Aktualisieren der Schrittanzahl - Status: ${response.statusCode}');
      throw Exception('Fehler beim Aktualisieren der Schrittanzahl der aktiven Quest: ${response.statusCode}');
    }
    AppLogger().log('QuestService: Schrittanzahl der aktiven Quest erfolgreich aktualisiert');
  }
  Future<int> getActiveQuestStepCount(User user) async {
    AppLogger().log('QuestService: getActiveQuestStepCount() für User ${user.uid}');
    final response = await api.get('activequest/${user.uid}/stepcount');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final steps = jsonResponse['steps'];
      AppLogger().log('QuestService: Aktuelle Schrittanzahl der aktiven Quest für User ${user.uid}: $steps');
      return steps;
    } 
    AppLogger().log('QuestService: Keine Schrittanzahl gefunden, Rückgabe von 0');
    return 0;
  }

  
}