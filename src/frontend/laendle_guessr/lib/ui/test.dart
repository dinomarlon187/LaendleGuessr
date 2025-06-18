import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laendle_guessr/services/locationchecker.dart'; // Adjust the import as needed
import 'package:laendle_guessr/services/logger.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationText = "Waiting for location...";
  final LocationChecker _locationChecker = LocationChecker();

  @override
  void initState() {
    super.initState();
    AppLogger().log('LocationScreen: initState() aufgerufen');
    AppLogger().log('LocationScreen: Starte Location Listening');
    _locationChecker.startListening((Position position) {
      AppLogger().log('LocationScreen: Neue Position erhalten: ${position.latitude}, ${position.longitude}');
      setState(() {
        _locationText = "📍 ${position.latitude}, ${position.longitude}";
      });
    });
  }

  @override
  void dispose() {
    AppLogger().log('LocationScreen: dispose() aufgerufen');
    _locationChecker.stopListening();
    AppLogger().log('LocationScreen: Location Listening gestoppt');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger().log('LocationScreen: build() aufgerufen');
    return Scaffold(
      appBar: AppBar(title: const Text("Live Location")),
      body: Center(
        child: Text(
          _locationText,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}