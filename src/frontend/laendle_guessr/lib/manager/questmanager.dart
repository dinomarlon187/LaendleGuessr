import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:laendle_guessr/services/quest_service.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:flutter/material.dart';
import 'package:laendle_guessr/services/step_counter.dart';


class QuestManager extends ChangeNotifier{
  QuestManager._internal(this.questService);
  static final QuestManager _instance = QuestManager._internal(QuestService.instance);
  factory QuestManager() => _instance;
  static QuestManager get instance => _instance;
  final UserManager userManager = UserManager.instance;

  late Quest weeklyQuest;
  Map<City, Quest> dailyQuestByCity = {};
  Timer? _midnightTimer;
  Duration? _timeUntilMidnight;
  final ValueNotifier<Duration> timeUntilMidnightNotifier = ValueNotifier(Duration.zero);
  final QuestService questService;

  Timer? questTimer;
  int elapsedSeconds = 0;
    // KI: "how to format elapsed time in HH:MM:SS format so i can use it in my ui?"
  String get elapsedTime {
    final hours = (elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> loadQuests() async {
    // Load Daily Quests:
    //Funktioniert, wenn die Datenbank gefüllt ist, ansonsten gibt es einen Fehler
    dailyQuestByCity.clear();
    dailyQuestByCity[City.bregenz] = await questService.getdailyQuest(City.bregenz);
    //dailyQuestByCity[City.dornbirn] = await questService.getdailyQuest(City.dornbirn);
    //dailyQuestByCity[City.hohenems] = await questService.getdailyQuest(City.hohenems);
    //dailyQuestByCity[City.feldkirch] = await questService.getdailyQuest(City.feldkirch);
    //dailyQuestByCity[City.bludenz] = await questService.getdailyQuest(City.bludenz);
    weeklyQuest = await questService.getweeklyQuest();
    // Known issue: If the user has last days daily quest as a weekly quest now, it will not be updated.
    if (userManager.currentUser!.activeQuest != weeklyQuest && userManager.currentUser!.activeQuest != getDailyQuestForUser() && userManager.currentUser!.activeQuest != null) {
      await questService.removeQuestFromActive(userManager.currentUser!);
      userManager.currentUser!.activeQuest = null;
    }
    await fetchActiveQuest();
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
    questTimer?.cancel();
    timeUntilMidnightNotifier.dispose();
    StepCounter.instance.startStepCounting();
    super.dispose();
  }

  Quest? getDailyQuestForUser() {
    return dailyQuestByCity[userManager.currentUser!.city];
  }



  Quest getWeeklyQuest() => weeklyQuest;

  Future<List<Quest>> getAllQuests() async {
    return await questService.getAllQuests();
  }
  Future<List<Quest>> getAllDoneQuestsByUser(User user) async {
    return await questService.getAllDoneQuestsByUser(user);
  }
  Future<void> fetchActiveQuest() async {
    userManager.currentUser!.activeQuest = await questService.getActiveQuestForUser(userManager.currentUser!);
  }

  bool get isRunning => questTimer?.isActive ?? false;

  Future<void> startQuest(qid) async {
    notifyListeners();
    userManager.currentUser!.activeQuest = await questService.getQuestById(qid);
    await questService.addQuestToActive(userManager.currentUser!,qid);
  }

  Future<void> startTracking() async{
    if (userManager.currentUser!.activeQuest == null){
      return;
    }
    elapsedSeconds = await questService.getActiveQuestDuration(userManager.currentUser!);
    startQuestTimer();
    StepCounter.instance.startStepCounting();
  }

  void startQuestTimer() {
    questTimer?.cancel();
    questTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void forfeitQuest() async {
    questTimer?.cancel();
    notifyListeners();
    await questService.removeQuestFromActive(userManager.currentUser!);
    userManager.currentUser!.activeQuest = null;
  }

  void finishQuest() async{
    await questService.postQuestDoneByUser(userManager.currentUser!.activeQuest!.qid, userManager.currentUser!.uid);
    await questService.removeQuestFromActive(userManager.currentUser!);
    userManager.currentUser!.activeQuest = null;
    questTimer?.cancel();
    StepCounter.instance.stopStepCounting();
    notifyListeners();
  }
}