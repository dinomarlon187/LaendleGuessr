import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:laendle_guessr/services/quest_service.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounter extends ChangeNotifier {
  StepCounter._internal();
  static final StepCounter _instance = StepCounter._internal();
  factory StepCounter() => _instance;
  static StepCounter get instance => _instance;

  late Stream<StepCount> _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;

  int _totalSteps = 0;
  int get totalSteps => _totalSteps;

  int _initialPedometerValue = 0;
  int _dbStepCount = 0;

  static const String _pedometerValueKey = 'initialPedometerValue';

  void onStepCount(StepCount event) {
    if (_initialPedometerValue == 0) {
      _initialPedometerValue = event.steps;
      _saveInitialPedometerValue(_initialPedometerValue);
    }
    _totalSteps = _dbStepCount + (event.steps - _initialPedometerValue);
    notifyListeners();
  }

  void onStepCountError(error) {
    debugPrint('Step Count Error: $error');
  }

  Future<void> startStepCounting() async {
    
    _dbStepCount = await QuestService.instance.getActiveQuestStepCount(UserManager.instance.currentUser!);
    _initialPedometerValue = await _loadInitialPedometerValue();

    _stepCountStream = Pedometer.stepCountStream; 
    _stepCountSubscription = _stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
      cancelOnError: false,
    );
  }

  Future<void> stopStepCounting() async {
    await _stepCountSubscription?.cancel();
    QuestService.instance.updateActiveQuestStepCount(UserManager.instance.currentUser!, _totalSteps);

    _stepCountSubscription = null;
    _totalSteps = 0;
    _initialPedometerValue = 0;
    _dbStepCount = 0;
    await _clearInitialPedometerValue();
    notifyListeners();  
  }

  Future<void> _saveInitialPedometerValue(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('initialPedometerValue', value);
  }
  Future<int> _loadInitialPedometerValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('initialPedometerValue') ?? 0;
  }
  Future<void> _clearInitialPedometerValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('initialPedometerValue');
  }
}
