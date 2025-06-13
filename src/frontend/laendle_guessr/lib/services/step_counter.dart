import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';



class StepCounter extends ChangeNotifier {
  StepCounter._internal();
  static final StepCounter _instance = StepCounter._internal();
  factory StepCounter() => _instance;
  static StepCounter get instance => _instance;

  late Stream<StepCount> _stepCountStream;
  int _totalSteps = 0;
  int get totalSteps => _totalSteps;
  
  void onStepCount(StepCount event){
    _totalSteps = event.steps;
    notifyListeners();
  }

  void onStepCountError(error) {}

  Future<void> startStepCounting() async {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount, onError: onStepCountError);
  }

  Future<void> stopStepCounting() async {
    // KI: "how to stop the step counter stream?"
    await _stepCountStream.drain();
    _totalSteps = 0;
    notifyListeners();
  }
}