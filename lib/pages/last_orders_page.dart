import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/common/common.dart';
import 'package:ubiiqueso/models/order.dart';
import 'package:ubiiqueso/pages/order_detail_page.dart';
import 'package:ubiiqueso/services/shared_service.dart';

class LastOrdersPage extends StatefulWidget {
  const LastOrdersPage({super.key});

  @override
  State<LastOrdersPage> createState() => _LastOrdersPageState();
}

class _LastOrdersPageState extends State<LastOrdersPage> {


  // .where('mode', isNotEqualTo: 'tienda')
  final Stream<QuerySnapshot> _ordersStream = (() {
    // Obtener la fecha actual en Caracas (-4 UTC)
    final now = DateTime.now().toUtc().add(const Duration(hours: -4));
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfDayUtc = startOfDay.toUtc().add(const Duration(hours: 4)); // Volver a UTC
    final startTimestamp = startOfDayUtc.millisecondsSinceEpoch ~/ 1000; // segundos

    return FirebaseFirestore.instance
        .collection('orders')
        .where('shopId', isEqualTo: SharedService.shopId)
        .where('active', isEqualTo: true)
        .where('mode', isEqualTo: 'tienda')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  })();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBarTextWidget(
        text: "Ultimas 10 Ordenes",
        isBack: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las ordenes'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay ordenes recientes'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return orderCardWidget(data: data);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget orderCardWidget({required Map<String, dynamic> data}) {

    final String status = data['statusCurrent']?.toString() ?? 'Sin Status';
    final String customerName = data['customer']['name'] ?? 'Sin Nombre';
    final String customerCedula = data['customer']['cedula'] ?? 'Sin Cedula';
    final String total = data['total']?.toString() ?? '0';
    final String customerTipo = data['customer']['tipo'] ?? '';
    final String id = data['id'];

    final String paidPuntoUsd = (data['paidPuntoUsd'] ?? 0) > 0 ? data['punto'] ?? 'Punto. ' : '';
    final String paidMovilUsd = (data['paidMovilUsd'] ?? 0) > 0 ? 'PMovil. ' : '';
    final String paidCash = (data['paidCash'] ?? 0) > 0 ? 'Cash USD. ' : '';
    final String paidEfectivoUsd = (data['paidEfectivoUsd'] ?? 0) > 0 ? 'Efvo Bs. ' : '';
    final String paidZelleUsd = (data['paidZelleUsd'] ?? 0) > 0 ? 'Zelle.' : '';
    final String operator = data['operator'] ?? '';

    final ticket = data['ticket'].contains('-') ? data['ticket'].split('-')[1] : data['ticket'];
    final String pagos = '$paidPuntoUsd$paidMovilUsd$paidCash$paidEfectivoUsd$paidZelleUsd';
    final String myCustomer = '$customerTipo$customerCedula, $customerName';
    final timestamp = data['timestamp'];

    final Customer customer = Customer(
      name: customerName,
      cedula: customerCedula,
      tipo: customerTipo,
    );

    return Card(
      color: Colors.black,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 5, right: 16),
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade700,
          child: const Icon(Icons.receipt, color: Colors.white),
        ),
        title: _cardTitle(ticket),
        subtitle: _cardCustomer("$myCustomer\n${pagos.isNotEmpty ? pagos : 'Mostrador'} \n$operator. $status"),
        trailing: _cardMonto(total),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(
                id: id,
                ticket: ticket,
              ),
            ),
          );
        },
      ),
    );
  }

  Text _cardMonto(String value) =>
    Text("\$${(double.tryParse(value) ?? 0.0).toStringAsFixed(2)}",
      textScaler: const TextScaler.linear(1.8),
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    );

  Text _cardCustomer(String value) =>
    Text(value,
      textScaler: const TextScaler.linear(1.0),
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    );

  Text _cardTitle(String value) {
    return Text(
      "Ticket: $value",
      textScaler: const TextScaler.linear(1.0),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}