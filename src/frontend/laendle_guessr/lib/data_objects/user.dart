import 'package:laendle_guessr/data_objects/account.dart';
import 'package:laendle_guessr/manager/inventory.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/quest.dart';

class User extends Account{
  int coins;
  Inventory inventory = Inventory();
  City city;
  Quest? activeQuest;

  User({
    required super.uid,
    required super.username,
    required this.city,
    required this.coins,
  })  : super(isAdmin: false);
}