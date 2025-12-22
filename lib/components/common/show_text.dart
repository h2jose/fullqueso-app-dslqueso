import 'package:flutter/material.dart';

class ShowText extends StatelessWidget {
  final String text;
  final Color color;

  const ShowText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(text, textScaler: TextScaler.linear(1.3), style: TextStyle(color: color, fontWeight: FontWeight.w700),)
      ),
    );
  }
}
