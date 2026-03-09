import 'package:disglobal_sdk_demo_for_flutter/infrastructure/theme/app_theme.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/home/home_demo.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/printer/printer_screen.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/sale/sale_screen.dart';
import 'package:disglobal_sdk_demo_for_flutter/presentation/screens/settlement/settlement_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DG Demo SDK',
      theme: AppTheme(selectedColor: 0).getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeDemo(),
        'do-transaction' : (context) => const SaleScreen(),
        'printer' : (context) => const PrinterScreen(),
        'do-settlement' : (context) => const SettlementScreen(),
      },
    );
  }
}
