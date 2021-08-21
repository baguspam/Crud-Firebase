import 'package:firebase_database/firebase_database.dart';

class Barang{
  final String? key;
  String? namaBrg;
  bool? favorite;
  String? price;
  String? stock;
  String? desc;

  Barang({
    this.key,
    this.namaBrg,
    this.favorite,
    this.price,
    this.stock,
    this.desc
  });

  Barang.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        namaBrg = snapshot.value['namaBrg'],
        favorite = snapshot.value['favorite'],
        price = snapshot.value['price'],
        stock = snapshot.value['stock'],
        desc = snapshot.value['desc'];

  Map<String, dynamic> toJson() => {
    "key": key,
    "namaBrg": namaBrg,
    "favorite": favorite,
    "price": price,
    "stock": stock,
    "desc": desc,
  };

}