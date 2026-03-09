import 'package:disglobal_sdk_demo_for_flutter/infrastructure/models/record_response_model.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/buttons_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/scafold_custom.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TransactionApprovedScreen extends StatelessWidget {
  final RecordResponse recordResponse;
  final String document;
  final String amountReintentar;

  const TransactionApprovedScreen({
    super.key,
    required this.recordResponse,
    required this.document,
    required this.amountReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Convertimos el RecordResponse a JSON
    final jsonPretty = const JsonEncoder.withIndent(
      '  ',
    ).convert(recordResponse.toJson());

    return CustomScaffold(
      title: 'RESULTADO DE COMPRA',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'APROBADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 320,
              width: 350,
              child: Card(
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Text(
                      jsonPretty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomActionsButton(
              label: 'FINALIZAR',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              withIcon: true,
              icon: Icons.house_outlined,
              iconSize: 30,
              borderRadius: 50,
              backgroundColor: colors.primary,
              borderColor: Colors.white,
              sideBorder: 3,
            ),
          ],
        ),
      ),
    );
  }
}
