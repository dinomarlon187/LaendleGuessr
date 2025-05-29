import 'package:laendle_guessr/data_objects/account.dart';
import 'package:laendle_guessr/manager/inventory.dart';
import 'package:laendle_guessr/data_objects/city.dart';

class User extends Account{
  int coins;
  final Inventory inventory;
  City city;

  User({
    required super.uid,
    required super.username,
    required super.password,
    required this.city,
    required this.coins,
    Inventory? inventory,
  })  : inventory = inventory ?? Inventory(),
        super(isAdmin: false);


}