import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/product.dart';
import 'package:ubiiqueso/utils/format_general.dart';

class CartShowProdName extends StatelessWidget {
  final ProductModel product;
  const CartShowProdName({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatProduct(product.name),
      textScaler: const TextScaler.linear(1.1),
      style: TextStyle(
        height: 0.95,
        color: product.quantity > 0
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}