import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubiiqueso/components/common/app_bar_text_widget.dart';
import 'package:ubiiqueso/pages/home_page.dart';
import 'package:ubiiqueso/services/counter_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:ubiiqueso/infrastructure/models/settlement_response_sdk_model.dart';

import '../components/common/show_alert.dart';

class SignoutPage extends StatefulWidget {
  const SignoutPage({super.key});

  @override
  State<SignoutPage> createState() => _SignoutPageState();
}

class _SignoutPageState extends State<SignoutPage> {
  final DoTransaction _dslService = DoTransaction();

  bool isBack = true;
  bool finished = false;
  bool isProcessing = false;
  String settlementResult = '';

  // Método para procesar settlement con DSL
  void _procesarSettlementDSL() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Llamar a DSL doTransactionSettlement (transType: 4 = SETTLEMENT)
      final result = await _dslService.doTransactionSettlement();

      // Parsear respuesta DSL
      if (result is SettlementResponse) {
        setState(() {
          // result == 0 significa éxito en DSL
          if (result.result == 0) {
            settlementResult = '''
✅ CIERRE EXITOSO

Total Ventas Débito: ${result.totalDebitCardSale ?? '0'}
Total Ventas Crédito: ${result.totalCreditCardSale ?? '0'}
Lote Débito: ${result.debitBatchNo ?? 'N/A'}
Lote Crédito: ${result.creditBatchNo ?? 'N/A'}
''';
            isBack = false;
            finished = true;
            isProcessing = false;
          } else {
            settlementResult = 'ERROR: ${result.result} - ${result.responseMessage ?? 'Error desconocido'}';
            ShowAlert(context, "CIERRE RECHAZADO: $settlementResult", 'error');
            isProcessing = false;
            finished = false;
          }
        });
      } else {
        ShowAlert(context, "Error: Respuesta inválida del POS", 'error');
        setState(() {
          isProcessing = false;
          finished = false;
        });
      }
    } catch (e) {
      print("Error procesando settlement DSL: $e");
      ShowAlert(context, "Error al procesar cierre: $e", 'error');
      setState(() {
        isProcessing = false;
        finished = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initDSLService();
  }

  void _initDSLService() async {
    try {
      await _dslService.bindService();
      // Delay obligatorio de 500ms después de bindService
      await Future.delayed(const Duration(milliseconds: 500));
      print("DSL Service inicializado correctamente para settlement");
    } catch (e) {
      print("Error inicializando DSL Service: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTextWidget(
        text: 'Cierre de Lote',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (!finished) ElevatedButton(
                onPressed: isProcessing ? null : _procesarSettlementDSL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Full width button
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cerrar Punto', textScaler: TextScaler.linear(1.5)),
              ),
              const SizedBox(height: 20),
              if (settlementResult.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        settlementResult,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: finished ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            try {
              // 1. Recuperar counterId de SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final counterId = prefs.getString('counterId');
              if (counterId != null && counterId.isNotEmpty) {
                // 2. Cerrar sesión en el servidor
                await closeCounterSession(counterId);
                // 3. Limpiar counterId de SharedPreferences
                await prefs.remove('counterId');
              }
              // 4. Limpiar datos locales
              SharedService.shopId = '';
              SharedService.shopCode = '';
              // 5. Logout de Firebase
              await FirebaseAuth.instance.signOut();
              // 6. Navegar a HomePage
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute( builder: (context) => const HomePage()), (route) => false);
            } on Exception catch (e) {
              // Si falla el cierre, mostrar error
              ShowAlert(context, 'Error al cerrar sesión: ${e.toString()}', 'error');
              debugPrint('Error en logout: $e');
            }


          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary, // Background color
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            textStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            minimumSize:
            const Size(double.infinity, 50), // Full width button
          ),
          child: const Text('CONTINUAR'),
        ),
      ) : null,
    );
  }
}