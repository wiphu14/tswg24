import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CartypeModel {
  final String id;
  final String cartype;
  CartypeModel({
    required this.id,
    required this.cartype,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cartype': cartype,
    };
  }

  factory CartypeModel.fromMap(Map<String, dynamic> map) {
    return CartypeModel(
      id: (map['id'] ?? '') as String,
      cartype: (map['cartype'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartypeModel.fromJson(String source) => CartypeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
