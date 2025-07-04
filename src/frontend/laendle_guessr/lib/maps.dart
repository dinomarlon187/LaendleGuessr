import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/services/step_counter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:laendle_guessr/services/logger.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with AutomaticKeepAliveClientMixin {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  final UserManager _userManager = UserManager.instance;
  final LocationChecker locationChecker = LocationChecker();
  final QuestManager _questManager = QuestManager.instance;

  double _currentZoom = 17.0;
  bool _isMapReady = false;
  bool _isButtonPressed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    AppLogger().log('MapsPage geladen');
    AppLogger().log('MapsPage: Starte Berechtigungsprüfung und Tracking');
    _checkPermissionsAndStartTracking();
    AppLogger().log('MapsPage: Starte QuestManager Tracking');
    _questManager.startTracking();
  }

  Future<void> _checkPermissionsAndStartTracking() async {
    AppLogger().log('MapsPage: Prüfe Standortdienste');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      AppLogger().log('MapsPage: Standortdienste sind deaktiviert');
      _showError("Standortdienste sind deaktiviert.");
      return;
    }
    AppLogger().log('MapsPage: Standortdienste sind aktiviert');

    AppLogger().log('MapsPage: Fordere Standortberechtigung an');
    var status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      AppLogger().log('MapsPage: Standortberechtigung verweigert');
      _showError("Standortberechtigung verweigert.");
      return;
    }
    AppLogger().log('MapsPage: Standortberechtigung erteilt');

    LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.deniedForever) {
      AppLogger().log('MapsPage: Standortberechtigung dauerhaft verweigert');
      _showError("Standortberechtigung dauerhaft verweigert, bitte in den App-Einstellungen aktivieren.");
      return;
    }

    AppLogger().log('MapsPage: Starte Position Stream');
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted) return;
      AppLogger().log('MapsPage: Neue Position erhalten: ${position.latitude}, ${position.longitude}');
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newLocation;
      });
      if (_isMapReady) {
        AppLogger().log('MapsPage: Bewege Karte zur neuen Position');
        _mapController.move(newLocation, _currentZoom);
      }
    }, onError: (error) {
      AppLogger().log('MapsPage: Fehler bei Position Stream: $error');
      if (mounted) {
        _showError("Fehler beim Empfangen des Standorts: $error");
      }
    });
  }

  void _showError(String message) {
    if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    StepCounter.instance.stopStepCounting();
    _questManager.questTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: _currentZoom,
              maxZoom: 19,
              minZoom: 5,
              onMapReady: () {
                if (!mounted) return;
                _isMapReady = true;
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, _currentZoom);
                }
              },
              onPositionChanged: (MapPosition pos, bool hasGesture) {
                if (pos.zoom != null && mounted) {
                  _currentZoom = pos.zoom!;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.laendle_guessr',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_currentLocation == null && !_isMapReady)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _userManager.currentUser?.activeQuest != null
                ? _buildActiveQuestBar()
                : _buildInactiveQuestBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveQuestBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoBox(
              icon: Icons.timer,
              label: 'Zeit',
              valueBuilder: () => QuestManager.instance.elapsedTime,
              listenable: QuestManager.instance,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoBox(
              icon: Icons.directions_walk,
              label: 'Schritte',
              valueBuilder: () => StepCounter.instance.totalSteps.toString(),
              listenable: StepCounter.instance,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isButtonPressed = true;
              });
            },
            onTapUp: (_) async {
            setState(() {
              _isButtonPressed = false;
            });
            final result = await locationChecker.checkLocation();
            if (!mounted) return;
            if (result == true) {
              await _questManager.finishQuest();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quest erfolgreich abgeschlossen!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Du bist nicht am Zielort!')),
              );
            }
          },
            child: AnimatedScale(
              scale: _isButtonPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Prüfen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
  required IconData icon,
  required String label,
  required String Function() valueBuilder,
  Listenable? listenable,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: listenable ?? QuestManager.instance,
          builder: (context, _) {
            return Text(
              valueBuilder(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

  Widget _buildInactiveQuestBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Keine aktive Quest',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
