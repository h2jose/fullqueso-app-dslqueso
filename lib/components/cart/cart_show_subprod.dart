import 'package:flutter/widgets.dart';
import 'package:ubiiqueso/models/product.dart';

class CartShowSubprod extends StatelessWidget {
  final ProductModel product;
  const CartShowSubprod({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.additional != null && product.additional!.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: product.additional!
              .split(', ')
              .map((item) => Text(
                    item.split(' | ').first,
                    textScaler: const TextScaler.linear(0.85),
                  ))
              .toList(),
        )
      : const SizedBox.shrink();
  }
}