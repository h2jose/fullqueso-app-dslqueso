import 'dart:convert';

import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:ubiiqueso/theme/color.dart';

class AppBarCheckoutWidget extends StatelessWidget implements PreferredSize {
  final CheckoutModel checkout;
  const AppBarCheckoutWidget({
    super.key,
    required this.checkout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () async {
          debugPrint("checkout: ${json.encode(checkout.timestamp)}");
          debugPrint("ticket: ${json.encode(checkout.ticket)}");
          await setIncompleteOrder(checkout);
          Navigator.pop(context);
        },
      ),
      title: const Text( 'RESUMEN PEDIDO', style: TextStyle(color: Colors.white),
      ),


    );
  }

  @override
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1);
}
