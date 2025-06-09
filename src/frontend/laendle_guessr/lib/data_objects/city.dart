enum City{
  bregenz,
  dornbirn,
  hohenems,
  feldkirch,
  bludenz
}

extension CityExtension on City{
  int get id{
     switch (this){
      case City.bregenz:
        return 0;
      case City.dornbirn:
        return 1;
      case City.hohenems:
        return 2;
      case City.feldkirch:
        return 3;
      case City.bludenz:
        return 4;
    }
  }
  static City fromId(int id) {
    switch (id) {
      case 0:
        return City.bregenz;
      case 1:
        return City.dornbirn;
      case 2:
        return City.hohenems;
      case 3:
        return City.feldkirch;
      case 4:
        return City.bludenz;
      default:
        throw Exception('Invalid City ID: $id');
    }
  }
}