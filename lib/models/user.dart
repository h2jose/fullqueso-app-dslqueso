class UserModel {
  String? id;
  String? uid;
  String? email;
  String? name;
  String? role;
  bool? active;
  String? shopId;
  String? shopCode;

  UserModel({
    this.id, this.uid,
    this.email,
    this.name,
    this.role,
    this.active,
    this.shopId,
    this.shopCode = 'express'
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    active = json['active'];
    shopId = json['shopId'];
    shopCode = json['shopCode'] ?? 'express';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['email'] = email;
    data['name'] = name;
    data['role'] = role;
    data['active'] = active;
    data['shopId'] = shopId;
    data['shopCode'] = shopCode;
    return data;
  }
}
