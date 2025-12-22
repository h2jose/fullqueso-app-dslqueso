
import 'package:flutter/material.dart';
import 'package:ubiiqueso/theme/color.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/favicon.png', width: 150),
          const Text(
            'Conectando...',
            textScaler: TextScaler.linear(1.5),
            style: TextStyle(color: AppColor.secondary),
          ),
        ],
      ),
    );
  }
}
