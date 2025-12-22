import 'package:ubiiqueso/models/product.dart';

class CartService {

  static double getTotalAmount(
      List<ProductModel> products, Map<String, int> quantities) {
    double total = 0.0;
    for (var prod in products) {
      total += prod.price! * (quantities[prod.sId] ?? 0);
    }
    return total;
  }

  static double getTotalAmountBs(
      List<ProductModel> products, Map<String, int> quantities, double rate) {
    double total = 0.0;
    for (var prod in products) {
      total += prod.price! * (quantities[prod.sId] ?? 0);
    }
    return total * rate;
  }

}


