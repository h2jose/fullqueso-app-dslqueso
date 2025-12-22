import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/checkout/checkout.dart';
import 'package:ubiiqueso/services/shared_service.dart';

class CheckoutTileProduct extends StatelessWidget {
  final String imagePath;
  final String productName;
  final double productPrice;
  final int productQuantity;
  const CheckoutTileProduct({super.key, required this.imagePath, required this.productName, required this.productPrice, required this.productQuantity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (SharedService.showImage)
          // CheckoutImageProduct(
          //   imagePath: imagePath,
          // ),
          const SizedBox(width: 4),
          Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            CheckoutQuantityProduct(
              quantity: productQuantity,
              name: productName,
            ),
            const SizedBox(height: 4),
            CheckoutPriceProduct(price: productPrice),
            ],
          ),
          ),
          CheckoutTotalProduct(
          price: productPrice,
          quantity: productQuantity,
          ),
        ],
        ),
      ),
    );
  }
}

/* ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: SharedService.showImage ? CheckoutImageProduct(
        imagePath: imagePath,
      ) : null,
      title: CheckoutQuantityProduct(
          quantity: productQuantity, name: productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckoutPriceProduct(price: productPrice),
        ],
      ),
      trailing: CheckoutTotalProduct(
        price: productPrice,
        quantity: productQuantity,
      ),
    ) */