class DataBase {
  static final DataBase _instance = DataBase._internal();
  factory DataBase(){
    return _instance;
  }
  DataBase._internal();
}