
import 'package:flutter/material.dart';
import 'package:ubiiqueso/utils/format_general.dart';

class CheckoutQuantityProduct extends StatelessWidget {
  final int quantity;
  final String name;
  const CheckoutQuantityProduct({super.key, required this.quantity, required this.name});

  @override
  Widget build(BuildContext context) {
    return  Text("$quantity x ${formatProduct(name)}",
        textScaler: const TextScaler.linear(1.1),
        softWrap: true,
        style: const TextStyle(
          color: Colors.white,
          height: 0.90,
        )
        );
  }
}