import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ubiiqueso/utils/constants.dart';

class RateService {

  Future<double> fetchRate() async {

    // CODIGO ANTERIOR CON AXIOS EN JAVASCRIPT / VUE, para migrar a Dart / Flutter en este servicio
    // const response = await apiRate.get('/exchange/bcv')
    // El servidor devuelve { price: number }
    // return response.data.price || 50

    const String uriExchange = uriRate;

    final resp = await http.get(Uri.parse(uriExchange));
    if (resp.statusCode == 200) {
      return json.decode(resp.body)['price'] ?? 1.0;
    } else {
      throw Exception('Failed to load rate');
    }


  }

}

