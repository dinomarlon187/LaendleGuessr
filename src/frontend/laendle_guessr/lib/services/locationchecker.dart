import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:laendle_guessr/manager/usermanager.dart';

class LocationChecker {
  static final LocationChecker _instance = LocationChecker._internal();
  factory LocationChecker() => _instance;
  LocationChecker._internal();

  static LocationChecker get instance => _instance;

  StreamSubscription<Position>? _positionStream;

  final UserManager userManager = UserManager.instance;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  Future<bool> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> startListening(Function(Position) onUpdate) async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      return;
    }

    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
          (Position position) {
        onUpdate(position);
      },
    );
  }

  void stopListening() {
    _positionStream?.cancel();
    _positionStream = null;
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
  if (distanceInMeters <= 10) {
    return true;
  } else {
    return false;
  }
    

  }
}
