import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

class StepCounter extends ChangeNotifier {
  StepCounter._internal();
  static final StepCounter _instance = StepCounter._internal();
  factory StepCounter() => _instance;
  static StepCounter get instance => _instance;

  late Stream<StepCount> _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;

  int _totalSteps = 0;
  int get totalSteps => _totalSteps;

  void onStepCount(StepCount event) {
    _totalSteps = event.steps;
    notifyListeners(); 
  }

  void onStepCountError(error) {
    debugPrint('Step Count Error: $error');
  }

  Future<void> startStepCounting() async {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
      cancelOnError: false,
    );
  }

  Future<void> stopStepCounting() async {
    await _stepCountSubscription?.cancel(); // Properly cancel subscription
    _stepCountSubscription = null;
    _totalSteps = 0;
    notifyListeners();  
  }
}
