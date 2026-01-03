import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:ubiiqueso/components/common/show_alert.dart';
import 'package:ubiiqueso/models/checkout.dart';
import 'package:ubiiqueso/pages/dashboard_page.dart';
import 'package:ubiiqueso/services/customer_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/utils/bank_data.dart';
import 'package:ubiiqueso/utils/constants.dart';
import 'package:ubiiqueso/utils/show_error_container.dart';
import 'package:http/http.dart' as http;
import 'package:ubiiqueso/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';

class CheckoutBottomsheetPayments extends StatefulWidget {
  final CheckoutModel checkout;
  const CheckoutBottomsheetPayments({super.key, required this.checkout});
  @override
  State<CheckoutBottomsheetPayments> createState() => _CheckoutBottomsheetPaymentsState();
}

class _CheckoutBottomsheetPaymentsState extends State<CheckoutBottomsheetPayments> {
  String? _selectedPaymentMethod;
  String totalBs = '';
  String totalUsd = '';
  CheckoutModel get checkout => widget.checkout;

  String? _errorMessage;
  Timer? _errorTimer;

  FirebaseFirestore db = FirebaseFirestore.instance;
  bool saving = false;
  bool loading = false;
  final PrinterPos _printer = PrinterPos();


  // Pago movil
  String? _selectedBancoCode =  '0102';
  String? _selectedTipo = 'V';
  final List<String> _tipos = ['V', 'E', 'J', 'G'];
  String? _selectedPrefix = '0412';
  final List<String> _prefixes = ['0412', '0414', '0424', '0416', '0426'];
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _referenciaController = TextEditingController();



  // Pago Zelle
  final _zelleReferenciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    totalBs = NumberFormat.currency(locale: 'en_US', symbol: 'Bs.').format(checkout.totalToPayBs);
    totalUsd = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(checkout.totalToPay);
    if (bancos.isNotEmpty) {
      _selectedBancoCode = bancos[0]['value'];
      _cedulaController.text = checkout.customer?.cedula ?? '';
      _selectedTipo = checkout.customer?.tipo ?? 'V';
      _telefonoController.text = checkout.customer?.cel ?? '';
      _selectedPrefix = checkout.customer?.prefix ?? '0412';
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedPaymentMethod = null;
      _cedulaController.clear();
      _telefonoController.clear();
      _referenciaController.clear();
      _zelleReferenciaController.clear();
      if (bancos.isNotEmpty) {
        _selectedBancoCode = bancos[0]['value'];
      }
    });
  }

  void _showError(String message) {
    _errorTimer?.cancel();
    setState(() {
      _errorMessage = message;
    });
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
    _errorTimer?.cancel();
  }



  bool _validatePagoMovilFields() {
    final cedulaIsEmpty = _cedulaController.text.trim().isEmpty;
    final telefonoIsEmpty = _telefonoController.text.trim().isEmpty;
    final referenciaIsEmpty = _referenciaController.text.trim().isEmpty;

    if (cedulaIsEmpty || telefonoIsEmpty || referenciaIsEmpty) {
      _showError(
        'Complete todos los campos: Cédula/Rif, Teléfono y Referencia.',
      );
      return false;
    }
    return true;
  }

  bool _validateZelleFields() {
    final referenciaZelleIsEmpty =
        _zelleReferenciaController.text.trim().isEmpty;

    if (referenciaZelleIsEmpty) {
      _showError('Por favor, ingrese la Referencia / Confirmación de Zelle.');
      return false;
    }
    return true;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: const Text('CONFIRMAR PAGO', textScaler: TextScaler.linear(1.3),),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.dark,
          ),
          content: Text(
            '¿seguro de procesar el pago mediante $_selectedPaymentMethod?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: AppColor.dark), textScaler: TextScaler.linear(0.9),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.dark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              child: const Text('SI, PROCESAR', style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _processPayment();
              },
            ),
          ],
        );
      },
    );
  }

  void _processPayment() async {

    final now = DateTime.now();
    final int timestamp = (now.millisecondsSinceEpoch / 1000).round();

    if (_selectedPaymentMethod == 'Pago Móvil') {
      final uriQueryReferencia = '$uriApiBdv/query?referencia=${_referenciaController.text}';
      const uriBdvReferencia = '$uriApiBdv/conciliar';
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final hoy = '$day/$month/$year ${now.hour}:${now.minute}';
      final Map<String, dynamic> conciliacionBdv = {
        'cedulaPagador': '$_selectedTipo${_cedulaController.text}',
        'telefonoPagador': '${_selectedPrefix ?? ''}${_telefonoController.text}',
        'referencia': _referenciaController.text,
        'fechaPago': "$year-$month-$day",
        'importe': checkout.totalToPayBs!.toStringAsFixed(2),
        'bancoOrigen': _selectedBancoCode,
        'timePago': hoy,
        'ticket': checkout.ticket,
        'key': SharedService.keyBdv,
        'telefono': SharedService.pagoMovil.replaceAll('-', ''),
        'shopName': SharedService.shopName,
      };

      try {
        setState(() {loading = true;});
        final queryResp = await http.get(Uri.parse(uriQueryReferencia));
        final someData = jsonDecode(queryResp.body)  ?? 'NO DATA';

        if (someData != 'NO DATA') {
          setState(() {loading = false;});
          _showError('Numero de Referencia ya fue usado');
          return;
        }

        final postResp = await http.post(
          Uri.parse(uriBdvReferencia),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(conciliacionBdv),
        );

        final responseBody = jsonDecode(postResp.body);

        log('Response Body: $responseBody');

        if (postResp.statusCode == 200 && responseBody['code'] == 1000) {
          log('Conciliacion existe, se puede guardar');

          setState(() {
            checkout.totalPaidBs = checkout.totalToPayBs;
            checkout.totalPaid = checkout.totalToPay;
            checkout.conciliacionBdv = ConciliacionBdv.fromMap(conciliacionBdv);
            checkout.conciliacionBdv?.key = 'BDV';
            checkout.paidMovilVaucher = _referenciaController.text;
            checkout.paidMovilBs = checkout.totalToPayBs;
            checkout.paidMovilUsd = checkout.totalToPay;
            checkout.isBdv = true;
            checkout.statusId = 2;
            checkout.statusCurrent = 'Preparación';
            checkout.statusLog?[1].date = timestamp;
            checkout.statusLog?[1].user = SharedService.operatorName;
            checkout.statusLog?[2].date = timestamp;
            checkout.statusLog?[2].user = SharedService.operatorName;
          });

          await http.post(
            Uri.parse('$uriBase/bdv/conciliar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(checkout.conciliacionBdv),
          );

          setState(() {loading = false;});

          _processCheckout();
          return;


        } else {
          setState(() {
            loading = false;
          });
          _dialogPagoSinConciliar(timestamp);
          return;
        }
      } catch (e) {
        print('Error en la conciliación: $e');
        _showError('Error de conexión o inesperado.');
        return;
      }
    } else if (_selectedPaymentMethod == 'Zelle') {
      log('Referencia Zelle: ${_zelleReferenciaController.text}');
      setState(() {
        checkout.statusId = 0;
        checkout.statusCurrent = 'Solicitado';
        checkout.statusLog?[0].date = timestamp;
        checkout.statusLog?[0].user = SharedService.operatorName;
        checkout.totalPaidBs = checkout.totalToPayBs;
        checkout.totalPaid = checkout.totalToPay;
        checkout.conciliacionBdv = ConciliacionBdv();
        checkout.isBdv = false;
        checkout.paidZelleVaucher = _zelleReferenciaController.text;
        checkout.paidZelle = checkout.totalToPay;
      });
      _processCheckout();
      return;

    } else if (_selectedPaymentMethod == 'Mostrador') {
      log('Pago en mostrador registrado como pendiente.');
        // _dialogPagoSinConciliar(timestamp);

      setState(() {
        checkout.statusId = 0;
        checkout.statusCurrent = 'Solicitado';
        checkout.statusLog?[0].date = timestamp;
        checkout.statusLog?[0].user = SharedService.operatorName;
        checkout.totalPaidBs = 0;
        checkout.totalPaid = 0;
        checkout.conciliacionBdv = ConciliacionBdv();
        checkout.isBdv = false;
      });
      await _imprimirOrdenServicio();
      _processCheckout();
        return;
    }
    log("cerrar bottomsheet");
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<dynamic> _dialogPagoSinConciliar(int timestamp) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
          return AlertDialog(
          backgroundColor: Colors.red,
          title: const Text(
            'PAGO NO EXISTE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Desea continuar con chequeo manual?',
            style: TextStyle(color: Colors.white),
          ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.accent,
                  foregroundColor: AppColor.dark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 36), // Make button take full width available in dialog
                  ),
                  onPressed: () {
                  // print('Conciliacion no existe, se puede guardar para revisión');

                  setState(() {
                    checkout.statusId = 0;
                    checkout.statusCurrent = 'Solicitado';
                    checkout.statusLog?[0].date = timestamp;
                    checkout.statusLog?[0].user = SharedService.operatorName;
                    checkout.conciliacionBdv?.key = 'BDV';
                    checkout.paidMovilVaucher = _referenciaController.text;
                    checkout.paidMovilBs = checkout.totalToPayBs;
                    checkout.paidMovilUsd = checkout.totalToPay;
                    checkout.isBdv = false;
                    checkout.conciliacionBdv = ConciliacionBdv();
                    checkout.isBdv = false;
                  });

                  // print("checkout.toJson(): ${checkout.toJson()}");

                  Navigator.of(dialogContext).pop();
                  // if (mounted) Navigator.of(context).pop(); // Keep this commented out or decide if it's needed based on flow

                  _processCheckout();
                  },
                  child: const Text(
                  'CONTINUAR',
                  textScaler: TextScaler.linear(1.5),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.dark,
                  ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                  Navigator.of(dialogContext).pop();
                  },
                ),
                ],
              ),
          ],
          );
      },
    );
  }

  Future<void> _processCheckout() async {
    if (mounted) {
      setState(() {
        saving = true;
      });
    }
    try {
      // generar ID de ORDEN
      if (checkout.id != null && !checkout.id!.contains('_')) { // si no tiene guion bajo, significa que no se ha generado
        checkout.id = "${checkout.timestamp}_${checkout.customer?.cedula}";
      }

      await db.collection('orders').doc("${checkout.id}").set(checkout.toJson());
      await saveCustomerService(checkout.customer!);
      ShowAlert(context, "Orden procesada satisfactoriamente", 'success');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (e) {
      log('Error: $e');
      ShowAlert(context, e.toString(), 'error');
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  Future<void> _imprimirOrdenServicio() async {
    try {
      // Formatear ticket (últimos 6 dígitos)
      String ticket = checkout.ticket ?? '';
      if (ticket.length > 6) {
        ticket = ticket.substring(ticket.length - 6);
      }

      // Formatear cliente (tipo-cedula)
      String cedula = '${checkout.customer?.tipo ?? 'V'}-${checkout.customer?.cedula ?? ''}';
      String cliente = '${checkout.customer?.name ?? ''}';

      // Formatear fecha y hora actual
      final now = DateTime.now();
      String fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(now);

      print('DEBUG fechaHora generada: $fechaHora');

      // Obtener operador
      String operador = SharedService.operatorName;

      // Imprimir orden de servicio
      await _printer.imprimirOrdenServicio(ticket, cedula, cliente, fechaHora, operador);
    } catch (e) {
      log('Error imprimiendo orden de servicio: $e');
    }
  }

  Future<dynamic> _dialogAfterSave() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Orden procesada satisfactoriamente',
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ticket'),
              Text(
                checkout.ticket!.substring(checkout.ticket!.length - 6),
                textScaler: const TextScaler.linear(1.5),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              /* const Text('Total Pagado Divisas'),
              Text(
                checkout.totalPaid!.toStringAsFixed(2),
                textScaler: const TextScaler.linear(1.5),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Total Pagado Bs'),
              Text(
                checkout.totalPaidBs!.toStringAsFixed(2),
                textScaler: const TextScaler.linear(1.5),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ), */
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const DashboardPage()),
                );
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
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _telefonoController.dispose();
    _referenciaController.dispose();
    _zelleReferenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerTotales(),
          const SizedBox(height: 15),
          if (_selectedPaymentMethod == null) _buildPaymentMethodList()
          else
            _buildSelectedPaymentForm(),

          const SizedBox(height: 10),

          if (loading)
            const Center(child: CircularProgressIndicator()),
          if (saving)
            const Center(child: CircularProgressIndicator()),

          ShowErrorContainer(errorMessage: _errorMessage,),
          const SizedBox(height: 10),

          if (_selectedPaymentMethod != null)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  bool isValid = true;
                  if (_selectedPaymentMethod == 'Pago Móvil') {
                    isValid = _validatePagoMovilFields();
                  } else if (_selectedPaymentMethod == 'Zelle') {
                    isValid = _validateZelleFields();
                  }
                  if (!isValid) { return; }

                  _showConfirmationDialog();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.dark,
                  padding: const EdgeInsets.symmetric( horizontal: 40, vertical: 12, ),
                ),
                child: const Text(
                  'Procesar Pago',
                  textScaler: TextScaler.linear(1.5),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30,),

          TextButton(
              onPressed: () {
                _resetSelection();
                Navigator.pop(context);
              },
              child:  _closeSheet(),
            ),

          const SizedBox(height: 100,),
        ],
      ),
    );
  }

  Container _headerTotales() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
            color: AppColor.dark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Text(
              "Total a Pagar:\n$totalUsd  $totalBs ",
              textScaler: const TextScaler.linear(1.3),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
  }

  Widget _buildPaymentMethodList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Seleccione un Método de Pago',
          textScaler: TextScaler.linear(1.3),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ListTile(
          leading: const Icon(Icons.phone_android_outlined),
          title: const Text('Pago Móvil'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Pago Móvil';
            });
          },
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.alternate_email_outlined),
          title: const Text('Zelle'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Zelle';
            });
          },
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.storefront_outlined),
          title: const Text('Mostrador'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Mostrador';
            });
          },
        ),
      ],
    );
  }

  Widget _buildSelectedPaymentForm() {
    Widget content;
    String title = '';

    switch (_selectedPaymentMethod) {
      case 'Pago Móvil':
        content = _buildPagoMovilContent();
        title = 'Pago Móvil';
        break;
      case 'Zelle':
        content = _buildZelleContent();
        title = 'Zelle';
        break;
      case 'Mostrador':
        content = _buildMostradorContent();
        title = 'Mostrador';
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of( context, ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text('Cambiar'),
              onPressed: _resetSelection,
              style: TextButton.styleFrom(
                foregroundColor: AppColor.dark,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        content,
      ],
    );
  }

  Widget _buildPagoMovilContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: Datos para el pago
        Card(
          elevation: 1, // Reduced elevation slightly
          margin: EdgeInsets.zero,
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos para el Pago',
              textScaler: TextScaler.linear(1.2),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Número de Celular: ${SharedService.pagoMovil}',
              textScaler: const TextScaler.linear(1),
            ),
            const SizedBox(height: 2),
            Text(
              'Banco: ${SharedService.pagoMovilBank}',
              textScaler: const TextScaler.linear(1),
            ),
             const SizedBox(height: 2),
            Text(
              'RIF: ${SharedService.pagoMovilCi}',
              textScaler: const TextScaler.linear(1),
            ),
          ],
        ),
          ),
        ),
        const SizedBox(height: 10),

        // Card 2: Identificación y Datos del Pago
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección 1: Identificación del Cliente
                const Text(
                  'Identificación del Pagador',
                  textScaler: TextScaler.linear(1.2),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                value: _selectedTipo,
                isDense: true,
                items: _tipos.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedTipo = newValue);
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                ),
                keyboardType: TextInputType.number,
                  ),
                ),
              ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
               crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                value: _selectedPrefix,
                isDense: true,
                items: _prefixes.map((String prefix) {
                  return DropdownMenuItem<String>(
                    value: prefix,
                    child: Text(prefix),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedPrefix = newValue);
                },
                decoration: const InputDecoration(
                  labelText: 'Prefijo',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0), // Adjust padding
                ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                ),
                keyboardType: TextInputType.phone,
                  ),
                ),
              ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 10, thickness: 1),
                const SizedBox(height: 6),

                // Sección 2: Datos del Pago
                const Text(
                  'Datos del Pago',
                  textScaler: TextScaler.linear(1.2),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                // --- Dropdown de Bancos Actualizado ---
                DropdownButtonFormField<String>(
                  value: _selectedBancoCode,
                  isExpanded: true,
                  isDense: true,
                  hint: const Text(
                    "Seleccione Banco Emisor",
                     style: TextStyle(fontSize: 14),
                  ),
                  items: bancos.map((Map<String, String> banco) {
                    return DropdownMenuItem<String>(
                      value: banco['value']!,
                      child: Text(
                        "${banco['label']!} (${banco['value']!})",
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(1.0),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBancoCode = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Banco Emisor',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0), // Adjust padding
                  ),
                ),
                // --- Fin Dropdown de Bancos ---
                const SizedBox(height: 6),
                TextFormField(
              controller: _referenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              ),
              keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZelleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text( 'Datos para el Pago',
                  textScaler: TextScaler.linear(1.2),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Correo para el pago: ${SharedService.zelle}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Identificación del Pago',
                    textScaler: TextScaler.linear(1.2),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _zelleReferenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Referencia / Confirmación',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMostradorContent() {
    return const Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'El pago será procesado en el mostrador. El pedido quedará pendiente de verificación.',
          textScaler: TextScaler.linear(1.2),
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SizedBox _closeSheet() {
    return const SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel, size: 25,color: Color(0xFF575757),),
          SizedBox(width: 10),
          Text(
            'Cerrar',
            textScaler: TextScaler.linear(1.3),
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF575757)),
          ),
        ],
      ),
    );
  }



}
