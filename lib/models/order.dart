import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  bool? active;
  String? city;
  String? courierCode;
  String? driver;
  Customer? customer;
  String? mode;
  String? shopId;
  String? shopName;
  String? ticket;
  int? statusId;
  String? statusCurrent;
  int? timestamp;
  int? statusTimestamp;
  List? cart;
  num? paidCash;
  num? paidCashChange;
  num? paidEfectivoBs;
  num? paidEfectivoUsd;
  num? paidEfectivoChange;
  num? paidMovilBs;
  String? paidMovilVaucher;
  num? paidMovilUsd;
  num? paidZelle;
  String? paidZelleVaucher;
  num? paidPuntoBs;
  num? paidPuntoUsd;
  num? total;
  num? totalPaid;
  num? totalToPay;
  num? shopDelivery;
  String? couponCode;
  num? couponAmount;
  num? rate;
  List? statusLog;
  int? driverLog;
  String? notes;
  Message? message;
  bool? takeAway = false;

  OrderModel({
    this.id,
    this.active,
    this.city,
    this.courierCode,
    this.driver,
    this.customer,
    this.mode,
    this.shopId,
    this.shopName,
    this.ticket,
    this.statusId,
    this.statusCurrent,
    this.timestamp,
    this.statusTimestamp,
    this.cart,
    this.paidCash,
    this.paidCashChange,
    this.paidEfectivoBs,
    this.paidEfectivoUsd,
    this.paidEfectivoChange,
    this.paidMovilBs,
    this.paidMovilVaucher,
    this.paidMovilUsd,
    this.paidZelle,
    this.paidZelleVaucher,
    this.paidPuntoUsd,
    this.paidPuntoBs,
    this.total,
    this.totalPaid,
    this.totalToPay,
    this.shopDelivery,
    this.couponCode,
    this.couponAmount,
    this.rate,
    this.statusLog,
    this.driverLog,
    this.notes,
    this.message,
    this.takeAway,
  });

  factory OrderModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return OrderModel(
      id: data['id'],
      active: data['active'],
      city: data['city'],
      courierCode: data['courierCode'],
      driver: data['driver'],
      customer: data['customer'],
      mode: data['mode'],
      shopId: data['shopId'],
      shopName: data['shopName'],
      ticket: data['ticket'],
      statusId: data['statusId'],
      statusCurrent: data['statusCurrent'],
      timestamp: data['timestamp'],
      statusTimestamp: data['statusTimestamp'],
      cart: data['cart'],
      paidCash: data['paidCash'],
      paidCashChange: data['paidCashChange'],
      paidEfectivoBs: data['paidEfectivoBs'],
      paidEfectivoUsd: data['paidEfectivoUsd'],
      paidEfectivoChange: data['paidEfectivoChange'],
      paidMovilBs: data['paidMovilBs'],
      paidMovilVaucher: data['paidMovilVaucher'],
      paidMovilUsd: data['paidMovilUsd'],
      paidZelle: data['paidZelle'],
      paidZelleVaucher: data['paidZelleVaucher'],
      paidPuntoUsd: data['paidPuntoUsd'],
      paidPuntoBs: data['paidPuntoBs'],
      total: data['total'],
      totalPaid: data['totalPaid'],
      totalToPay: data['totalToPay'],
      shopDelivery: data['shopDelivery'],
      couponCode: data['couponCode'],
      couponAmount: data['couponAmount'],
      rate: data['rate'],
      statusLog: data['statusLog'],
      driverLog: data['driverLog'],
      notes: data['notes'],
      message: data['message'],
      takeAway: data['takeAway'],
    );
  }

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    active = json['active'];
    city = json['city'];
    courierCode = json['courierCode'];
    driver = json['driver'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
    message = json['message'] != null
        ? Message.fromJson(json['message'])
        : null;
    mode = json['mode'];
    shopId = json['shopId'];
    shopName = json['shopName'];
    ticket = json['ticket'];
    statusCurrent = json['statusCurrent'];
    statusId = json['statusId'];
    timestamp = json['timestamp'];
    statusTimestamp = json['statusTimestamp'];
    cart = json['cart'];
    paidCash = json['paidCash'];
    paidCashChange = json['paidCashChange'];
    paidEfectivoBs = json['paidEfectivoBs'];
    paidEfectivoUsd = json['paidEfectivoUsd'];
    paidEfectivoChange = json['paidEfectivoChange'];
    paidMovilBs = json['paidMovilBs'];
    paidMovilVaucher = json['paidMovilVaucher'];
    paidMovilUsd = json['paidMovilUsd'];
    paidZelle = json['paidZelle'];
    paidZelleVaucher = json['paidZelleVaucher'];
    paidPuntoBs = json['paidPuntoBs'];
    paidPuntoUsd = json['paidPuntoUsd'];
    total = json['total'];
    totalPaid = json['totalPaid'];
    totalToPay = json['totalToPay'];
    shopDelivery = num.parse(json['shopDelivery'].toString());
    couponCode = json['couponCode'];
    couponAmount = json['couponAmount'];
    rate = json['rate'];
    statusLog = json['statusLog'];
    driverLog = json['driverLog'];
    notes = json['notes'];
    takeAway = json['takeAway'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['active'] = active;
    data['city'] = city;
    data['courierCode'] = courierCode;
    data['driver'] = driver;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (message != null) {
      data['message'] = message!.toJson();
    }
    data['mode'] = mode;
    data['shopId'] = shopId;
    data['shopName'] = shopName;
    data['ticket'] = ticket;
    data['statusCurrent'] = statusCurrent;
    data['statusId'] = statusId;
    data['timestamp'] = timestamp;
    data['cart'] = cart;
    data['paidCash'] = paidCash;
    data['paidCashChange'] = paidCashChange;
    data['paidEfectivoBs'] = paidEfectivoBs;
    data['paidEfectivoUsd'] = paidEfectivoUsd;
    data['paidEfectivoChange'] = paidEfectivoChange;
    data['paidMovilBs'] = paidMovilBs;
    data['paidMovilVaucher'] = paidMovilVaucher;
    data['paidMovilUsd'] = paidMovilUsd;
    data['paidZelle'] = paidZelle;
    data['paidZelleVaucher'] = paidZelleVaucher;
    data['paidPuntoBs'] = paidPuntoBs;
    data['paidPuntoUsd'] = paidPuntoUsd;
    data['total'] = total;
    data['totalPaid'] = totalPaid;
    data['totalToPay'] = totalToPay;
    data['shopDelivery'] = shopDelivery;
    data['couponCode'] = couponCode;
    data['couponAmount'] = couponAmount;
    data['rate'] = rate;
    data['statusLog'] = statusLog;
    data['driverLog'] = driverLog;
    data['notes'] = notes;
    data['takeAway'] = takeAway;
    return data;
  }
}

class Customer {
  String? tipo;
  String? name;
  String? cedula;
  String? prefix;
  String? cel;
  String? phone;
  String? location;
  String? address;
  String? source;

  Customer({
    this.tipo,
    this.cedula,
    this.name,
    this.location,
    this.address,
    this.phone,
    this.prefix,
    this.cel,
    this.source,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    tipo = json['tipo'];
    name = json['name'];
    cedula = json['cedula'];
    prefix = json['prefix'];
    cel = json['cel'];
    phone = json['phone'];
    location = json['location'];
    address = json['address'];
    source = json['source'];
  }

  Customer.empty()
      : tipo = '',
        name = '',
        cedula = '',
        prefix = '',
        cel = '',
        phone = '',
        location = '',
        address = '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tipo'] = tipo;
    data['name'] = name;
    data['cedula'] = cedula;
    data['prefix'] = prefix;
    data['cel'] = cel;
    data['phone'] = phone;
    data['location'] = location;
    data['address'] = address;
    data['source'] = source ?? 'express';
    return data;
  }

}

class Message {
  String? body;
  bool? read;
  String? title;
  int? timestamp;

  Message({this.body, this.read, this.title, this.timestamp});

  Message.fromJson(Map<String, dynamic> json) {
    body = json['body'] ?? '';
    read = json['read'] ?? false;
    title = json['title'] ?? 'Fullqueso';
    timestamp = json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['body'] = body;
    data['read'] = read ?? false;
    data['title'] = title ?? 'Fullqueso';
    data['timestamp'] = timestamp;
    return data;
  }

}
