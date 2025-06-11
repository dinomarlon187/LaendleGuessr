import 'dart:convert';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/api_service.dart';

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
      return jsonList.map((jsonItem) => Quest.fromJson(jsonItem)).toList();
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

  Future postQuestDoneByUser(int qid, int uid) async {
    final json = {
      'id' : qid,
      'uid': uid
    };
    final response = await api.post('quest_user', json);
    if (response.statusCode != 200){
      throw Exception('Fehler beim zuweisen eienr Quest zu einem User: ${response.statusCode}');
    }
  }
}