import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laendle_guessr/services/locationchecker.dart'; // Adjust the import as needed

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
    _locationChecker.startListening((Position position) {
      setState(() {
        _locationText = "📍 ${position.latitude}, ${position.longitude}";
      });
    });
  }

  @override
  void dispose() {
    _locationChecker.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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