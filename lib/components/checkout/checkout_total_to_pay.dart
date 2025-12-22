import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ubiiqueso/theme/color.dart';

class CheckoutTotalToPay extends StatelessWidget {
  final double totalToPay;
  final double totalToPayBs;
  final double rate;
  const CheckoutTotalToPay({super.key, required this.totalToPay, required this.totalToPayBs, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: \$${totalToPay.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textScaler: const TextScaler.linear(1.3),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasa Bcv ${rate.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                ),
                textScaler: const TextScaler.linear(1),
              ),
              Text(
                'Bs ${NumberFormat.currency(locale: 'en_US', symbol: '').format(totalToPayBs)}',
                style: const TextStyle(
                    color: AppColor.accent, fontWeight: FontWeight.bold),
                textScaler: const TextScaler.linear(1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}