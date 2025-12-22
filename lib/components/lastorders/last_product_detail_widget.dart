import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/checkout/checkout.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/theme/color.dart';

class LastProductDetailWidget extends StatelessWidget {
  final Cart? product;

  const LastProductDetailWidget({super.key, required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: CheckoutQuantityProduct(
                    quantity: product!.quantity!,
                    name: product!.name!,
                  ),
                ),
                CheckoutPriceProduct(price: product!.price!),
              ],
            ),
            const SizedBox(width: 4,),
            const Spacer(),
            CheckoutTotalProduct(
              price: product!.price!,
              quantity: product!.quantity!,
            ),
          ],
        ),
        Divider(
          color: AppColor.background,
        )
      ],
    );
  }
}