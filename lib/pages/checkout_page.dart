import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:ubiiqueso/components/checkout/checkout.dart';
import 'package:ubiiqueso/components/common/app_bar_checkout_widget.dart';
import 'package:ubiiqueso/components/common/show_alert.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/pages/dashboard_page.dart';
import 'package:ubiiqueso/services/cart_service.dart';
import 'package:ubiiqueso/services/customer_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:ubiiqueso/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:ubiiqueso/infrastructure/functions/help_funtions/help_funtions.dart';
import 'package:ubiiqueso/infrastructure/models/record_response_model.dart';

class CheckoutPage extends StatefulWidget {
  final List<ProductModel> products;
  final Map<String, int> quantities;
  final double rate;
  final String ticketNumber;
  final int timestamp;

  const CheckoutPage(
      {super.key,
      required this.products,
      required this.quantities,
      required this.rate,
      required this.ticketNumber,
      required this.timestamp});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String codeResult = "FQ";
  String messageResult = "POS ERROR";
  String confirmNum = "";
  String referencia = "";
  String tipoTarjeta = "";
  String terminal = "DSL";

  final DoTransaction _dslService = DoTransaction();
  final PrinterPos _printer = PrinterPos();

  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _beeperController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _codigoPuntoController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _takeAwayController = TextEditingController();
  final List<String> phoneCodes = ['0412', '0414', '0424', '0416', '0426'];
  String selectedPhoneCode = '0412';
  final List<String> tipos = ['V', 'E', 'J', 'G'];
  String selectedTipo = 'V';
  final List<String> codigoPuntoValues = puntosList;
  String selectedCodigoPunto = SharedService.punto;
  // bool isPaymentValid = false;
  bool isProcessing = false;
  final MoneyMaskedTextController _montoController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'Bs ',
  );
  late CheckoutModel checkout;
  bool saving = false;
  bool takeAway = false;

  double totalPaid = 0;
  double totalPaidBs = 0;
  double paidPuntoBs = 0;
  double paidPuntoUsd = 0;

  double getTotalAmount() {
    return CartService.getTotalAmount(widget.products, widget.quantities);
  }

  double getTotalAmountBs() {
    return CartService.getTotalAmountBs(
        widget.products, widget.quantities, widget.rate);
  }

  Future _searchCustomer() async {
    if (_cedulaController.text.isNotEmpty) {
      final customer = await queryCustomerService(_cedulaController.text);
      if (customer.cedula == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente no encontrado')),
        );
      } else {
        setState(() {
          _tipoController.text = customer.tipo ?? 'V';
          selectedTipo = customer.tipo ?? 'V';
          _nombreController.text = customer.name ?? '';
          _telefonoController.text = customer.cel ?? '';
          selectedPhoneCode = customer.prefix ?? '0412';
        });
      }
    }
  }

  void _validateAndCheckout() {
    if (_cedulaController.text.isEmpty ||
            _nombreController.text.isEmpty ||
            _telefonoController.text.isEmpty
        // || _beeperController.text.isEmpty
        //|| _referenciaController.text.isEmpty
        ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }
    checkout.customer = Customer(
        tipo: _tipoController.text,
        cedula: _cedulaController.text,
        name: _nombreController.text,
        prefix: selectedPhoneCode,
        cel: _telefonoController.text,
        phone: '$selectedPhoneCode${_telefonoController.text}',
        location: '',
        address: '',
        source: 'express');
    checkout.customerId = _cedulaController.text;

    final totalBs = getTotalAmountBs().toStringAsFixed(2);
    final totalWithoutDot = transformarAmountaEntero(totalBs);
    _procesarPagoDSL(totalWithoutDot);
  }

  void _fillCheckout() {

    final String numberTicket = widget.ticketNumber;

    String beeper = _beeperController.text;

    checkout.notes = checkout.notes ?? '';
    checkout.takeAway = checkout.takeAway ?? false;
    checkout.operator = SharedService.operatorName;
    checkout.operatorCode = SharedService.operatorCode;

    checkout.active = true;
    checkout.id = widget.timestamp.toString();
    checkout.city = SharedService.shopCity;
    checkout.shopId = SharedService.shopId;
    checkout.shopCode = SharedService.shopCode;
    checkout.shopName = SharedService.shopName;
    checkout.operatorCode = SharedService.operatorCode;
    checkout.operator = SharedService.operatorName;
    checkout.mode = 'tienda';
    checkout.caja = 'CAJA1';
    checkout.paidPuntoBs = double.parse(getTotalAmountBs().toStringAsFixed(2));
    checkout.paidPuntoUsd = double.parse(getTotalAmount().toStringAsFixed(2));
    checkout.ticket = numberTicket;
    checkout.statusId = 2;
    checkout.statusCurrent = 'Preparación';
    checkout.statusTimestamp = widget.timestamp;
    checkout.timestamp = widget.timestamp;
    checkout.statusLog = [
      StatusLog(
          id: 0,
          date: widget.timestamp,
          status: 'Solicitado',
          message: 'Pedido iniciado',
          user: SharedService.operatorName),
      StatusLog(
          id: 1,
          date: widget.timestamp,
          status: 'Verificado',
          message: 'Pago verificado',
          user: SharedService.operatorName),
      StatusLog(
          id: 2,
          date: widget.timestamp,
          status: 'Preparación',
          message: 'Pedido en preparación',
          user: SharedService.operatorName),
      StatusLog(
          id: 3,
          date: 0,
          status: 'Despachado',
          message: 'Pedido en camino',
          user: ''),
      StatusLog(
          id: 4,
          date: 0,
          status: 'Entregado',
          message: 'Pedido entregado',
          user: ''),
    ];
    // checkout.totalPaid = _montoController.numberValue;
    checkout.total = getTotalAmount();
    checkout.totalPaid = getTotalAmount();
    checkout.totalToPay = getTotalAmount();
    checkout.rate = widget.rate;
    checkout.read = false;
    checkout.punto = selectedCodigoPunto;
    checkout.beeper = beeper;
    // checkout.notes = notes;
    // checkout.takeAway = takeAway;

    // checkout.courier = Courier();
    // checkout.courierCode = '';
    // checkout.message = Message();
    checkout.printInvoice = false;

    checkout.paidMovilUsd = 0;
    checkout.paidMovilBs = 0;
    checkout.paidMovilVaucher = '';
    checkout.paidZelle = 0;
    checkout.paidZelleVaucher = '';
    checkout.paidEfectivoUsd = 0;
    checkout.paidEfectivoBs = 0;
    checkout.paidEfectivoChange = 0;
    checkout.paidCash = 0;
    checkout.paidCashChange = 0;
    checkout.totalGeneral = 0;

    checkout.couponCode = '';
    checkout.couponAmount = 0;
    checkout.driver = '';
    checkout.driverLog = 0;
    // checkout.conciliacionBdv = ConciliacionBdv();
    checkout.isBdv = false;
    checkout.quote = '';
    checkout.shopAddress = '';
    checkout.shopLocation = '';
    checkout.shopDelivery = 0;
    checkout.shopWhatsapp = '';
    checkout.terminal = 'DSL';
    checkout.isUbii = false;
    checkout.syncToLocal = true;

    SharedService.punto = selectedCodigoPunto;
  }

  void _procesarPagoDSL(String amount) async {
    String numOrder = widget.ticketNumber.length > 6
        ? widget.ticketNumber.substring(widget.ticketNumber.length - 6)
        : widget.ticketNumber;

    try {
      checkout.statusId = 0;
      checkout.statusCurrent = 'Solicitado';
      checkout.totalPaid = 0;
      checkout.totalPaidBs = 0;
      checkout.paidPuntoBs = 0;
      checkout.paidPuntoUsd = 0;

      await _processCheckout(false); // Guardar sin finalizar (Pedido sin pago)

      String cardholderId = checkout.customerId ?? '111111';

      // Llamar a DSL doTransaction (transType: 1 = PAYMENT)
      final result = await _dslService.doTransaction(
        amount,
        cardholderId,
        '1',
        numOrder,
        1, // transType: 1 = PAYMENT
      );

      // Parsear respuesta DSL
      if (result is RecordResponse) {
        setState(() {
          // result == 0 significa éxito en DSL
          if (result.result == 0) {
            checkout.statusId = 2;
            checkout.statusCurrent = 'Preparación';
            checkout.totalPaid = totalPaid;
            checkout.totalPaidBs = totalPaidBs;
            checkout.paidPuntoBs = paidPuntoBs;
            checkout.paidPuntoUsd = paidPuntoUsd;
            checkout.terminal = result.terminalId ?? 'DSL';
            checkout.isUbii = false;
            checkout.ubiiLog = '${result.rrn ?? ''} | ${result.referenceNumber ?? ''}';

            // IMPRIMIR COMPROBANTE
            _imprimirComprobante(result);

            _processCheckout(true); // Guardar y finalizar
          } else {
            // Pago rechazado - imprimir comprobante de error
            _imprimirComprobanteError(result);

            ShowAlert(context, "Error procesando pago - Código: ${result.errorCode}", 'error');
            setState(() {
              saving = false;
            });
            return;
          }
        });
      } else {
        ShowAlert(context, "Error: Respuesta inválida del POS", 'error');
        setState(() {
          saving = false;
        });
      }
    } catch (e) {
      // Intentar extraer información del error para imprimir comprobante
      RecordResponse? errorResponse;
      String errorMessage = "Error procesando pago";

      try {
        // Intentar parsear el JSON del error
        final errorString = e.toString();

        // Extraer JSON del mensaje de error
        final jsonStart = errorString.indexOf('{');
        final jsonEnd = errorString.lastIndexOf('}');

        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = errorString.substring(jsonStart, jsonEnd + 1);
          final errorJson = jsonDecode(jsonString);

          // Crear RecordResponse del error
          errorResponse = RecordResponse.fromJson(errorJson);

          // Extraer errorCode para mensaje
          final errorCode = errorJson['errorCode'] ?? errorJson['result'] ?? 'desconocido';
          errorMessage = "Error procesando pago - Código: $errorCode";
        } else {
          errorMessage = "Error procesando pago";
        }
      } catch (parseError) {
        errorMessage = "Error procesando pago";
      }

      // Mostrar alerta con mensaje limpio
      ShowAlert(context, errorMessage, 'error');

      // IMPRIMIR COMPROBANTE DE ERROR si se pudo parsear
      if (errorResponse != null) {
        _imprimirComprobanteError(errorResponse);
      }

      setState(() {
        saving = false;
      });
    }
  }

  void _imprimirComprobante(RecordResponse response) async {
    try {
      final now = DateTime.now();
      final fecha = DateFormat('dd/MM/yyyy').format(now);
      final hora = DateFormat('HH:mm:ss').format(now);
      final montoFormateado = getTotalAmountBs().toStringAsFixed(2);

      await _printer.imprimirPos(
        checkout.customer?.name ?? 'Cliente',
        checkout.customer?.cedula ?? '',
        montoFormateado,
        '', // ctaContrato - no aplica
        response.referenceNumber ?? '',
        fecha,
        hora,
        response.batchNum ?? '',
        '', // afiliado - extraer si está disponible
        response.terminalId ?? '',
        response.deviceSerial ?? '',
        response.traceNumber ?? '',
      );
    } catch (e) {
      // No bloqueamos el flujo si falla la impresión
    }
  }

  void _imprimirComprobanteError(RecordResponse errorResponse) async {
    try {
      final now = DateTime.now();
      final fecha = DateFormat('dd/MM/yyyy').format(now);
      final hora = DateFormat('HH:mm:ss').format(now);
      final montoFormateado = getTotalAmountBs().toStringAsFixed(2);

      // Imprimir comprobante con información del error
      await _printer.imprimirPos(
        checkout.customer?.name ?? 'Cliente',
        checkout.customer?.cedula ?? '',
        montoFormateado,
        'ERROR', // Indicador de error en lugar de ctaContrato
        errorResponse.referenceNumber ?? 'N/A',
        fecha,
        hora,
        errorResponse.batchNum ?? 'N/A',
        'ERROR', // Marcador de error
        errorResponse.terminalId ?? 'N/A',
        errorResponse.deviceSerial ?? 'N/A',
        errorResponse.traceNumber ?? 'N/A',
      );
    } catch (e) {
      // No bloqueamos el flujo si falla la impresión
    }
  }

  void _initDSLService() async {
    try {
      await _dslService.bindService();
      // Delay obligatorio de 500ms después de bindService
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Error inicializando DSL Service
    }
  }

  @override
  void initState() {
    super.initState();
    _initDSLService();
    checkout = CheckoutModel();
    _montoController.text = NumberFormat.currency(locale: 'en_US', symbol: '')
        .format(getTotalAmountBs());

    checkout.cart = widget.products.map((e) {
      final quantity = widget.quantities[e.sId] ?? 0;
      final total = e.price! * quantity;
      final price = e.price!;
      List<Additional> myAdditionals = [];

      String myAdditional = e.additional
              ?.split(', ')
              .map((item) => item.split(' | ').first)
              .join(', ') ??
          '';

      if (e.additional != null && e.additional!.isNotEmpty) {
        myAdditionals = e.additional!.split(', ').map((item) {
          final parts = item.split(' | ');
          final quantityAndName = parts[0].split(' x ');
          final quantity = int.parse(quantityAndName[0]);
          final name = quantityAndName[1];
          final code = parts[1];
          final partTotal = price * quantity;
          return Additional(
              code: code,
              name: name,
              price: price,
              quantity: quantity,
              total: partTotal);
        }).toList();
      }

      return Cart(
          id: e.sId,
          name: e.name,
          price: e.price,
          quantity: quantity,
          total: total,
          image: e.image,
          code: e.code,
          category: e.category,
          image2: e.image2,
          home: e.home,
          promo: e.promo,
          extras: e.extras,
          active: e.active,
          activeDelivery: e.activeDelivery,
          activeCarro: e.activeCarro,
          activeTienda: e.activeTienda,
          position: e.position,
          additional: myAdditional,
          additionals: myAdditionals);
    }).toList();
    _fillCheckout();
    totalPaid = checkout.totalPaid ?? 0;
    totalPaidBs = checkout.totalPaidBs ?? 0;
    paidPuntoBs = checkout.paidPuntoBs ?? 0;
    paidPuntoUsd = checkout.paidPuntoUsd ?? 0;

    setState(() {
      saving = false;
    });
  }

  @override
  void dispose() {
    _referenciaController.dispose();
    _codigoPuntoController.dispose();
    _montoController.dispose();
    _tipoController.dispose();
    _cedulaController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _beeperController.dispose();
    _notesController.dispose();
    _takeAwayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBarCheckoutWidget(checkout: checkout),
      body: widget.products.isEmpty
          ? const Center(child: Text('No hay productos en el carrito'))
          : ListView.builder(
              itemCount: widget.products.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.products.length) {
                  return _registerPayment();
                }
                final product = widget.products[index];
                String image = '$uriServer/products/${product.image}';
                List<String> subProducts =
                    product.additional?.split(', ') ?? [];
                return Column(
                  children: [
                    const SizedBox(height: 5),

                    // Mostrar el producto principal (siempre para productos con flavours, solo si no hay extras para productos tradicionales)
                    if (subProducts.isEmpty || (product.useFlavour == true))
                      CheckoutTileProduct(
                          imagePath: image,
                          productName: product.name!,
                          productPrice: product.price!,
                          productQuantity: product.quantity),

                    // Mostrar cada subproducto adicional
                    if (product.useFlavour == true && subProducts.isNotEmpty)
                      // Para productos con flavours, mostrar sabores indentados con precio 0
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          children: [
                            for (var subProduct in subProducts)
                              if (subProduct.trim().isNotEmpty &&
                                  subProduct.contains(' x ') &&
                                  subProduct.contains('|'))
                                CheckoutTileSubproduct(
                                    subProduct: subProduct,
                                    imagePath: image,
                                    price: 0), // Precio 0 para sabores
                          ],
                        ),
                      )
                    else
                      // Para productos tradicionales con extras
                      for (var subProduct in subProducts)
                        if (subProduct.trim().isNotEmpty &&
                            subProduct.contains(' x ') &&
                            subProduct.contains('|'))
                          CheckoutTileSubproduct(
                              subProduct: subProduct,
                              imagePath: image,
                              price: product.price!),
                  ],
                );
              },
            ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => _showPaymentBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.dark, // Background color
                  foregroundColor: Colors.white, // Text color
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.25, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: _validateAndCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary, // Background color
                  foregroundColor: Colors.white, // Text color
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.75, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PAGAR',
                            textScaler: TextScaler.linear(1.5),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                // : Text(
                //   NumberFormat.currency(locale: 'en', symbol: 'Bs.')
                //       .format(getTotalAmountBs()),
                //   textScaler: const TextScaler.linear(1.5),
                //   overflow: TextOverflow.ellipsis,
                //   style: const TextStyle(
                //       color: Colors.white, fontWeight: FontWeight.bold),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerPayment() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CheckoutTotalToPay(
            totalToPay: getTotalAmount(),
            totalToPayBs: getTotalAmountBs(),
            rate: widget.rate,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              // Tipo
              Row(
                children: [
                  Container(
                    color: Colors.grey.shade700,
                    width: MediaQuery.of(context).size.width * 0.12,
                    padding: const EdgeInsets.only(left: 12),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.grey.shade900,
                      hint: const Text(''),
                      value: selectedTipo,
                      isExpanded: true,
                      iconSize: 16,
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTipo = newValue!;
                          _tipoController.text = selectedTipo;
                        });
                      },
                      items:
                          tipos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.28,
                child: TextFormField(
                  controller: _cedulaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputFieldDecoration("cedula"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                flex: 2,
                child: TextFormField(
                  onTap: () async {
                    setState(() {
                      isProcessing = true;
                    });
                    await _searchCustomer();
                    setState(() {
                      isProcessing = false;
                    });
                  },
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputFieldNameDecoration(isProcessing),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Container(
                      color: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey.shade900,
                        hint: const Text('Código'),
                        value: selectedPhoneCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPhoneCode = newValue!;
                          });
                        },
                        items: phoneCodes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _telefonoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputFieldDecoration('Teléfono'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  controller: _beeperController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputFieldDecoration('Beeper/Mesa'),
                  onChanged: (value) {
                    setState(() {
                      checkout.beeper = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Checkbox(
                        checkColor: Colors.red,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.yellow;
                          }
                          return Colors.white;
                        }),
                        side: BorderSide(
                          color: takeAway == true
                              ? Colors.red
                              : Colors.black, // Border color
                          width: 1.5, // Border width
                        ),
                        value: takeAway,
                        onChanged: (bool? value) {
                          setState(() {
                            takeAway = value!;
                            checkout.takeAway = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Para Llevar',
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            decoration: inputFieldDecoration('Notas'),
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                checkout.notes = value;
              });
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _processCheckout(finishIntent) async {
    setState(() {
      saving = true;
    });
    try {
      // generar ID de ORDEN
      if (checkout.id != null && !checkout.id!.contains('_')) { // si no tiene guion bajo, significa que no se ha generado
        checkout.id = '${widget.timestamp}_${checkout.customerId!}';
      }
      await db.collection('orders').doc(checkout.id).set(checkout.toJson());
      await saveCustomerService(checkout.customer!);

    } catch (e) {
      ShowAlert(context, 'Error al guardar la orden. Reporte pago', 'error');
    }
    finally {
      setState(() {
        saving = false;
      });
    }

    if (finishIntent) {
      ShowAlert(context, "Orden procesada satisfactoriamente", 'success');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );

      // _dialogAfterSave();
    }
  }

  void _showPaymentBottomSheet(BuildContext context) {
    if (_cedulaController.text.isEmpty ||
            _nombreController.text.isEmpty ||
            _telefonoController.text.isEmpty
        // || _beeperController.text.isEmpty
        //|| _referenciaController.text.isEmpty
        ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }
    checkout.customer = Customer(
        tipo: _tipoController.text,
        cedula: _cedulaController.text,
        name: _nombreController.text,
        prefix: selectedPhoneCode,
        cel: _telefonoController.text,
        phone: '$selectedPhoneCode${_telefonoController.text}',
        location: '',
        address: '',
        source: 'DSL');
    checkout.customerId = _cedulaController.text;

    _fillCheckout();
    checkout.statusId = 0;
    checkout.statusCurrent = 'Solicitado';
    checkout.statusLog?[1].date = 0;
    checkout.statusLog?[1].user = '';
    checkout.statusLog?[2].date = 0;
    checkout.statusLog?[2].user = '';
    checkout.paidPuntoBs = 0;
    checkout.paidPuntoUsd = 0;

    checkout.totalToPay = getTotalAmount();
    checkout.totalToPayBs = getTotalAmountBs();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          padding: const EdgeInsets.all(20.0),
          child: CheckoutBottomsheetPayments(checkout: checkout),
        );
      },
    );
  }
}
