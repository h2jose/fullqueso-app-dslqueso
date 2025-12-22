import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/models/order.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<OrderModel> getOrder(String id) async {
  final doc = await db.collection('orders').doc(id).get();
  return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
}

Future<void> updateOrder(String id, Map<String, dynamic> data) async {
  await db.collection('orders').doc(id).update(data);
}


Future copyToClippboard(order, cart) async {
  final header = '''
Ticket Nº ${order?.ticket}
Tienda: ${order?.shopName}
PARA: ${order?.customer?.name}
CEDULA: ${order?.customer?.cedula}
TELÉFONO: ${order?.customer?.phone}
PUNTO DE REFERENCIA: ${order?.customer?.address}
${order?.customer?.location ?? 'No envió ubicación'}
''';
  final myOrder = cart!
      .map((product) =>
          '${product['quantity']} ${product['name']} \$${product['total']}')
      .join('\n');
  String coupon = '';
  if (order?.couponCode != null && order!.couponCode!.isNotEmpty) {
    coupon =
        'Cupón ${order?.couponCode} -\$${order?.couponAmount!.toStringAsFixed(2)}';
  }
  String total = '';
  if (order?.mode == 'delivery') {
    total = '''
Subtotal: \$${order?.totalToPay!.toStringAsFixed(2)}
Delivery: \$${order?.shopDelivery!.toStringAsFixed(2)}
Total: \$${order?.totalToPay!.toStringAsFixed(2)}
''';
  } else {
    total = '''
Subtotal: \$${order?.totalToPay!.toStringAsFixed(2)}
Total a Pagar: \$${order?.totalToPay!.toStringAsFixed(2)}
''';
  }

  String paidMovilBs = '';
  if (order!.paidMovilBs! > 0) {
    paidMovilBs = '''
Pago Móvil
Monto Bs: Bs${order!.paidMovilBs!.toStringAsFixed(2)}
Monto USD: \$${order!.paidMovilUsd!.toStringAsFixed(2)}
Confirmación: ${order?.paidMovilVaucher ?? ''}
....
''';
  }

  String paidEfectivoBs = "";
  if (order!.paidEfectivoBs! > 0) {
    paidEfectivoBs = '''
Efectivo Bs
Recibir Bs: Bs${order!.paidEfectivoBs!.toStringAsFixed(2)}
Entregar Vuelto: \$${order!.paidEfectivoChange!.toStringAsFixed(2)}
....
''';
  }

  String paidZelle = '';
  if (order!.paidZelle! > 0) {
    paidZelle = '''
Pago con Zelle
Monto: \$${order!.paidZelle!.toStringAsFixed(2)}
Confirmación: ${order?.paidZelleVaucher ?? ''}
....
''';
  }

  String paidCash = '';
  if (order!.paidCash! > 0) {
    String paidCashChange = order!.paidCashChange! > 0
        ? 'Entregar Vuelto: \$${order!.paidCashChange!.toStringAsFixed(2)}'
        : 'No requiere cambio';
    paidCash = '''
Efectivo Divisas
Recibir: \$${order!.paidCash!.toStringAsFixed(2)}
Entregar Vuelto: $paidCashChange
....
''';
  }

  await Clipboard.setData(ClipboardData(text: '''
$header
-------------------
PEDIDO
-------------------
$myOrder
-------------------
$coupon
$total
-------------------
FORMA DE PAGO
-------------------
$paidMovilBs
$paidCash
$paidZelle
$paidEfectivoBs
-------------------
MOTORIZADO
${order?.driver ?? 'Sin ASignar'}
'''));
}


Future setIncompleteOrder(CheckoutModel checkout) async {
  String id = checkout.timestamp.toString();
  String myDate = checkout.ticket!.substring(0, 8);
  return await FirebaseDatabase.instance
      .ref()
      .child("incompletes/${checkout.shopId}/$myDate/$id")
      .set(checkout.toJson());
}
