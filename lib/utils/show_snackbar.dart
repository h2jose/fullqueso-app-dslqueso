import 'package:flutter/material.dart';
import 'package:ubiiqueso/theme/color.dart';

showSnackbar(BuildContext context, String text, String type) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: (type == 'success') ? AppColor.secondary : Colors.red,
  ));
}
