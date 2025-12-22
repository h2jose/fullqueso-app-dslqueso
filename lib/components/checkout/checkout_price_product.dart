import 'package:flutter/material.dart';

class CheckoutPriceProduct extends StatelessWidget {
  final double price;
  const CheckoutPriceProduct({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Text('\$${price.toStringAsFixed(2)}',
        textScaler: const TextScaler.linear(0.9),
        style: const TextStyle(color: Colors.white));
  }
}