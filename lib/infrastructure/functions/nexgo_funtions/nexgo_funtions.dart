import 'dart:convert';

import 'package:ubiiqueso/infrastructure/models/record_response_model.dart';
import 'package:ubiiqueso/infrastructure/models/settlement_response_sdk_model.dart';
import 'package:flutter/services.dart';

class DoTransaction {
  static const platform = MethodChannel('nexgo_service');

  Future<void> bindService() async {
    try {
      final bool result = await platform.invokeMethod('bindService');
      print('Service bound: $result');
    } on PlatformException catch (e) {
      print("Error binding service: ${e.message}");
    }
  }

  Future<Object> doTransaction(
    String amount,
    String cardholderId,
    String waiterNum,
    String referenceNo,
    int transType,
  ) async {
    try {
      print('VALIDANDO MONTO DESDE DoTransaction: $amount');
      print('VALIDANDO CEDULA DESDE DoTransaction: $cardholderId');
      final String result = await platform.invokeMethod('doTransaction', {
        'amount': amount,
        'cardholderId': cardholderId,
        'waiterNum': waiterNum,
        'referenceNo': referenceNo,
        'transType': transType,
      });

      print('RESPUESTA NATIVA: $result');
      final Map<String, dynamic> resultJson = jsonDecode(result);
      print('JSON PARSEADO: $resultJson');
      RecordResponse records = RecordResponse.fromJson(resultJson);
      print('RECORD CREADO: result=${records.result}');
      return records;
    } on PlatformException catch (e) {
      print('ERROR PLATFORM: ${e.code} - ${e.message}');

      // Si el error es SERVICE_NOT_BOUND, lanzar excepción directamente
      if (e.code == 'SERVICE_NOT_BOUND' || e.code == 'REMOTE_EXCEPTION') {
        throw Exception(e.message);
      }

      // Si es TRANSACTION_FAILED, el mensaje ya es JSON
      try {
        final Map<String, dynamic> resultJson2 = jsonDecode(e.message!);
        print('ERROR JSON PARSEADO: $resultJson2');
        RecordResponse records2 = RecordResponse.fromJson(resultJson2);
        print('ERROR CONVERTIDO A RECORD: result=${records2.result}');
        return records2;
      } catch (parseError) {
        print('ERROR PARSEANDO JSON: $parseError');
        throw Exception('Error procesando respuesta: ${e.message}');
      }
    }
  }

  Future<Object> doTransactionSettlement() async {
    try {
      final String result = await platform.invokeMethod('doTransaction', {
        'amount': '0',
        'cardholderId': '0',
        'waiterNum': '',
        'referenceNo': '',
        'transType': 4,
      });
      print(result);
      final Map<String, dynamic> resultJson = jsonDecode(result);
      print(resultJson);
      SettlementResponse records = SettlementResponse.fromJson(resultJson);
      print(records);
      return records;
    } on PlatformException catch (e) {
      print(e.message);
      final Map<String, dynamic> resultJson2 = jsonDecode(e.message!);
      print(resultJson2);
      SettlementResponse records2 = SettlementResponse.fromJson(resultJson2);
      print(records2);
      print("lo volvi un record");
      return records2;
    }
  }
}

class PrinterPos {
  static const platform = MethodChannel('nexgo_service');

  //Imprimir comprobante real
  Future<void> imprimirPos(
    String fullName,
    String ciClient,
    String amount,
    String ctaContrato,
    String referenceNo,
    String fecha,
    String hora,
    String lote,
    String afiliado,
    String terminal,
    String serial,
    String trace,
  ) async {
    try {
      final String result = await platform.invokeMethod('printReceipt', {
        'fullName': fullName,
        'amount': amount,
        'ciClient': ciClient,
        'ctaContrato': ctaContrato,
        'referenceNo': referenceNo,
        'fecha': fecha,
        'hora': hora,
        'lote': lote,
        'afiliado': afiliado,
        'terminal': terminal,
        'serial': serial,
        'trace': trace,
      });
      print('Result from Java: $result');
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  //Función de test para imprimir sin parámetros
  Future<void> imprimirTestPos(String fecha, String hora) async {
    try {
      final String result = await PrinterPos.platform.invokeMethod(
        'printerTest',
        {'fecha': fecha, 'hora': hora},
      );
      print(result);
    } catch (e) {
      print(e);
    }
  }

  // Imprimir Orden de Servicio
  Future<void> imprimirOrdenServicio(
    String ticket,
    String cliente,
    String fechaHora,
    String operador,
  ) async {
    try {
      final String result = await platform.invokeMethod('printOrdenServicio', {
        'ticket': ticket,
        'cliente': cliente,
        'fechaHora': fechaHora,
        'operador': operador,
      });
      print('Orden de servicio impresa: $result');
    } on PlatformException catch (e) {
      print("Error imprimiendo orden: ${e.message}");
    }
  }
}
