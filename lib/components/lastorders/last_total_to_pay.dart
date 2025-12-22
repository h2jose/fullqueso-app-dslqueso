import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ubiiqueso/theme/color.dart';

class LastTotalToPay extends StatelessWidget {
  final double totalToPay;
  final double rate;
  const LastTotalToPay({super.key, required this.totalToPay, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Total: \$${totalToPay.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1.1),
            ),
            Text(
              'Bs ${NumberFormat.currency(locale: 'en_US', symbol: '').format(totalToPay * rate)}',
              style: const TextStyle(
                  color: AppColor.accent, fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1.1),
            ),
          ],
        )
      ],
    );
  }
}