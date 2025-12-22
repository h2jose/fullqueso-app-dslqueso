import 'package:flutter/material.dart';

class CheckoutTotalProduct extends StatelessWidget {
  final double price;
  final int quantity;
  const CheckoutTotalProduct({super.key, required this.price, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Text('\$${(price * quantity).toStringAsFixed(2)}',
        textScaler: const TextScaler.linear(1.2),
        style: const TextStyle(color: Colors.white));
  }
}