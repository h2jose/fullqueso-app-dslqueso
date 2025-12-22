import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/lastorders/lastorders.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/theme/color.dart';

class LastCardProductsWidget extends StatelessWidget {
  final List<Object> subProducts;
  final Cart product;
  final OrderModel order;

  const LastCardProductsWidget({super.key, required this.subProducts, required this.product, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.dark,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            'DETALLE DEL PEDIDO \nEstatus: ${order.active! ? 'ACTIVO' : 'CANCELADO'}',
            textAlign: TextAlign.center,
            style: TextStyle(
            color: AppColor.light,
            fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          if (subProducts.isEmpty)
            LastProductDetailWidget(product: product),
          for (var subProduct in subProducts)
            Text(subProduct.toString()),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Tasa BCV: Bs ${order!.rate.toString()}", style: TextStyle(color: AppColor.light),),
              const Spacer(),
              LastTotalToPay(totalToPay: order!.totalPaid!.toDouble(), rate: order!.rate!.toDouble())
              // Container(
              //   child: CheckoutTotalToPay(
              //     totalToPay: order!.totalToPay!.toDouble(),
              //     totalToPayBs: order!.totalToPay!.toDouble() * order!.rate!
              //   ),
              // ),
            ],
          )
        ],
      ),
      ),
    );
  }
}