import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';


class QuestManager{
  late Quest weeklyQuest;
  late Map<City, List<Quest>> dailyQuestsByCity;

  Future<void> loadQuests() async {
    
  }

  List<Quest> getDailyQuestsForUser(User user) {
    return dailyQuestsByCity[user.city] ?? [];
  }

  Quest getWeeklyQuest() => weeklyQuest;
}