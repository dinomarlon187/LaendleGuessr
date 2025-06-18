import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/services/logger.dart';

class LocationChecker {
  static final LocationChecker _instance = LocationChecker._internal();
  factory LocationChecker() {
    AppLogger().log('LocationChecker instanziiert');
    return _instance;
  }
  LocationChecker._internal();

  static LocationChecker get instance => _instance;

  StreamSubscription<Position>? _positionStream;

  final UserManager userManager = UserManager.instance;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  Future<bool> checkPermission() async {
    AppLogger().log('LocationChecker: checkPermission() aufgerufen');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger().log('LocationChecker: Standortdienste sind nicht aktiviert');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      AppLogger().log('LocationChecker: Standortberechtigung verweigert, fordere an');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger().log('LocationChecker: Standortberechtigung erneut verweigert');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger().log('LocationChecker: Standortberechtigung dauerhaft verweigert');
      return false;
    }
    AppLogger().log('LocationChecker: Standortberechtigung erteilt');
    return true;
  }

  Future<void> startListening(Function(Position) onUpdate) async {
    AppLogger().log('LocationChecker: startListening() aufgerufen');
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      AppLogger().log('LocationChecker: Keine Berechtigung, Listening abgebrochen');
      return;
    }

    AppLogger().log('LocationChecker: Starte Position Stream');
    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
          (Position position) {
        AppLogger().log('LocationChecker: Position Update: ${position.latitude}, ${position.longitude}');
        onUpdate(position);
      },
    );
  }

  void stopListening() {
    AppLogger().log('LocationChecker: stopListening() aufgerufen');
    _positionStream?.cancel();
    _positionStream = null;
    AppLogger().log('LocationChecker: Position Stream gestoppt');
  }

  Future<bool?> checkLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      return null;
    }
    Position _current = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double distanceInMeters = Geolocator.distanceBetween(
    _current.latitude,
    _current.longitude,
    userManager.currentUser!.activeQuest!.latitude,
    userManager.currentUser!.activeQuest!.longitude,
  );
  if (distanceInMeters <= 100000000000000) {
    return true;
  } else {
    return false;
  }
    

  }
}
