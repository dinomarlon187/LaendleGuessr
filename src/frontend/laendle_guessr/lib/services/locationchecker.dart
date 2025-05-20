class LocationChecker {
  static final LocationChecker _instance = LocationChecker._internal(); //erstellt eine Instanz von LocationChecker sobald die Klasse geladen wird

  factory LocationChecker() {
    return _instance; // gibt immer die gleicht Instanz zurück
  }

  LocationChecker._internal(); // privater Konstruktor, so kann die Klasse nicht von außen instanziiert werden


}