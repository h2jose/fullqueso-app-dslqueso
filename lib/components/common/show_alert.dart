import 'package:flutter/material.dart';

ShowAlert(BuildContext context, String text, String type) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: (type == 'success') ? Colors.green[900] : Colors.red,
    duration: const Duration(seconds: 5),
  ));
}
