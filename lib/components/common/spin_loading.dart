import 'package:ubiiqueso/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinLoading extends StatelessWidget {
  SpinLoading({Key? key, required this.text, required this.size})
      : super(key: key);

  String text;
  double size;

  @override
  Widget build(BuildContext context) {
    final spinkit = SpinKitWave(
      color: AppColor.primary,
      size: size,
    );
    return Column(
      children: [
        spinkit,
        Text(
          text,
          style: const TextStyle(color: AppColor.primary),
        )
      ],
    );
  }
}
