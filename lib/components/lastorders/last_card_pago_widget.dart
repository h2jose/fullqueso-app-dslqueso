import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/theme/color.dart';

class LastCardPagoWidget extends StatelessWidget {
  final OrderModel order;
  const LastCardPagoWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return   SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColor.dark,
        margin: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'DETALLE DEL PAGO',
                textAlign: TextAlign.center,
                style: TextStyle(  color: AppColor.light,  fontWeight: FontWeight.w600,  ),
              ),
            ),
            const SizedBox(height: 15),


            if (order.paidPuntoUsd != null && (order.paidPuntoUsd ?? 0) > 0) ...[
              const SizedBox(height: 10),
              Text(
                "Punto",
                style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.light,),
              ),
              Text("Monto (USD): \$${order.paidPuntoUsd?.toStringAsFixed(2) ?? 0}",  style: TextStyle(color: AppColor.light,),),
              Text("Monto (Bs): ${order.paidPuntoBs?.toStringAsFixed(2) ?? 0} Bs",  style: TextStyle(color: AppColor.light,),),
              Divider(color: AppColor.background,)
            ],
            if (order!.paidZelle! > 0) ...[
              SizedBox(
                height: 5,
                child: Text(
                "Zelle",
                style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.light,),
                ),
              ),
              Text("Monto: \$${order.paidZelle!.toStringAsFixed(2) ?? 0}", style: TextStyle(color: AppColor.light,)),
              Text("Referencia: ${order.paidZelleVaucher ?? 'S/N'}", style: TextStyle(color: AppColor.light,)),
              Divider(color: AppColor.background,)
            ],
            if (order!.paidMovilUsd! > 0) ...[
              const SizedBox(height: 5),
              Text("Pago Móvil",
                style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.light,),
              ),
              Text("Monto (USD): \$${order.paidMovilUsd?.toStringAsFixed(2) ?? 0}",  style: TextStyle(color: AppColor.light,),),
              Text("Monto (Bs): ${order.paidMovilBs?.toStringAsFixed(2) ?? 0} Bs",   style: TextStyle(color: AppColor.light,),),
              Text("Referencia: ${order.paidMovilVaucher ?? 'S/N'}",   style: TextStyle(color: AppColor.light,),),
              Divider(color: AppColor.background,)
            ],
          ],
        ),
        ),
      ),
    );
  }
}