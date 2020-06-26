import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;

  User({this.uid});
}

class UserData {
  final String uid;
  final String name;
  final String companyName;

  UserData({this.uid, this.name, this.companyName});

  factory UserData.fromFirestore(DocumentSnapshot data) {
    Map mapData = data.data;
    return UserData(
      uid: data.documentID,
      name: mapData['name'],
      companyName: mapData['companyName'],
    );
  }
}
