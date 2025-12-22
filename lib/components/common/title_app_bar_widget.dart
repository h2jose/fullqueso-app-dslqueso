import 'package:flutter/material.dart';
import 'package:ubiiqueso/services/shared_service.dart';

class TitleAppBarWidget extends StatelessWidget {
  const TitleAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          SharedService.shopName,
          textScaler: const TextScaler.linear(0.9),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        Text(
          SharedService.operatorName,
          textScaler: const TextScaler.linear(0.5),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}