import 'dart:convert';

import 'package:ubiiqueso/models/order.dart';
import 'package:ubiiqueso/models/product.dart';

class CheckoutModel {
  String? quote;
  double? totalGeneral;
  int? driverLog;
  String? driver;
  double? totalPaid;
  double? totalPaidBs;
  bool? active;
  double? rate;
  String? shopWhatsapp;
  double? paidZelle;
  String? shopName;
  double? paidMovilUsd;
  List<StatusLog>? statusLog;
  double? paidPuntoBs;
  bool? isBdv;
  double? paidEfectivoUsd;
  int? statusId;
  int? statusTimestamp;
  String? ticket;
  bool? read;
  ConciliacionBdv? conciliacionBdv;
  String? paidZelleVaucher;
  // String? courierCode;
  double? paidCash;
  String? shopId;
  String? customerId;
  double? totalToPay;
  double? totalToPayBs;
  double? total;
  double? paidEfectivoBs;
  String? paidMovilVaucher;
  double? couponAmount;
  double? shopDelivery;
  // Courier? courier;
  String? shopCode;
  bool? printInvoice;
  String? operatorCode;
  String? operator;
  double? paidMovilBs;
  String? shopLocation;
  int? timestamp;
  double? paidPuntoUsd;
  double? paidCashChange;
  List<Cart>? cart;
  Customer? customer;
  String? shopAddress;
  String? id;
  // Message? message;
  String? statusCurrent;
  String? couponCode;
  String? city;
  String? mode;
  double? paidEfectivoChange;
  String? punto;
  String? beeper;
  String? terminal = 'UBII';
  bool? takeAway = false;
  String? notes;
  String? caja;
  String? ubiiLog;
  bool? isUbii = true;
  bool? syncToLocal = true;

  CheckoutModel({
    this.quote,
    this.totalGeneral,
    this.driverLog,
    this.driver,
    this.totalPaid,
    this.totalPaidBs,
    this.active,
    this.rate,
    this.shopWhatsapp,
    this.paidZelle,
    this.shopName,
    this.paidMovilUsd,
    this.statusLog,
    this.paidPuntoBs,
    this.isBdv,
    this.paidEfectivoUsd,
    this.statusId,
    this.statusTimestamp,
    this.ticket,
    this.read,
    this.conciliacionBdv,
    this.paidZelleVaucher,
    // this.courierCode,
    this.paidCash,
    this.shopId,
    this.customerId,
    this.totalToPay,
    this.totalToPayBs,
    this.total,
    this.paidEfectivoBs,
    this.paidMovilVaucher,
    this.couponAmount,
    this.shopDelivery,
    // this.courier,
    this.shopCode,
    this.printInvoice,
    this.operatorCode,
    this.operator,
    this.paidMovilBs,
    this.shopLocation,
    this.timestamp,
    this.paidPuntoUsd,
    this.paidCashChange,
    this.cart,
    this.customer,
    this.shopAddress,
    this.id,
    // this.message,
    this.statusCurrent,
    this.couponCode,
    this.city,
    this.mode,
    this.paidEfectivoChange,
    this.punto,
    this.beeper,
    this.terminal,
    this.takeAway,
    this.notes,
    this.caja,
    this.ubiiLog,
    this.isUbii,
    this.syncToLocal
  });

  CheckoutModel copyWith({
    String? quote,
    double? totalGeneral,
    int? driverLog,
    String? driver,
    double? totalPaid,
    double? totalPaidBs,
    bool? active,
    double? rate,
    String? shopWhatsapp,
    double? paidZelle,
    String? shopName,
    double? paidMovilUsd,
    List<StatusLog>? statusLog,
    double? paidPuntoBs,
    bool? isBdv,
    double? paidEfectivoUsd,
    int? statusId,
    int? statusTimestamp,
    String? ticket,
    bool? read,
    ConciliacionBdv? conciliacionBdv,
    String? paidZelleVaucher,
    // String? courierCode,
    double? paidCash,
    String? shopId,
    String? customerId,
    double? totalToPay,
    double? totalToPayBs,
    double? total,
    double? paidEfectivoBs,
    String? paidMovilVaucher,
    double? couponAmount,
    double? shopDelivery,
    // Courier? courier,
    String? shopCode,
    bool? printInvoice,
    String? operatorCode,
    String? operator,
    double? paidMovilBs,
    String? shopLocation,
    int? timestamp,
    double? paidPuntoUsd,
    double? paidCashChange,
    List<Cart>? cart,
    Customer? customer,
    String? shopAddress,
    String? id,
    // Message? message,
    String? statusCurrent,
    String? couponCode,
    String? city,
    String? mode,
    double? paidEfectivoChange,
    String? punto,
    String? beeper,
    String? terminal,
    bool? takeAway,
    String? notes,
    String? caja,
    String? ubiiLog,
    bool? isUbii,
    bool? syncToLocal,
  }) =>
      CheckoutModel(
        quote: quote ?? this.quote,
        totalGeneral: totalGeneral ?? this.totalGeneral,
        driverLog: driverLog ?? this.driverLog,
        driver: driver ?? this.driver,
        totalPaid: totalPaid ?? this.totalPaid,
        totalPaidBs: totalPaidBs ?? this.totalPaidBs,
        active: active ?? this.active,
        rate: rate ?? this.rate,
        shopWhatsapp: shopWhatsapp ?? this.shopWhatsapp,
        paidZelle: paidZelle ?? this.paidZelle,
        shopName: shopName ?? this.shopName,
        paidMovilUsd: paidMovilUsd ?? this.paidMovilUsd,
        statusLog: statusLog ?? this.statusLog,
        paidPuntoBs: paidPuntoBs ?? this.paidPuntoBs,
        isBdv: isBdv ?? this.isBdv,
        paidEfectivoUsd: paidEfectivoUsd ?? this.paidEfectivoUsd,
        statusId: statusId ?? this.statusId,
        statusTimestamp: statusTimestamp ?? this.statusTimestamp,
        ticket: ticket ?? this.ticket,
        read: read ?? this.read,
        conciliacionBdv: conciliacionBdv ?? this.conciliacionBdv,
        paidZelleVaucher: paidZelleVaucher ?? this.paidZelleVaucher,
        // courierCode: courierCode ?? this.courierCode,
        paidCash: paidCash ?? this.paidCash,
        shopId: shopId ?? this.shopId,
        customerId: customerId ?? this.customerId,
        totalToPay: totalToPay ?? this.totalToPay,
        totalToPayBs: totalToPayBs ?? this.totalToPayBs,
        total: total ?? this.total,
        paidEfectivoBs: paidEfectivoBs ?? this.paidEfectivoBs,
        paidMovilVaucher: paidMovilVaucher ?? this.paidMovilVaucher,
        couponAmount: couponAmount ?? this.couponAmount,
        shopDelivery: shopDelivery ?? this.shopDelivery,
        // courier: courier ?? this.courier,
        shopCode: shopCode ?? this.shopCode,
        printInvoice: printInvoice ?? this.printInvoice,
        operatorCode: operatorCode ?? this.operatorCode,
        operator:
            operator ?? this.operator,
        paidMovilBs: paidMovilBs ?? this.paidMovilBs,
        shopLocation: shopLocation ?? this.shopLocation,
        timestamp: timestamp ?? this.timestamp,
        paidPuntoUsd: paidPuntoUsd ?? this.paidPuntoUsd,
        paidCashChange: paidCashChange ?? this.paidCashChange,
        cart: cart ?? this.cart,
        customer: customer ?? this.customer,
        shopAddress: shopAddress ?? this.shopAddress,
        id: id ?? this.id,
        // message: message ?? this.message,
        statusCurrent: statusCurrent ?? this.statusCurrent,
        couponCode: couponCode ?? this.couponCode,
        city: city ?? this.city,
        mode: mode ?? this.mode,
        paidEfectivoChange: paidEfectivoChange ?? this.paidEfectivoChange,
        punto: punto ?? this.punto,
        beeper: beeper ?? this.beeper,
        terminal: terminal ?? this.terminal,
        takeAway: takeAway ?? this.takeAway,
        notes: notes ?? this.notes,
        caja: caja ?? this.caja,
        ubiiLog: ubiiLog ?? this.ubiiLog,
        isUbii: isUbii ?? this.isUbii,
        syncToLocal: syncToLocal ?? this.syncToLocal,
      );

  factory CheckoutModel.fromRawJson(String str) =>
      CheckoutModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckoutModel.fromJson(Map<String, dynamic> json) => CheckoutModel(
        quote: json["quote"],
        totalGeneral: json["totalGeneral"],
        driverLog: json["driverLog"],
        driver: json["driver"],
        totalPaid: json["totalPaid"]?.toDouble(),
        totalPaidBs: json["totalPaidBs"]?.toDouble(),
        active: json["active"],
        rate: json["rate"]?.toDouble(),
        shopWhatsapp: json["shopWhatsapp"],
        paidZelle: json["paidZelle"]?.toDouble(),
        shopName: json["shopName"],
        paidMovilUsd: json["paidMovilUsd"]?.toDouble(),
        statusLog: json["statusLog"] == null
            ? []
            : List<StatusLog>.from(
                json["statusLog"]!.map((x) => StatusLog.fromJson(x))),
        paidPuntoBs: json["paidPuntoBs"]?.toDouble(),
        isBdv: json["isBDV"],
        paidEfectivoUsd: json["paidEfectivoUsd"]?.toDouble(),
        statusId: json["statusId"],
        statusTimestamp: json["statusTimestamp"],
        ticket: json["ticket"],
        read: json["read"],
        conciliacionBdv: json["conciliacionBdv"] == null
            ? null
            : ConciliacionBdv.fromJson(json["conciliacionBdv"]),
        paidZelleVaucher: json["paidZelleVaucher"],
        // courierCode: json["courierCode"],
        paidCash: json["paidCash"]?.toDOuble(),
        shopId: json["shopId"],
        customerId: json["customerId"],
        totalToPay: json["totalToPay"]?.toDouble(),
        totalToPayBs: json["totalToPayBs"]?.toDouble(),
        total: json["total"]?.toDouble(),
        paidEfectivoBs: json["paidEfectivoBs"],
        paidMovilVaucher: json["paidMovilVaucher"],
        couponAmount: json["couponAmount"]?.toDOuble(),
        shopDelivery: json["shopDelivery"]?.toDouble(),
        // courier:
        //     json["courier"] == null ? null : Courier.fromJson(json["courier"]),
        shopCode: json["shopCode"],
        printInvoice: json["printInvoice"],
        operatorCode: json["operatorCode"],
        operator: json["operator"],
        paidMovilBs: json["paidMovilBs"]?.toDouble(),
        shopLocation: json["shopLocation"],
        timestamp: json["timestamp"],
        paidPuntoUsd: json["paidPuntoUsd"]?.toDouble(),
        paidCashChange: json["paidCashChange"]?.toDouble(),
        cart: json["cart"] == null
            ? []
            : List<Cart>.from(json["cart"]!.map((x) => Cart.fromJson(x))),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        shopAddress: json["shopAddress"],
        id: json["id"],
        // message: json["message"] == null ? null : Message.fromJson(json["message"]),
        statusCurrent: json["statusCurrent"],
        couponCode: json["couponCode"],
        city: json["city"],
        mode: json["mode"],
        paidEfectivoChange: json["paidEfectivoChange"]?.toDouble(),
        punto: json["punto"],
        beeper: json["beeper"],
        terminal: json["terminal"],
        takeAway: json["takeAway"],
        notes: json["notes"],
        caja: json['caja'],
        ubiiLog: json['ubiiLog'],
        isUbii: json['isUbii'] ?? true,
        syncToLocal: json['syncToLocal'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "quote": quote,
        "totalGeneral": totalGeneral,
        "driverLog": driverLog,
        "driver": driver,
        "totalPaid": totalPaid,
        "totalPaidBs": totalPaidBs,
        "active": active,
        "rate": rate,
        "shopWhatsapp": shopWhatsapp,
        "paidZelle": paidZelle,
        "shopName": shopName,
        "paidMovilUsd": paidMovilUsd,
        "statusLog": statusLog == null
            ? []
            : List<dynamic>.from(statusLog!.map((x) => x.toJson())),
        "paidPuntoBs": paidPuntoBs,
        "isBDV": isBdv,
        "paidEfectivoUsd": paidEfectivoUsd,
        "statusId": statusId,
        "statusTimestamp": statusTimestamp,
        "ticket": ticket,
        "read": read,
        "conciliacionBdv": conciliacionBdv?.toJson(),
        "paidZelleVaucher": paidZelleVaucher,
        // "courierCode": courierCode,
        "paidCash": paidCash,
        "shopId": shopId,
        "customerId": customerId,
        "totalToPay": totalToPay,
        "totalToPayBs": totalToPayBs,
        "total": total,
        "paidEfectivoBs": paidEfectivoBs,
        "paidMovilVaucher": paidMovilVaucher,
        "couponAmount": couponAmount,
        "shopDelivery": shopDelivery,
        // "courier": courier?.toJson(),
        "shopCode": shopCode,
        "printInvoice": printInvoice,
        "operatorCode": operatorCode,
        "operator": operator,
        "paidMovilBs": paidMovilBs,
        "shopLocation": shopLocation,
        "timestamp": timestamp,
        "paidPuntoUsd": paidPuntoUsd,
        "paidCashChange": paidCashChange,
        "cart": cart == null
            ? []
            : List<dynamic>.from(cart!.map((x) => x.toJson())),
        "customer": customer?.toJson(),
        "shopAddress": shopAddress,
        "id": id,
        // "message": message?.toJson(),
        "statusCurrent": statusCurrent,
        "couponCode": couponCode,
        "city": city,
        "mode": mode,
        "paidEfectivoChange": paidEfectivoChange,
        "punto": punto,
        "beeper": beeper,
        "terminal": terminal,
        "takeAway": takeAway,
        "notes": notes,
        "caja": caja,
        "ubiiLog": ubiiLog,
        "isUbii": isUbii,
        "syncToLocal": syncToLocal,
      };
}

class Cart {
  int? quantity;
  int? position;
  String? id;
  bool? active;
  String? additional;
  List<Additional>? additionals;
  bool? activeTienda;
  double? price;
  double? priceBs;
  List<Extras>? extras;
  String? image;
  String? name;
  List<Category>? category;
  bool? home;
  double? total;
  String? image2;
  bool? activeDelivery;
  bool? activeCarro;
  bool? promo;
  String? code;
  int? key;

  Cart({
    this.quantity,
    this.position,
    this.id,
    this.active,
    this.additional,
    this.additionals,
    this.activeTienda,
    this.price,
    this.priceBs,
    this.extras,
    this.image,
    this.name,
    this.category,
    this.home,
    this.total,
    this.image2,
    this.activeDelivery,
    this.activeCarro,
    this.promo,
    this.code,
    this.key,
  });

  Cart copyWith({
    int? quantity,
    int? position,
    String? id,
    bool? active,
    String? additional,
    List<Additional>? additionals,
    bool? activeTienda,
    double? price,
    double? priceBs,
    List<Extras>? extras,
    String? image,
    String? name,
    List<Category>? category,
    bool? home,
    double? total,
    String? image2,
    bool? activeDelivery,
    bool? activeCarro,
    bool? promo,
    String? code,
    int? key,
  }) =>
      Cart(
        quantity: quantity ?? this.quantity,
        position: position ?? this.position,
        id: id ?? this.id,
        active: active ?? this.active,
        additional: additional ?? this.additional,
        additionals: additionals ?? this.additionals,
        activeTienda: activeTienda ?? this.activeTienda,
        price: price ?? this.price,
        priceBs: priceBs ?? this.priceBs,
        extras: extras ?? this.extras,
        image: image ?? this.image,
        name: name ?? this.name,
        category: category ?? this.category,
        home: home ?? this.home,
        total: total ?? this.total,
        image2: image2 ?? this.image2,
        activeDelivery: activeDelivery ?? this.activeDelivery,
        activeCarro: activeCarro ?? this.activeCarro,
        promo: promo ?? this.promo,
        code: code ?? this.code,
        key: key ?? this.key,
      );

  factory Cart.fromRawJson(String str) => Cart.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cart.fromLegayJson(Map<String, dynamic> json) => Cart(
    name: json["name"],
    price: (json['price'] as num?)?.toDouble(),
    quantity: json['quantity'] as int?,
  );

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        quantity: json['quantity'] as int?,

        position: json["position"],
        id: json["_id"],
        active: json["active"],
        additional: json["additional"],
        additionals: json["additionals"] == null
            ? []
            : List<Additional>.from(
                json["additionals"]!.map((x) => Additional.fromJson(x))),
        activeTienda: json["activeTienda"],
        price: (json['price'] as num?)?.toDouble(),
        extras: json["extras"] == null
            ? []
            : List<Extras>.from(
                json["extras"]!.map((x) => Extras.fromJson(x))),
        image: json["image"],
        name: json["name"],
        category: json["category"] == null
            ? []
            : List<Category>.from(
                json["category"]!.map((x) => Category.fromJson(x))),
        home: json["home"],
        total: (json['total'] as num?)?.toDouble(),
        image2: json["image2"],
        activeDelivery: json["activeDelivery"],
        activeCarro: json["activeCarro"],
        promo: json["promo"],
        code: json["code"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "quantity": quantity,
        "position": position,
        "_id": id,
        "active": active,
        "additional": additional,
        "additionals": additionals == null
            ? []
            : List<dynamic>.from(additionals!.map((x) => x.toJson())),
        "activeTienda": activeTienda,
        "price": price,
        "extras": extras == null
            ? []
            : List<dynamic>.from(extras!.map((x) => x.toJson())),
        "image": image,
        "name": name,
        "category": category == null
            ? []
            : List<dynamic>.from(category!.map((x) => x.toJson())),
        "home": home,
        "total": total,
        "image2": image2,
        "activeDelivery": activeDelivery,
        "activeCarro": activeCarro,
        "promo": promo,
        "code": code,
        "key": key,
      };
}

class Courier {
  String? id;
  String? name;
  String? code;
  String? whatsapp1;

  Courier({
    this.id,
    this.name,
    this.code,
    this.whatsapp1,
  });

  Courier copyWith({
    String? id,
    String? name,
    String? code,
    String? whatsapp1,
  }) =>
      Courier(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        whatsapp1: whatsapp1 ?? this.whatsapp1,
      );

  factory Courier.fromRawJson(String str) => Courier.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["_id"],
        name: json["name"],
        code: json["code"],
        whatsapp1: json["whatsapp1"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "code": code,
        "whatsapp1": whatsapp1,
      };
}

class ConciliacionBdv {
  String? cedulaPagador;
  String? fechaPago;
  String? key;
  String? referencia;
  String? bancoOrigen;
  String? telefonoPagador;
  String? telefono;
  String? importe;
  String? timePago;
  String? ticket;
  String? shopName;

  ConciliacionBdv({
    this.cedulaPagador,
    this.fechaPago,
    this.key,
    this.referencia,
    this.bancoOrigen,
    this.telefonoPagador,
    this.telefono,
    this.importe,
    this.timePago,
    this.ticket,
    this.shopName,
  });

  ConciliacionBdv copyWith({
    String? cedulaPagador,
    String? fechaPago,
    String? key,
    String? referencia,
    String? bancoOrigen,
    String? telefonoPagador,
    String? telefono,
    String? importe,
    String? timePago,
    String? ticket,
    String? shopName,
  }) =>
      ConciliacionBdv(
        cedulaPagador: cedulaPagador ?? this.cedulaPagador,
        fechaPago: fechaPago ?? this.fechaPago,
        key: key ?? this.key,
        referencia: referencia ?? this.referencia,
        bancoOrigen: bancoOrigen ?? this.bancoOrigen,
        telefonoPagador: telefonoPagador ?? this.telefonoPagador,
        telefono: telefono ?? this.telefono,
        importe: importe ?? this.importe,
        timePago: timePago ?? this.timePago,
        ticket: ticket ?? this.ticket,
        shopName: shopName ?? this.shopName,
      );

  factory ConciliacionBdv.fromRawJson(String str) =>
      ConciliacionBdv.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ConciliacionBdv.fromMap(Map<String, dynamic> map) {
    return ConciliacionBdv(
      cedulaPagador: map["cedulaPagador"],
      fechaPago: map["fechaPago"],
      key: map["key"],
      referencia: map["referencia"],
      bancoOrigen: map["bancoOrigen"],
      telefonoPagador: map["telefonoPagador"],
      telefono: map["telefono"],
      importe: map["importe"],
      timePago: map["timePago"],
      ticket: map["ticket"],
      shopName: map["shopName"],
    );
  }

  factory ConciliacionBdv.fromJson(Map<String, dynamic> json) =>
      ConciliacionBdv(
        cedulaPagador: json["cedulaPagador"],
        fechaPago: json["fechaPago"],
        key: json["key"],
        referencia: json["referencia"],
        bancoOrigen: json["bancoOrigen"],
        telefonoPagador: json["telefonoPagador"],
        telefono: json["telefono"],
        importe: json["importe"],
        timePago: json["timePago"],
        ticket: json["ticket"],
        shopName: json["shopName"],
      );

  Map<String, dynamic> toJson() => {
        "cedulaPagador": cedulaPagador,
        "fechaPago": fechaPago,
        "key": key,
        "referencia": referencia,
        "bancoOrigen": bancoOrigen,
        "telefonoPagador": telefonoPagador,
        "telefono": telefono,
        "importe": importe,
        "timePago": timePago,
        "ticket": ticket,
        "shopName": shopName,
      };
}

class StatusLog {
  int? date;
  String? status;
  int? id;
  String? message;
  String? user;

  StatusLog({
    this.date,
    this.status,
    this.id,
    this.message,
    this.user
  });

  StatusLog copyWith({
    int? date,
    String? status,
    int? id,
    String? message,
    String? user,
  }) =>
      StatusLog(
        date: date ?? this.date,
        status: status ?? this.status,
        id: id ?? this.id,
        message: message ?? this.message,
        user: user ?? this.user,
      );

  factory StatusLog.fromRawJson(String str) =>
      StatusLog.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
        date: json["date"],
        status: json["status"],
        id: json["id"],
        message: json["message"],
        user: json['user'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "status": status,
        "id": id,
        "message": message,
        "user": user ?? '',
      };
}


class Additional {
  String code;
  String name;
  double price;
  int quantity;
  double total;

  Additional({required this.code, required this.name, required this.price, required this.quantity, required this.total});

  Additional.fromJson(Map<String, dynamic> json) :
    code = json['code'],
    name = json['name'],
    price = json['price'],
    quantity = json['quantity'],
    total = json['total'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = code;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['total'] = total;
    return data;
  }
}
