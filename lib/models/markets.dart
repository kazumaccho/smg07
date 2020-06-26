import 'package:cloud_firestore/cloud_firestore.dart';

class M_Markets {
  final String documentID;
  final String name;
  int currentMaterials;
  final int price;
  final int maxPrice;
  final int maxVolume;

  M_Markets(
      {this.documentID,
      this.name,
      this.currentMaterials,
      this.price,
      this.maxPrice,
      this.maxVolume});

  factory M_Markets.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return M_Markets(
        documentID: doc.documentID,
        name: data['name'] ?? '',
        currentMaterials: data['currentMaterials'] ?? 0,
        price: data['price'] ?? 0,
        maxPrice: data['maxPrice'] ?? 0,
        maxVolume: data['maxVolume'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = Map<String, dynamic>();
    result['name'] = name;
    result['currentMaterials'] = currentMaterials;
    result['price'] = price;
    result['maxPrice'] = maxPrice;
    result['maxVolume'] = maxVolume;

    return result;
  }
}
