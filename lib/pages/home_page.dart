import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubiiqueso/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/common/common.dart';
import 'package:ubiiqueso/components/form/form.dart';
import 'package:ubiiqueso/models/user.dart';
import 'package:ubiiqueso/services/counter_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/services/user_service.dart';
import 'package:ubiiqueso/theme/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final operatorController = TextEditingController();
  final localIpController = TextEditingController();
  final localPortController = TextEditingController();

  String selectedCodigoPunto = SharedService.punto;

  void signUserIn() async {
    setState(() {
      isLoading = true;
    });
    final username = usernameController.value.text.trim();
    final password = passwordController.value.text.trim();
    final operator = operatorController.value.text.trim();

    if (operator.isEmpty) {
      ShowAlert(context, "Nombre del Usuario es obligatorio", 'error');
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (username.isEmpty || password.isEmpty) {
      ShowAlert(context, "Hubo un error, Código y Contraseña son obligatorios",
          'error');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Primero hacer login
      final value = await signin(username.toLowerCase(), password);
      final doc = await db.collection('users').doc(value.id).get();

      if (doc.exists) {
        UserModel myUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        // debugPrint("user: ${myUser.toJson()}");

        final punto = SharedService.punto; // ej: "Punto 1"
        final parts = punto.split(' ');
        final puntoNumber = parts.length > 1 ? parts[1] : '0';
        final operatorCode = 'UBII-$puntoNumber';

        // Guardar en Mongo Online para Cierre de Caja
        await saveCounterData({
          'shop': myUser.shopId!,
          'operatorCode': operatorCode,
          'operatorName': operator.toUpperCase(),
          'punto': SharedService.punto,
        });

        // Configurar datos del usuario
        SharedService.shopId = myUser.shopId!;
        SharedService.shopCode = myUser.shopCode!;
        SharedService.shopName = myUser.shopCode!;
        SharedService.displayName = myUser.name ?? 'UBII';
        SharedService.operatorName = operator.toUpperCase() ?? 'FQ_UBII';
        SharedService.logon = 'YES';
        SharedService.operatorCode = operatorCode;

        // Navegar al dashboard
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
      }
    } catch (error) {
      debugPrint("error: $error");
      // Limpiar SharedPreferences en caso de error para evitar estado inconsistente
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('shopId');
      await prefs.remove('shopCode');
      await prefs.remove('shopName');
      await prefs.remove('displayName');
      await prefs.remove('operatorName');
      await prefs.remove('operatorCode');
      await prefs.remove('logon');
      await prefs.remove('counterId');
      // Hacer signOut de Firebase también para mantener consistencia
      await FirebaseAuth.instance.signOut();
      ShowAlert(context, error.toString(), 'error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCodigoPunto = SharedService.punto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SharedService.shopId == '' ? SingleChildScrollView(
          child: Center(
            child: isLoading
                ? const LoadingWidget()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/isologo2.png', width: 150),
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'UBII',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueAccent[700]),
                          ),
                          const TextSpan(
                            text: 'FULL',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black26),
                          ),
                          const TextSpan(
                            text: 'QUESO',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary),
                          ),
                        ],
                      )),
                      const SizedBox(height: 25),
                       Container(
                          width: MediaQuery.of(context).size.width * 0.88,
                           padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: selectedCodigoPunto,
                            onChanged: (String? newValue) {
                              setState(() {
                              selectedCodigoPunto = newValue!;
                              SharedService.punto = newValue;
                              });
                            },
                            items: puntosList
                              .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textScaler: const TextScaler.linear(1.1),
                                style: const TextStyle(color: AppColor.secondary, fontWeight: FontWeight.w800),
                              ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 10),
                      FormTextField(
                        controller: operatorController,
                        hintText: 'Nombre del Operador',
                        obscureText: false,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow( RegExp(r'[a-zA-Z0-9]')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FormTextField(
                        controller: usernameController,
                        hintText: 'Código Acceso',
                        obscureText: false,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FormTextField(
                        controller: passwordController,
                        hintText: 'Contraseña',
                        obscureText: true,
                      ),

                      const SizedBox(height: 15),

                      // sign in button
                      FormButton(
                        label: 'INGRESAR',
                        onTap: signUserIn,
                      ),
                      const SizedBox(height: 30),
                      const VersionNumber(color: Colors.black26)
                    ],
                  ),
          ),
        ) : Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/isologo2.png', width: 250),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary, // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    minimumSize:
                    const Size(double.infinity, 50), // Full width button
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/dashboard', (route) => false);
                  }, child: const Text('Continuar')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
