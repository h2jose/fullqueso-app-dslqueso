import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/order.dart';
import 'package:ubiiqueso/theme/color.dart';

class LastCardCustomerWidget extends StatelessWidget {
  final Customer customer;
  const LastCardCustomerWidget({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColor.dark,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Text(
            'DATOS DEL CLIENTE',
            textAlign: TextAlign.center,
            style: TextStyle(
            color: AppColor.light,
            fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${customer.tipo ?? ''}-${customer.cedula ?? ''} ${customer.name ?? ''}',
            softWrap: true,
            style: TextStyle(color: AppColor.light, height: 0.9),
          ),
          const SizedBox(height: 5),
          Text(
            '${customer.prefix ?? ''}-${customer.cel ?? ''}',
            style: TextStyle(color: AppColor.light, height: 0.9),
          ),
          ],
        ),
        ),
      ),
    );
  }
}