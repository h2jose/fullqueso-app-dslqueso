import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ubiiqueso/theme/color.dart';

class ShowSpin extends StatelessWidget {
  const ShowSpin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: const SpinKitWave(
        color: AppColor.secondary,
        size: 80.0,
      ),
    );
  }
}