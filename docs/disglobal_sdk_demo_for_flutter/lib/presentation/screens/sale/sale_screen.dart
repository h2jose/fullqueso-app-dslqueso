import 'dart:convert';

import 'package:disglobal_sdk_demo_for_flutter/infrastructure/functions/help_funtions/help_funtions.dart';
import 'package:disglobal_sdk_demo_for_flutter/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:disglobal_sdk_demo_for_flutter/infrastructure/models/record_response_model.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/sale/transaction_approved_screen.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/sale/transaction_failed_screen.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/buttons_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/scafold_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final GlobalKey<CustomTextFieldBoxState> textFieldKey = GlobalKey();
  final GlobalKey<CustomTextFieldBoxState> textFieldKey2 = GlobalKey();
  late TextEditingController numberDocument;
  late TextEditingController amount;

  @override
  void initState() {
    super.initState();
    numberDocument = TextEditingController();
    amount = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transaccion = DoTransaction();
    return CustomScaffold(
      title: 'HACER COMPRA',
      showLeading: true,
      iconLeanding: Icons.arrow_back_ios_new,
      sizedIconLeanding: 30,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'EJEMPLO PARA HACER UNA TRANSACCION',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ingrese Monto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            CustomAmountField(
              key: textFieldKey2,
              hintText: 'Ingrese Monto',
              borderColor: colors.primary,
              textColor: colors.primary,
              borderWidth: 3,
              borderRadius: 20,
              fontSize: 25,
              onValue: (value) {
                amount.text = value.toString();
                print(amount.text);
              },
            ),
            SizedBox(height: 20),
            Text(
              'Ingrese Cedula de la Tarjeta',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            CustomTextFieldBox(
              key: textFieldKey,
              hintText: 'Ingrese C.I',
              borderColor: colors.primary,
              textColor: colors.primary,
              borderWidth: 3,
              borderRadius: 20,
              fontSize: 25,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onValue: (value) {
                numberDocument.text = value;
                print(numberDocument.text);
              },
            ),
            SizedBox(height: 20),
            CustomActionsButton(
              label: 'PAGAR',
              onPressed: () async {
                //DEV
                debugPrint(
                  'MONTO ENVIADO: ${transformarAmountaEntero(amount.text)}',
                );
                debugPrint('CEDULA ENVIADA: ${numberDocument.text}');

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
                  //Ejecutamos la transaccion
                  final value = await transaccion.doTransaction(
                    transformarAmountaEntero(amount.text),
                    numberDocument.text,
                    '',
                    '',
                    1,
                  );

                  late RecordResponse result;

                  // 🔍 Parsear resultado
                  if (value is RecordResponse) {
                    result = value;
                  } else if (value is String) {
                    final jsonMap = jsonDecode(value);
                    result = RecordResponse.fromJson(
                      Map<String, dynamic>.from(jsonMap),
                    );
                  } else if (value is Map) {
                    result = RecordResponse.fromJson(
                      Map<String, dynamic>.from(value),
                    );
                  } else {
                    throw Exception("Formato inesperado: ${value.runtimeType}");
                  }

                  textFieldKey.currentState?.reset();
                  textFieldKey2.currentState?.reset();

                  // ✔️ Si aprobado
                  if (result.result == 0) {
                    debugPrint("🚀 Transacción aprobada");

                    // Cerrar loading PRIMERAMENTE
                    Navigator.pop(context);

                    //EJECUTAR ACCION COMO NAVEGAR A PANTALLA O HACER UNA REQUEST APENAS TENEMOS EL JSON ETC..
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionApprovedScreen(
                          recordResponse: result,
                          document: numberDocument.text,
                          amountReintentar: transformarAmountaEntero(
                            amount.text,
                          ),
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context); // 🔹 Cerrar loading
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionFailedScreen(
                          recordResponse: result,
                          amountReintentar: transformarAmountaEntero(
                            amount.text,
                          ),
                          document: numberDocument.text,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context); // 🔹 Cerrar loading
                  debugPrint("🔥 Error procesando transacción: $e");
                }
              },
              withIcon: true,
              icon: Icons.payment_outlined,
              iconSize: 30,
              borderRadius: 50,
              backgroundColor: colors.primary,
              borderColor: Colors.white,
              sideBorder: 3,
              width: 180,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
