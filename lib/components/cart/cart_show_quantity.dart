import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/models.dart';

class CartShowQuantity extends StatelessWidget {
  final ProductModel product;
  const CartShowQuantity({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        '${product.quantity}',
        textScaler: product.quantity > 0
            ? const TextScaler.linear(1.5)
            : const TextScaler.linear(1.3),
        style: TextStyle(
            color: product.quantity > 0 ? Colors.black : Colors.white,
            fontWeight:
                product.quantity > 0 ? FontWeight.w800 : FontWeight.w400),
      ),
    );
  }
}