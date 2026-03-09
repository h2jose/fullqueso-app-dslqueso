import 'package:disglobal_sdk_demo_for_flutter/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/buttons_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/scafold_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrinterScreen extends StatelessWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomScaffold(
      title: 'IMPRIMIR TEST',
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
                      'AQUI EL LOGO',
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
                        Text('Item 1:', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 180),
                        Text('Valor 1', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Item 2:', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 180),
                        Text('Valor 2', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Item 3:', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 180),
                        Text('Valor 3', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      '1000.00 Bs',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '------ ESTO ES UNA PRUEBA -----',
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
            label: 'IMPRIMIR',
            onPressed: () async {
              final printer = PrinterPos();
              await printer.imprimirTestPos(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                DateFormat().add_Hms().format(DateTime.now()),
              );
            },
            withIcon: true,
            icon: Icons.receipt,
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
    );
  }
}
