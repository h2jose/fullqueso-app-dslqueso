import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/product.dart';

class CartShowTotal extends StatelessWidget {
  final ProductModel product;
  const CartShowTotal({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.quantity > 0 ? Text(
      'x ${product.quantity}: \$${(product.price! * product.quantity).toStringAsFixed(2)}',
      textScaler: const TextScaler.linear(1),
      style: TextStyle(
          color: product.quantity > 0 ? Colors.black : Colors.white,
          fontWeight: product.quantity > 0 ? FontWeight.w800 : FontWeight.w400),
    ) : Container();
  }
}