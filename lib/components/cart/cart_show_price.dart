import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/product.dart';

class CartShowPrice extends StatelessWidget {
  final ProductModel product;
  const CartShowPrice({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${product.price!.toStringAsFixed(2)}',
      textScaler: const TextScaler.linear(0.9),
      style: TextStyle(
        color: product.quantity > 0 ? Colors.black : Colors.white,
      ),
    );
  }
}