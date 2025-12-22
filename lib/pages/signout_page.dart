import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubiiqueso/components/common/app_bar_text_widget.dart';
import 'package:ubiiqueso/pages/home_page.dart';
import 'package:ubiiqueso/services/counter_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';

import '../components/common/show_alert.dart';

class SignoutPage extends StatefulWidget {
  const SignoutPage({super.key});

  @override
  State<SignoutPage> createState() => _SignoutPageState();
}

class _SignoutPageState extends State<SignoutPage> {
  static const platform = MethodChannel('com.fullqueso.ubiiqueso/channel');

  bool isBack = true;
  bool finished = false;
  // Lista para almacenar la respuesta
  List<Map<String, String>> responseData = [];

  // Método para lanzar el intent y recibir la respuesta
  void _launchIntent(String transType, String amount) async {
    try {
      final Map<Object?, Object?> result = await platform.invokeMethod('getResponse', {
        'transType': transType,
        'amount': amount,
        'logon': "NO"
      });

      if (result != null) {
        List<Map<String, String>> resultList = [];
        result.forEach((key, value) {
          resultList.add({'key': key.toString(), 'value': value.toString()});
        });
        setState(() {
          responseData = resultList;
          SharedService.logon = 'YES';
          isBack = false;
          finished = true;
        });
      }
    } on PlatformException catch (e) {
      ShowAlert(context, e.message ?? 'Error Desconocido', 'error');
      print("Error obteniendo la respuesta del intent: $e");
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
                onPressed: () {
                  _launchIntent('SETTLEMENT', '0');
                  setState(() {
                    isBack = false;
                    finished = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Full width button
                ),
                child: const Text('Cerrar Punto', textScaler: TextScaler.linear(1.5),),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: responseData.length,
                  itemBuilder: (context, index) {
                    final data = responseData[index];
                    return ListTile(
                      title: Text(data['key'] ?? 'No Key'),
                      subtitle: Text(data['value'] ?? 'No Value'),
                    );
                  },
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