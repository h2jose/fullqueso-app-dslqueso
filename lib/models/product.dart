class ProductModel {
  String? sId;
  String? code;
  List<Category>? category;
  int? position;
  String? name;


  double? priceBs;
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
  int quantity = 0;
  String? additional = '';
  bool? useFlavour = false;
  int qtyFlavour = 0;
  String? codeFlavour = '';
  List<Extras>? flavours;

  ProductModel(
      {this.sId,
      this.code,
      this.category,
      this.position,
      this.name,
      this.price,
      this.priceBs,
      this.image,
      this.image2,
      this.home,
      this.promo,
      this.extras,
      this.active,
      this.activeDelivery,
      this.activeCarro,
      this.activeTienda,
      this.quantity = 0,
      this.additional,
      this.useFlavour = false,
      this.qtyFlavour = 0,
      this.codeFlavour = '',
      this.flavours,
      });

  ProductModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    position = json['position'];
    name = json['name'];
    priceBs = json['priceBs'] is int ? json['priceBs'].toDouble() : json['priceBs'];
    price = json['price'] is int ? json['price'].toDouble() : json['price'];
    image = json['image'];
    image2 = json['image2'];
    home = json['home'];
    promo = json['promo'];
    if (json['extras'] != null) {
      extras = <Extras>[];
      json['extras'].forEach((v) {
        extras!.add(Extras.fromJson(v));
      });
    }
    active = json['active'];
    activeDelivery = json['activeDelivery'];
    activeCarro = json['activeCarro'];
    activeTienda = json['activeTienda'];
    additional = json['aditional'];
    useFlavour = json['useFlavour'] ?? false;
    qtyFlavour = json['qtyFlavour'] ?? 0;
    codeFlavour = json['codeFlavour'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['code'] = code;
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    data['position'] = position;
    data['name'] = name;
    data['priceBs'] = priceBs ?? 0;
    data['price'] = price;
    data['image'] = image;
    data['image2'] = image2;
    data['home'] = home;
    data['promo'] = promo;
    if (extras != null) {
      data['extras'] = extras!.map((v) => v.toJson()).toList();
    }
    if (flavours != null) {
      data['flavours'] = flavours!.map((v) => v.toJson()).toList();
    }
    data['active'] = active;
    data['activeDelivery'] = activeDelivery;
    data['activeCarro'] = activeCarro;
    data['activeTienda'] = activeTienda;
    data['additional'] = additional;
    data['useFlavour'] = useFlavour;
    data['qtyFlavour'] = qtyFlavour;
    data['codeFlavour'] = codeFlavour;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['sound'] = sound;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
