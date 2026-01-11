import 'dart:convert';

import 'package:ubiiqueso/infrastructure/models/record_response_model.dart';
import 'package:ubiiqueso/infrastructure/models/settlement_response_sdk_model.dart';
import 'package:flutter/services.dart';

class DoTransaction {
  static const platform = MethodChannel('nexgo_service');

  Future<void> bindService() async {
    try {
      await platform.invokeMethod('bindService');
    } on PlatformException catch (_) {
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
      final String result = await platform.invokeMethod('doTransaction', {
        'amount': amount,
        'cardholderId': cardholderId,
        'waiterNum': waiterNum,
        'referenceNo': referenceNo,
        'transType': transType,
      });

      final Map<String, dynamic> resultJson = jsonDecode(result);
      RecordResponse records = RecordResponse.fromJson(resultJson);
      return records;
    } on PlatformException catch (e) {

      // Si el error es SERVICE_NOT_BOUND, lanzar excepción directamente
      if (e.code == 'SERVICE_NOT_BOUND' || e.code == 'REMOTE_EXCEPTION') {
        throw Exception(e.message);
      }

      // Si es TRANSACTION_FAILED, el mensaje ya es JSON
      try {
        final Map<String, dynamic> resultJson2 = jsonDecode(e.message!);
        RecordResponse records2 = RecordResponse.fromJson(resultJson2);
        return records2;
      } catch (parseError) {
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
      final Map<String, dynamic> resultJson = jsonDecode(result);
      SettlementResponse records = SettlementResponse.fromJson(resultJson);
      return records;
    } on PlatformException catch (e) {
      final Map<String, dynamic> resultJson2 = jsonDecode(e.message!);
      SettlementResponse records2 = SettlementResponse.fromJson(resultJson2);
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
      await platform.invokeMethod('printReceipt', {
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
    } on PlatformException catch (_) {
    }
  }

  //Función de test para imprimir sin parámetros
  Future<void> imprimirTestPos(String fecha, String hora) async {
    try {
      await PrinterPos.platform.invokeMethod(
        'printerTest',
        {'fecha': fecha, 'hora': hora},
      );
    } catch (_) {
    }
  }

  // Imprimir Orden de Servicio
  Future<void> imprimirOrdenServicio(
    String ticket,
    String cedula,
    String cliente,
    String fechaHora,
    String operador,
  ) async {
    try {
      await platform.invokeMethod('printOrdenServicio', {
        'ticket': ticket,
        'cedula': cedula,
        'cliente': cliente,
        'fechaHora': fechaHora,
        'operador': operador,
      });
    } on PlatformException catch (_) {
    }
  }
}
