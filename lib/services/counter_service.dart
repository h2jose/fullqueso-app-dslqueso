import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ubiiqueso/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda la informacion del usuario en MongoDB Cloud
Future<void> saveCounterData(Map<String, dynamic> userData) async {

  // calcular timestamp epoch en seconds:
  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  userData['timestampOpen'] = timestamp;
  userData['timestampClose'] = timestamp;
  userData['isUbii'] = true;
  userData['active'] = true;

  final url = Uri.parse('$uriBase/counter/add/ubii');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al guardar la caja: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body);
    final counterId = responseData['data']['_id'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('counterId', counterId);


  } catch (e) {
    throw Exception('No se pudo conectar al servidor: $e');
  }
}

/// Cierra la sesión del contador en el servidor
  Future<void> closeCounterSession(String counterId) async
  {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final url = Uri.parse('$uriBase/counter/signout/ubii/$counterId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenExpress',
        },
        body: jsonEncode({
          'timestampClose': timestamp,
          'active': false,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al cerrar caja: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cerrando sesión: $e');
    }
  }