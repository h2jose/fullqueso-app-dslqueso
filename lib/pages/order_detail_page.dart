import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/checkout/checkout.dart';
import 'package:ubiiqueso/components/checkout/checkout_tile_product.dart';
import 'package:ubiiqueso/components/common/common.dart';
import 'package:ubiiqueso/components/lastorders/lastorders.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/services/order_service.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/utils/constants.dart';

class OrderDetailPage extends StatefulWidget {
  final String id;
  final String ticket;
  const OrderDetailPage({super.key, required this.id, required this.ticket});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
    OrderModel? order;
  List<Cart>? cart = [];
  String? products;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    getOrder(widget.id).then((value) {
      order = value;
      // order!.cart!.forEach((element) => debugPrint(element.toString()),);
      cart = (order?.cart)
          ?.map((item) => Cart.fromJson(item as Map<String, dynamic>))
          .toList();
    }).onError((error, _) {
      debugPrint("error ${error.toString()}");
      if (mounted) {
        ShowAlert(
            context, "Ha ocurrido un error con el Número de Ticket", 'error');
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoaded = true;
          debugPrint(cart!.length.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBarDefaultWidget(
        text: "ORDEN ${widget.ticket}",
        isBack: true,
      ),
      body: isLoaded
          ? ListView.builder(
              itemCount: cart?.length ?? 0,
              itemBuilder: (context, index) {
                final product = cart?[index];
                List<Object> subProducts = product?.additionals ?? [];
                final Customer? customer = order?.customer;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    LastCardCustomerWidget(customer: customer!),
                    const SizedBox(height: 4),
                    LastCardProductsWidget(
                      subProducts: subProducts,
                      product: product!,
                      order: order!
                    ),
                    const SizedBox(height: 4),
                    LastCardPagoWidget(order: order!),
                  ],
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }



}
