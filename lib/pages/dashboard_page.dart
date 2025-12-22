
import 'package:ubiiqueso/components/cart/cart.dart';
import 'package:ubiiqueso/components/common/common.dart';
import 'package:ubiiqueso/models/models.dart';
import 'package:ubiiqueso/models/shop.dart' as shop;
import 'package:ubiiqueso/pages/checkout_page.dart';
import 'package:ubiiqueso/services/cart_service.dart';
import 'package:ubiiqueso/services/rate_service.dart';
import 'package:ubiiqueso/services/shared_service.dart';
import 'package:ubiiqueso/theme/color.dart';
import 'package:ubiiqueso/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  shop.ShopModel shopData = shop.ShopModel();
  Map<String, int> quantities = {};
  double rate = 1.0;
  List<String> tempExtras = [];
  List<Additional> tempAdditionals = [];

  String additional = 'xxxxx';
  
  // Buscador
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void filterProducts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products
            .where((product) => 
                product.name!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    filterProducts('');
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar productos...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: filterProducts,
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: clearSearch,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4.0),
            ),
        ],
      ),
    );
  }

  // Funciones helper para sistema de flavours
  bool usesFlavours(ProductModel prod) {
    return prod.useFlavour == true &&
           prod.codeFlavour != null &&
           prod.codeFlavour!.isNotEmpty &&
           (prod.additional == null || 
            prod.additional!.isEmpty ||
            prod.additional is String);
  }

  void loadFlavoursForProduct(ProductModel prod) {
    if (prod.useFlavour == true && prod.codeFlavour != null && prod.codeFlavour!.isNotEmpty) {
      final flavourProduct = products.firstWhere(
        (p) => p.code == prod.codeFlavour,
        orElse: () => ProductModel(),
      );
      
      if (flavourProduct.extras != null && flavourProduct.extras!.isNotEmpty) {
        prod.flavours = List<Extras>.from(flavourProduct.extras!);
      }
    }
  }

  int requiredFlavourQuantity(ProductModel prod, int productQuantity) {
    return (prod.qtyFlavour) * productQuantity;
  }

  bool isFlavourSelectionValid(Map<String, int> flavourQuantities, int required) {
    int totalSelected = flavourQuantities.values.fold(0, (sum, qty) => sum + qty);
    return totalSelected == required;
  }

  String generateFlavourString(Map<String, int> quantities, List<Extras> flavours) {
    List<String> parts = [];
    
    quantities.forEach((flavourId, qty) {
      if (qty > 0) {
        final flavour = flavours.firstWhere((f) => f.sId == flavourId);
        parts.add('$qty x ${flavour.name} | ${flavour.code}');
      }
    });
    
    return parts.join(', ');
  }

  Map<String, int> parseFlavourString(String additionalString, List<Extras> flavours) {
    Map<String, int> quantities = {};
    
    // Inicializar todos a 0
    for (var flavour in flavours) {
      quantities[flavour.sId!] = 0;
    }
    
    if (additionalString.isEmpty) return quantities;
    
    // Parsear: "3 x Past. CARNE | FQ0850, 2 x Past. POLLO | FQ0851"
    final parts = additionalString.split(',').map((e) => e.trim()).toList();
    
    for (final part in parts) {
      final match = RegExp(r'^(\d+)\s*x\s*(.+?)\s*\|\s*(.+)$').firstMatch(part);
      if (match != null) {
        final qty = int.parse(match.group(1)!);
        final name = match.group(2)!.trim();
        final code = match.group(3)!.trim();
        
        final flavour = flavours.where((f) => f.name == name || f.code == code).firstOrNull;
        
        if (flavour != null) {
          quantities[flavour.sId!] = qty;
        }
      }
    }
    
    return quantities;
  }

  Future<void> fetchRate() async {
    rate = await RateService().fetchRate();
  }

  Future<void> fetchProducts() async {
    String uriApi = '$uriBase/shop/query?_id=${SharedService.shopId}';
    final response = await http.get(Uri.parse(uriApi));

    if (response.statusCode == 200) {
      setState(() {
        shopData = shop.ShopModel.fromJson(json.decode(response.body));

        SharedService.shopCity = shopData.city!;
        SharedService.shopName = shopData.name!;
        SharedService.pagoMovil = shopData.pagoMovil ?? '';
        SharedService.pagoMovilCi = shopData.pagoMovilCi ?? '';
        SharedService.pagoMovilBank = shopData.pagoMovilBank ?? '';
        SharedService.keyBdv = shopData.keyBdv ?? '';
        SharedService.zelle = shopData.zelle ?? '';

        products = (json.decode(response.body)['products'] as List)
            .map((productData) {
              var prod = ProductModel.fromJson(productData as Map<String, dynamic>);
              if (prod.priceBs != null && prod.priceBs! > 0) {
                prod.price = prod.priceBs! / rate;
              }
              return prod;
            })
            .where((prod) => prod.activeTienda == true)
            .toList();
        
        // Cargar flavours para productos que los necesiten
        for (var prod in products) {
          loadFlavoursForProduct(prod);
        }
        
        // Inicializar lista filtrada con todos los productos
        filteredProducts = List.from(products);
        
        quantities = {for (var prod in products) prod.sId!: 0};
      });
    } else {
      throw Exception('Failed to load products');
    }
  }


  void _incrementQuantity(int index) {
    if (rate == 1.0) {
      ShowAlert(context, 'Error en tasa BCV, Revise conexión, Refresque APP',
          'error');
      return;
    }
    setState(() {
      products[index].quantity++;
      quantities[products[index].sId!] =
          (quantities[products[index].sId!] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (products[index].quantity > 0) {
        products[index].quantity--;
        quantities[products[index].sId!] =
            quantities[products[index].sId!]! - 1;
      }
    });
  }

  double getTotalAmount() {
    return CartService.getTotalAmount(products, quantities);
  }

  double getTotalAmountBs() {
    return CartService.getTotalAmountBs(products, quantities, rate);
  }

  // String generateNumberTicket() {
  //   final now = DateTime.now();
  //   final DateFormat formatter = DateFormat('yyMMdd-HHmmss');
  //   return formatter.format(now);
  // }

  void _goToCheckout() async {
    // Generar timestamp y número de orden
    final now = DateTime.now();
    final int timestamp = (now.millisecondsSinceEpoch / 1000).round();
    final DateFormat formatter = DateFormat('yyMMdd-HHmmss');
    final String orderNumber = formatter.format(now);

    final filteredProducts =
        products.where((prod) => quantities[prod.sId]! > 0).toList();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          products: filteredProducts,
          quantities: quantities,
          rate: rate,
          ticketNumber: orderNumber,
          timestamp: timestamp,
        ),
      ),
    );
    // _clearSelection();
  }

  @override
  void initState() {
    super.initState();
    fetchRate().then((_) => fetchProducts());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = getTotalAmount();
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primary,
        title: const TitleAppBarWidget(),
      ),
      drawer: const DrawerWidget(),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40, top: 10),
                    itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              List<String> extras = [];
              List<String> additionals = [];
              if (product.extras != null && product.extras!.isNotEmpty) {
                additionals = product.extras!.map((e) => "${e.name} | ${e.code}") .toList();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: product.quantity > 0
                            ? Colors.yellow[200]
                            : Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: AppColor.dark, width: 1.0),
                      ),
                      child: ListTile(
                        isThreeLine: true,
                        dense: true,
                        // leading: SharedService.showImage ? CartShowImage(image: image) : null,
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CartShowProdName(product: product),
                            Row(
                              children: [
                                CartShowPrice(product: product),
                                const SizedBox(width: 6),
                                Flexible(child: CartShowTotal(product: product)),
                              ],
                            ),
                          ],
                        ),
                        subtitle: CartShowSubprod(product: product),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CartButtonQuantity(
                              color: Colors.red,
                              icon: Icons.remove,
                              onTap: () {
                                // Encontrar el índice real en la lista completa de productos
                                final realIndex = products.indexWhere((p) => p.sId == product.sId);
                                if (realIndex == -1) return;
                                
                                if (usesFlavours(product)) {
                                  if (product.quantity == 1) {
                                    // Eliminar directo si cantidad es 1
                                    setState(() {
                                      products[realIndex].quantity = 0;
                                      products[realIndex].additional = '';
                                      quantities[products[realIndex].sId!] = 0;
                                    });
                                  } else {
                                    // Abrir dialog para editar
                                    dialogFlavour(context, product, realIndex);
                                  }
                                } else if (product.extras != null && product.extras!.isNotEmpty) {
                                  dialogExtra(context, additionals, product, extras, realIndex);
                                } else {
                                  _decrementQuantity(realIndex);
                                }
                              },
                            ),
                            CartShowQuantity(product: product),
                            CartButtonQuantity(
                              color: Colors.green,
                              icon: Icons.add,
                              onTap: () {
                                // Encontrar el índice real en la lista completa de productos
                                final realIndex = products.indexWhere((p) => p.sId == product.sId);
                                if (realIndex == -1) return;
                                
                                if (usesFlavours(product)) {
                                  dialogFlavour(context, product, realIndex);
                                } else if (product.extras != null && product.extras!.isNotEmpty) {
                                  dialogExtra(context, additionals, product, extras, realIndex);
                                } else {
                                  _incrementQuantity(realIndex);
                                }
                              },
                            ),
                            // const SizedBox(width: 16),
                            // CartShowTotal(product: product),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
                  ),
                ),
              ],
            ),
          bottomNavigationBar: (totalAmount > 0) ? Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            color: Colors.red,
            child: InkWell(
              onTap: () => _goToCheckout(),
              child: RichText(
              text: TextSpan(
                children: [
                TextSpan(
                  text: 'Total: \$${getTotalAmount().toStringAsFixed(2)}\n',
                  style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'Bs ${NumberFormat.currency(locale: 'en_US', symbol: '').format(getTotalAmountBs())}',
                  style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  ),
                ),
                ],
              ),
              textAlign: TextAlign.center,
              ),
            ),
          ) : null,
    );
  }

  Future<dynamic> dialogFlavour(
      BuildContext context,
      ProductModel prod,
      int index
      ) {
    // Cerrar el teclado antes de mostrar el dialog
    FocusScope.of(context).unfocus();
    
    Map<String, int> tempFlavourQuantities = {};
    int tempQuantity = prod.quantity == 0 ? 1 : prod.quantity; // Trabajar con copia temporal
    
    // Inicializar cantidades
    if (prod.flavours != null) {
      for (var flavour in prod.flavours!) {
        tempFlavourQuantities[flavour.sId!] = 0;
      }
      
      // Si hay selección previa, cargarla
      if (prod.additional != null && prod.additional!.isNotEmpty) {
        tempFlavourQuantities = parseFlavourString(prod.additional!, prod.flavours!);
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(6),
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, dialogSetState) {
              int totalSelected = tempFlavourQuantities.values.fold(0, (sum, qty) => sum + qty);
              int required = requiredFlavourQuantity(prod, tempQuantity);
              bool isValid = isFlavourSelectionValid(tempFlavourQuantities, required);
              
              return Container(
                width: MediaQuery.of(context).size.width * 0.99,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 1.0,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header con validación
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isValid ? Icons.check_circle : Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selecciona exactamente $required sabores',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prod.name!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            textScaler: const TextScaler.linear(0.8),
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalSelected / $required seleccionados',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de sabores
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (prod.flavours != null)
                              for (var flavour in prod.flavours!)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColor.dark,
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            flavour.name ?? '',
                                            maxLines: 3,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            CartButtonQuantity(
                                              color: Colors.red,
                                              icon: Icons.remove,
                                              onTap: tempFlavourQuantities[flavour.sId!]! > 0 
                                                ? () {
                                                    dialogSetState(() {
                                                      tempFlavourQuantities[flavour.sId!] = 
                                                        tempFlavourQuantities[flavour.sId!]! - 1;
                                                    });
                                                  }
                                                : null,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                tempFlavourQuantities[flavour.sId!].toString(),
                                                textScaler: const TextScaler.linear(1.5),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white
                                                ),
                                              ),
                                            ),
                                            CartButtonQuantity(
                                              color: Colors.green,
                                              icon: Icons.add,
                                              onTap: totalSelected < required 
                                                ? () {
                                                    dialogSetState(() {
                                                      tempFlavourQuantities[flavour.sId!] = 
                                                        tempFlavourQuantities[flavour.sId!]! + 1;
                                                    });
                                                  }
                                                : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Control de cantidad del producto
                    Container(
                      color: Colors.grey[700],
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Cantidad: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                          CartButtonQuantity(
                            color: Colors.red,
                            icon: Icons.remove,
                            onTap: tempQuantity > 1 
                              ? () {
                                  dialogSetState(() {
                                    tempQuantity--;
                                    // Recalcular cantidades de flavours proporcionalmente
                                    Map<String, int> newQuantities = {};
                                    tempFlavourQuantities.forEach((key, value) {
                                      newQuantities[key] = (value * tempQuantity / (tempQuantity + 1)).round();
                                    });
                                    tempFlavourQuantities = newQuantities;
                                  });
                                }
                              : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              tempQuantity.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          CartButtonQuantity(
                            color: Colors.green,
                            icon: Icons.add,
                            onTap: () {
                              dialogSetState(() {
                                tempQuantity++;
                                // Mantener las cantidades de flavours y dejar que el usuario ajuste
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Botones de acción
                    Container(
                      width: double.infinity,
                      color: AppColor.primary,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isValid ? AppColor.dark : Colors.grey,
                            ),
                            onPressed: isValid ? () {
                              setState(() {
                                // Generar string de sabores
                                String flavourString = generateFlavourString(tempFlavourQuantities, prod.flavours!);
                                
                                // Actualizar producto
                                prod.additional = flavourString;
                                products[index].additional = flavourString;
                                
                                // Actualizar cantidad con valor temporal
                                products[index].quantity = tempQuantity;
                                quantities[products[index].sId!] = tempQuantity;
                              });
                              Navigator.pop(context);
                            } : null,
                            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<dynamic> dialogExtra(
      BuildContext context,
      List<String> additionals,
      ProductModel prod,
      List<String> extras,
      int index
      ) {
    // Cerrar el teclado antes de mostrar el dialog
    FocusScope.of(context).unfocus();
    
    tempExtras.clear();
    if (prod.additional != null && prod.additional!.isNotEmpty) {
      List<String> selectedItems = prod.additional!.split(', ');

      for (String item in selectedItems) {
        // Parse items like "2 x Extra Name | Code"
        if (item.contains(' x ')) {
          int count = int.tryParse(item.split(' x ')[0]) ?? 0;
          String extraItem = item.split(' x ')[1];

          // Find the matching extra in additionals
          String? matchingExtra = additionals.firstWhere(
                  (extra) => extra.split(' | ')[0] == extraItem.split(' | ')[0],
              orElse: () => ''
          );

          // Add the extra 'count' times to tempExtras
          for (int i = 0; i < count; i++) {
            tempExtras.add(matchingExtra);
          }
        }
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(6),
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.99,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 1.0,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
          Container(
            width: double.infinity,
            color: AppColor.primary,
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                const Text(
            'ADICIONALES',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
                ),
                Text(
            prod.name!,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(0.6),
            style: const TextStyle(
              color: Colors.white,
            ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
            for (var extra in additionals)
              StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColor.dark,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Text( extra.split(' | ').first, maxLines: 3, style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis), ),
                ),
                Row(
                  children: [
                    CartButtonQuantity(
                      color: Colors.red,
                      icon: Icons.remove,
                      onTap: (){
                        setState(() {
                          if (tempExtras.contains(extra)) {
                            tempExtras.remove(extra);
                          }
                        });
                      } ,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0),
                          child: Text(
                            tempExtras
                                .where((e) => e == extra)
                                .length
                                .toString(),
                            textScaler: const TextScaler.linear(1.5),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                    ),

                    CartButtonQuantity(
                      color: Colors.green,
                      icon: Icons.add,
                      onTap: () {
                        setState(() {
                          tempExtras.add(extra);
                        });
                      },
                    ),
                  ],
                ),

                    ],
                  ),
                ),
              ),
                  );

                },
              ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColor.primary,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.dark,
            ),
            onPressed: () {
              setState(() {
                Map<String, int> extraCounts = {};
                for (var extra in tempExtras) {
                  if (extraCounts.containsKey(extra)) {
              extraCounts[extra] = extraCounts[extra]! + 1;
                  } else {
              extraCounts[extra] = 1;
                  }
                }
                List<String> additionalList = [];
                extraCounts.forEach((extra, count) {
                  if (count > 0) {
              additionalList.add('$count x $extra');
                  } else {
              additionalList.add(extra);
                  }
                });
                String additionalString = additionalList.join(', ');

                prod.additional = additionalString;
                products[index].additional = additionalString;
                products[index].quantity = tempExtras.length;
                quantities[products[index].sId!] = tempExtras.length;
                tempExtras.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
              ],
            ),
          ),
        );
      },
    );
  }

}