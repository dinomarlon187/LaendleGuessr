import 'package:flutter/material.dart';
import 'package:laendle_guessr/services/logger.dart';

const kPrimaryColor = Color(0xFF00BFFF);

InputDecoration customInputDecoration(String label) {
  AppLogger().log('ui_components.dart: customInputDecoration verwendet');
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kPrimaryColor),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

ButtonStyle customButtonStyle({Color? bgColor}) {
  AppLogger().log('ui_components.dart: customButtonStyle verwendet');
  return ElevatedButton.styleFrom(
    backgroundColor: bgColor ?? kPrimaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
