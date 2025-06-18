import 'package:flutter/material.dart';

Future<String?> showIpInputDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('API nicht erreichbar'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Bitte IP-Adresse eingeben',
        ),
        keyboardType: TextInputType.url,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
