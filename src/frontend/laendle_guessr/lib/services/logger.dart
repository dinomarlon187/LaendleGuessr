import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Logger für die App.
///
/// Diese Klasse stellt Logging-Funktionen bereit, um Nachrichten sowohl in der Konsole
/// als auch in einer Logdatei zu protokollieren.
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  IOSink? _sink;

  Future<void> init() async {
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/app.log');
      _sink = file.openWrite(mode: FileMode.append);
    }
  }

  void log(String message) {
    final logMsg = '[${DateTime.now().toIso8601String()}] $message';
    debugPrint(logMsg);
    _sink?.writeln(logMsg);
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
