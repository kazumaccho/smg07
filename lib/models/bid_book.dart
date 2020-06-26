import 'package:cloud_firestore/cloud_firestore.dart';

class BidBook {
  final String owner; //親 uid
  final List<dynamic> markets;
  final List<dynamic> volumes;
  //final List<dynamic> joins;
  final Map<dynamic, dynamic> joins;
  final bool isOn;
  final int status;

  BidBook(
      {this.owner,
      this.markets,
      this.volumes,
      this.joins,
      this.isOn,
      this.status});

  factory BidBook.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return BidBook(
        owner: data['owner'] ?? '',
        markets: data['markets'] ?? [],
        volumes: data['volumes'] ?? [],
        joins: data['joins'] ?? {},
        isOn: data['isOn'] ?? false,
        status: data['status'] ?? 0);
  }
}
