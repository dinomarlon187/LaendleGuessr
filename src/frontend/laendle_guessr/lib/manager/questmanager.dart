import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:laendle_guessr/services/quest_service.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:flutter/material.dart';


class QuestManager extends ChangeNotifier{
  QuestManager._internal(this.questService);
  static final QuestManager _instance = QuestManager._internal(QuestService.instance);
  factory QuestManager() => _instance;
  static QuestManager get instance => _instance;


  late Quest weeklyQuest;
  Map<City, Quest> dailyQuestByCity = {};
  Timer? _midnightTimer;
  Duration? _timeUntilMidnight;
  final ValueNotifier<Duration> timeUntilMidnightNotifier = ValueNotifier(Duration.zero);
  final QuestService questService;

  Timer? _questTimer;
  int elapsedSeconds = 0;

  Future<void> loadQuests() async {
    // Load Daily Quests:
    //Funktioniert, wenn die Datenbank gefüllt ist, ansonsten gibt es einen Fehler
    dailyQuestByCity.clear();
    dailyQuestByCity[City.bregenz] = await questService.getdailyQuest(City.bregenz);
    dailyQuestByCity[City.dornbirn] = await questService.getdailyQuest(City.dornbirn);
    dailyQuestByCity[City.hohenems] = await questService.getdailyQuest(City.hohenems);
    dailyQuestByCity[City.feldkirch] = await questService.getdailyQuest(City.feldkirch);
    dailyQuestByCity[City.bludenz] = await questService.getdailyQuest(City.bludenz);
    weeklyQuest = await questService.getweeklyQuest();
    _scheduleMidnightUpdate();
  }

  void _scheduleMidnightUpdate(){
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _timeUntilMidnight = durationUntilMidnight;
    timeUntilMidnightNotifier.value = durationUntilMidnight;

    _midnightTimer = Timer(durationUntilMidnight, () async {
      await loadQuests();
    });
  }
  // KI: "do i need anything else to work properly?" (Ich habe ihm davor meinen Code für den Timer gegeben und gefragt pb das so funktioniert)
  void dispose() {
    _midnightTimer?.cancel();
    timeUntilMidnightNotifier.dispose();
  }

  Quest? getDailyQuestForUser(User user) {
    return dailyQuestByCity[user.city];
  }



  Quest getWeeklyQuest() => weeklyQuest;

  Future<List<Quest>> getAllQuests() async {
    return await questService.getAllQuests();
  }
  Future<List<Quest>> getAllDoneQuestsByUser(User user) async {
    return await questService.getAllDoneQuestsByUser(user);
  }

  bool get isRunning => _questTimer?.isActive ?? false;
  void startQuest(){
    elapsedSeconds = 0;
    _questTimer?.cancel();

    _questTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      notifyListeners();
    });
  }
}