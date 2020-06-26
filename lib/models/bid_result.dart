import 'package:cloud_firestore/cloud_firestore.dart';

class BidResult {
  final String documentID;
  final String companyName;
  final int power;
  final int price;
  final int rd;
  final int sold;
  final int volume;
  final bool isParent;
  final bool mr;
  final int maxPrice;

  BidResult(
      {this.documentID,
      this.companyName,
      this.power,
      this.price,
      this.rd,
      this.sold,
      this.volume,
      this.isParent,
      this.mr,
      this.maxPrice});

  factory BidResult.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    print(data.toString());
    return BidResult(
      companyName: data['companyName'] ?? '',
      power: data['power'] ?? 0,
      price: data['price'] ?? 0,
      rd: data['rd'] ?? 0,
      sold: data['sold'] ?? 0,
      volume: data['volume'] ?? 0,
      isParent: data['isParent'] ?? false,
      mr: data['mr'] ?? false,
      maxPrice: data['maxPrice'] ?? 0,
      documentID: doc.documentID,
    );
  }
}

/*
class BidResult {

  final int allusers;
  final int acceptUsers;
  final int joinUsers;
  final int bidUsers;
  final bool isOn;

  BidResult(this.allusers, this.acceptUsers, this.joinUsers, this.bidUsers,
      this.isOn);

  bool isDone() {
    return isOn;
  }
}

 */
/*
       'allusers' : allusers,
        'acceptUsers' : acceptUsers,
        'joinUsers' : joinUsers,
        'bidUsers' : bidUsers,
        'isOn' : isOn
 */
