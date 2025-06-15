import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00BFFF);

InputDecoration customInputDecoration(String label) {
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
  return ElevatedButton.styleFrom(
    backgroundColor: bgColor ?? kPrimaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
