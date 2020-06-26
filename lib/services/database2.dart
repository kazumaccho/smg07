import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/bid_users.dart';
import 'package:smg07/shared/global.dart';

class DatabaseService2 {
  Stream<List<BidUser>> streamBidUsers(FirebaseUser user) {
    var ref =
        firestore.collection('heroes').document(user.uid).collection('weapons');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => BidUser.formFireStore(doc)).toList());
  }
}

class Document<T> {
  final Firestore _db = Firestore.instance;
  DocumentReference ref;

  Document() {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    print('path = : ' + path);
    ref = _db.document(path);
  }

  Future<T> getData() {
    return ref.get().then((v) => Global.models[T](v.data) as T);
  }

  Stream<T> streamData() {
    return ref.snapshots().map((data) => Global.models[T](data) as T);
  }

  Future<void> upsert(Map data) {
    return ref.setData(Map<String, dynamic>.from(data), merge: true);
  }

  Future<BidBook> getData2() {
    return ref.get().then((data) => BidBook.fromFirestore(data));
  }

  Stream<BidBook> bidBookStream() {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    ref = Firestore.instance.document(path);
    print('bidBook Stream working... path : ' + path);
    return ref
        .snapshots(includeMetadataChanges: true)
        .map((data) => BidBook.fromFirestore(data));
  }
}

class Document4AllUsers {
  final Firestore _db = Firestore.instance;
  Document() {}

  Future<int> getData() {
    return _db
        .collection(rootCollectionName)
        .document('combat_data')
        .get()
        .then((v) => v.data['joins']);
    //return ref.get().then((v) => Global.models[T](v.data) as T);
  }
}

class Collection<T> {
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Collection({this.path}) {
    //ref = _db.collection(rootCollectionName+'/combat_data/combat_history/'+ globalSerialNo.toString() +'/markets/' + path + 'bidders');
    //ref = _db.collection(rootCollectionName+'/combat_data/combat_history/'+ globalSerialNo.toString() +'/markets/').limit(1).;
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.getDocuments();
    return snapshots.documents
        .map((doc) => Global.models[T](doc.data) as T)
        .toList();
  }

  Future<List<BidUser>> getData2(String marketName) async {
    String pathName = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString() +
        '/markets/' +
        marketName +
        '/bidders';
    var snapshots = await Firestore.instance
        .collection(pathName)
        .orderBy('price', descending: false)
        .getDocuments();
    return snapshots.documents
        .map((doc) => BidUser.formFireStore(doc))
        .toList();
  }
}
/*
  Stream<List<BidUser>> streamData() {
    //print('stream data sapporo');
    if (rootCollectionName.length != 0 &&
        globalSerialNo != 0 &&
        globalCheckMarket.length != 0) {
      String rootPath = rootCollectionName +
          '/combat_data/combat_history/' +
          globalSerialNo.toString() +
          '/markets/' +
          globalCheckMarket +
          '/bidders';
      print('rootPath 189 streamData()' + rootPath);
      ref = _db.collection(rootPath);
      return ref.snapshots().map((list) =>
          list.documents.map((data) => BidUser.formFireStore(data)).toList());
    } else {
      print('streamdata else');
    }
  }
}
*/
//  collection           doc          collection      doc        ,  collection , doc           ,  collection   ,  doc
// rootCollectionName , combat_data , combat_history, ¥¥sno¥¥    .  markets    ,  ¥¥aMarket¥¥  ,  bidders      ,  uid
//
