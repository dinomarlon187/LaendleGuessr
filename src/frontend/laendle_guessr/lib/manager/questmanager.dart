import 'package:laendle_guessr/services/database.dart';

class QuestManager{
  static final QuestManager _instance = QuestManager._internal();
  factory QuestManager(){
    return _instance;
  }
  QuestManager._internal();
}