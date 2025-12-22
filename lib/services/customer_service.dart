import 'dart:convert';

import 'package:ubiiqueso/models/order.dart';
import 'package:http/http.dart' as http;

import 'package:ubiiqueso/utils/constants.dart';

  Future<void> saveCustomerService(Customer data) async {
     String uriUpdate = "$uriCustomer/update";

    final resp = await http.post(Uri.parse(uriUpdate), body: {
      'tipo': data.tipo,
      'name': data.name,
      'cedula': data.cedula,
      'prefix': data.prefix,
      'cel': data.cel,
      'phone': data.phone,
      'location': data.location ?? '',
      'address': data.address ?? '',
      'source': 'express',
    });

    if (resp.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }



  Future<Customer> queryCustomerService(String cedula) async {

    String uriQueryCustomer = "$uriCustomer/query?cedula=$cedula";

    final resp = await http.get(Uri.parse(uriQueryCustomer));

    if (resp.statusCode == 200) {
      if (resp.body.isEmpty) {
        throw Exception('Cliente no existe');
      }
      final decodedJson = json.decode(resp.body);
      if (decodedJson == null) {
        return Customer.empty();
      }
      final Map<String, dynamic> data = decodedJson as Map<String, dynamic>;
      return Customer.fromJson(data);
    } else {
       return Customer.empty();
    }
  }

