import 'dart:convert';

import 'package:disglobal_sdk_demo_for_flutter/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:disglobal_sdk_demo_for_flutter/infrastructure/models/settlement_response_sdk_model.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/settlement/settlement_approved.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/settlement/settlement_failed.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/buttons_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/scafold_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transaccion = DoTransaction();
    return CustomScaffold(
      title: 'HACER CIERRE',
      showLeading: true,
      iconLeanding: Icons.arrow_back_ios_new,
      sizedIconLeanding: 30,
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Resumen de Operaciones\nen mi Base de Datos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 40),
                        Text(
                          'Hora: ${DateFormat().add_Hms().format(DateTime.now())}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cant. de Operaciones:',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 115),
                        Text('7', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total de Operaciones:',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 45),
                        Text('1256.10 Bs', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      '--- PUEDES HACER UN RECIBO ---',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '--- PARA CIERRE ---',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          CustomActionsButton(
            label: 'HACER CIERRE',
            onPressed: () async {
              //Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false, // Evita cerrar tocando fuera
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                //inicializamos bindService
                await transaccion.bindService();
                //Esperamos un poco para asegurarnos que se conecte
                await Future.delayed(const Duration(milliseconds: 500));
                //Ejecutamos el cierre
                final value = await transaccion.doTransactionSettlement();

                late SettlementResponse result;

                // 🔍 Parsear resultado
                if (value is SettlementResponse) {
                  result = value;
                } else if (value is String) {
                  final jsonMap = jsonDecode(value);
                  result = SettlementResponse.fromJson(
                    Map<String, dynamic>.from(jsonMap),
                  );
                } else if (value is Map) {
                  result = SettlementResponse.fromJson(
                    Map<String, dynamic>.from(value),
                  );
                } else {
                  throw Exception("Formato inesperado: ${value.runtimeType}");
                }
                // ✔️ Si aprobado
                if (result.result == 0) {
                  debugPrint("🚀 Transacción finalizada");

                  // Cerrar loading PRIMERAMENTE
                  Navigator.pop(context);
                  //EJECUTAR ACCION COMO NAVEGAR A PANTALLA O HACER UNA REQUEST APENAS TENEMOS EL JSON ETC..
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SettlementApproved(settlementResponse: result),
                    ),
                  );
                } else {
                  Navigator.pop(context); // 🔹 Cerrar loading
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SettlementFailed(settlementResponse: result),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context); // 🔹 Cerrar loading
                debugPrint("🔥 Error procesando transacción: $e");
              }
            },
            withIcon: true,
            icon: Icons.receipt_long_outlined,
            iconSize: 30,
            borderRadius: 50,
            backgroundColor: colors.primary,
            borderColor: Colors.white,
            sideBorder: 3,
            width: 250,
            height: 60,
          ),
        ],
      ),
    );
  }
}
