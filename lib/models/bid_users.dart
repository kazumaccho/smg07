import 'package:cloud_firestore/cloud_firestore.dart';

class BidUser {
  final String companyName;
  final int maxPrice;
  final bool mr;
  final int power;
  final int rd;
  final int volume;
  final int price;
  final int sold;
  final bool isJoin;
  final bool isParent;
  final String documentID;

  BidUser(
      {this.documentID,
      this.volume,
      this.price,
      this.sold,
      this.isJoin,
      this.maxPrice,
      this.companyName,
      this.mr,
      this.power,
      this.isParent,
      this.rd});

  factory BidUser.formFireStore(DocumentSnapshot doc) {
    Map data = doc.data;

    return BidUser(
        documentID: doc.documentID ?? '',
        companyName: data['companyName'] ?? 'none',
        maxPrice: data['maxPrice'] ?? 0,
        mr: data['mr'] ?? 0,
        power: data['power'] ?? 0,
        volume: data['volume'] ?? 0,
        price: data['price'] ?? 0,
        sold: data['sold'] ?? 0,
        isJoin: data['isJoin'] ?? false);
  }
}
