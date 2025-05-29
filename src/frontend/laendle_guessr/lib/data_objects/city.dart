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
}