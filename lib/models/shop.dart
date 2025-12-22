class ShopModel {
  String? sId;
  String? name;
  String? code;
  String? city;
  bool? igtf;
  List<String>? mode;
  List<Products>? products;
  Extras? manager;
  Extras? operator;
  Extras? operator2;
  String? pagoMovil;
  String? zelle;
  String? pagoMovilBank;
  String? pagoMovilCi;
  bool? active;
  bool? activeTienda;
  bool? useTienda;
  bool? activeBdv;
  String? keyBdv;

  ShopModel(
      {
      this.sId,
      this.name,
      this.code,
      this.city,
      this.igtf,
      this.mode,
      this.products,
      this.manager,
      this.operator,
      this.operator2,
      this.pagoMovil,
      this.zelle,
      this.pagoMovilBank,
      this.pagoMovilCi,
      this.active,
      this.activeTienda,
      this.useTienda,
      this.activeBdv,
      this.keyBdv
    });

  ShopModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    code = json['code'];
    city = json['city'];
    igtf = json['igtf'];
    mode = json['mode'].cast<String>();
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    manager =
        json['manager'] != null ? new Extras.fromJson(json['manager']) : null;
    operator =
        json['operator'] != null ? new Extras.fromJson(json['operator']) : null;
    operator2 = json['operator2'] != null
        ? new Extras.fromJson(json['operator2'])
        : null;
    pagoMovil = json['pagoMovil'];
    zelle = json['zelle'];
    pagoMovilBank = json['pagoMovilBank'];
    pagoMovilCi = json['pagoMovilCi'];
    active = json['active'];
    activeTienda = json['activeTienda'];
    useTienda = json['useTienda'];
    activeBdv = json['activeBdv'];
    keyBdv = json['keyBdv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['code'] = this.code;
    data['city'] = this.city;
    data['igtf'] = this.igtf;
    data['mode'] = this.mode;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.manager != null) {
      data['manager'] = this.manager!.toJson();
    }
    if (this.operator != null) {
      data['operator'] = this.operator!.toJson();
    }
    if (this.operator2 != null) {
      data['operator2'] = this.operator2!.toJson();
    }
    data['pagoMovil'] = this.pagoMovil;
    data['zelle'] = this.zelle;
    data['pagoMovilBank'] = this.pagoMovilBank;
    data['pagoMovilCi'] = this.pagoMovilCi;
    data['active'] = this.active;
    data['activeTienda'] = this.activeTienda;
    data['useTienda'] = this.useTienda;
    data['activeBdv'] = this.activeBdv;
    data['keyBdv'] = this.keyBdv;
    return data;
  }
}

class Products {
  String? sId;
  String? code;
  List<Category>? category;
  int? position;
  String? name;
  double? price;
  String? image;
  String? image2;
  bool? home;
  bool? promo;
  List<Extras>? extras;
  bool? active;
  bool? activeDelivery;
  bool? activeCarro;
  bool? activeTienda;

  Products(
      {this.sId,
      this.code,
      this.category,
      this.position,
      this.name,
      this.price,
      this.image,
      this.image2,
      this.home,
      this.promo,
      this.extras,
      this.active,
      this.activeDelivery,
      this.activeCarro,
      this.activeTienda});

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
    position = json['position'];
    name = json['name'];
    price = json['price'] is int ? json['price'].toDouble() : json['price'];
    image = json['image'];
    image2 = json['image2'];
    home = json['home'];
    promo = json['promo'];
    if (json['extras'] != null) {
      extras = <Extras>[];
      json['extras'].forEach((v) {
        extras!.add(new Extras.fromJson(v));
      });
    }
    active = json['active'];
    activeDelivery = json['activeDelivery'];
    activeCarro = json['activeCarro'];
    activeTienda = json['activeTienda'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    data['position'] = this.position;
    data['name'] = this.name;
    data['price'] = this.price;
    data['image'] = this.image;
    data['image2'] = this.image2;
    data['home'] = this.home;
    data['promo'] = this.promo;
    if (this.extras != null) {
      data['extras'] = this.extras!.map((v) => v.toJson()).toList();
    }
    data['active'] = this.active;
    data['activeDelivery'] = this.activeDelivery;
    data['activeCarro'] = this.activeCarro;
    data['activeTienda'] = this.activeTienda;
    return data;
  }
}

class Category {
  String? sId;
  String? name;
  String? sound;

  Category({this.sId, this.name, this.sound});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    sound = json['sound'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['sound'] = this.sound;
    return data;
  }
}

class Extras {
  String? sId;
  String? code;
  String? name;

  Extras({this.sId, this.code, this.name});

  Extras.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}


