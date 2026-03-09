import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/buttons_custom.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/img_app_widgets.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/widgets/scafold_custom.dart';
import 'package:flutter/material.dart';

class HomeDemo extends StatelessWidget {
  const HomeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomScaffold(
      showAppBar: false,
      title: '',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LogoPrincipal(widthImg: 320),
          SizedBox(height: 30),
          Text('DEMO DE INTEGRACION DEL SDK\nEN FLUTTER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,            
          )),
          SizedBox(height: 60),
          CustomActionsButton(
            label: 'HACER COMPRA',
            onPressed: () => Navigator.pushNamed(context, 'do-transaction'),
            withIcon: true,
            icon: Icons.payment_outlined,
            iconSize: 30,
            borderRadius: 50,
            backgroundColor: colors.primary,
            borderColor: Colors.white,
            sideBorder: 3,
          ),
          SizedBox(height: 30),
          CustomActionsButton(
            label: 'IMPRIMIR',
            onPressed: () => Navigator.pushNamed(context, 'printer'),
            withIcon: true,
            icon: Icons.receipt,
            iconSize: 30,
            borderRadius: 50,
            backgroundColor: colors.primary,
            borderColor: Colors.white,
            sideBorder: 3,
          ),
          SizedBox(height: 30),
          CustomActionsButton(
            label: 'HACER CIERRE',
            onPressed: () => Navigator.pushNamed(context, 'do-settlement'),
            withIcon: true,
            icon: Icons.receipt_long_rounded,
            iconSize: 30,
            borderRadius: 50,
            backgroundColor: colors.primary,
            borderColor: Colors.white,
            sideBorder: 3,
          ),
        ],
      ),
    );
  }
}
