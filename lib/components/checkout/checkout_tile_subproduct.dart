import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/checkout/checkout_image_product.dart';
import 'package:ubiiqueso/services/shared_service.dart';

class CheckoutTileSubproduct extends StatelessWidget {
  final String subProduct;
  final String imagePath;
  final double price;
  const CheckoutTileSubproduct({super.key, required this.subProduct, required this.imagePath, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 6, right: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (SharedService.showImage)
          CheckoutImageProduct(imagePath: imagePath),
          const SizedBox(width: 4.0),
          Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subProduct.split(' | ').first,
                textScaler: const TextScaler.linear(1),
                style: const TextStyle(color: Colors.white, height: 0.80),
              ),
              // Solo mostrar precio si no es 0 (para sabores no mostrar precio)
              if (price > 0) ...[
                const SizedBox(height: 4.0),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  textScaler: const TextScaler.linear(0.9),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
          ),
          // Solo mostrar total si el precio no es 0 (para sabores no mostrar total)
          if (price > 0) ...[
            const SizedBox(width: 8.0),
            Text(
            '\$${(price * int.parse(subProduct.split(' ').first)).toStringAsFixed(2)}',
            textScaler: const TextScaler.linear(1.2),
            style: const TextStyle(color: Colors.white),
            ),
          ],
        ],
        ),
      ),
    );
  }
}