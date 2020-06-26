import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/markets.dart';
import 'package:smg07/shared/global.dart';

class BlocMarkets with ChangeNotifier {
  List<M_Markets> _markets;
  String path;
  final Firestore _db = Firestore.instance;
  StreamSubscription _marketsSubsc;

  BlocMarkets({this.path}) {
    if (this.path.length > 0) updateMarketPath(path);
  }

  void updateMarketPath(String path) {
    this.path = path;
    if (path.length == 0) return null;
    _marketsSubsc = _db
        .collection(path)
        .orderBy('maxPrice', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _markets = snapshot.documents
          .map((doc) => M_Markets.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  List<M_Markets> get markets => _markets;

  void cancel() {
    _marketsSubsc.cancel();
  }

  void commitMarket(List<M_Markets> markets) {
    WriteBatch batch = Firestore.instance.batch();

    markets.forEach((aMarket) {
      String aMarketPath = path + '/' + aMarket.documentID;
      batch.setData(_db.document(aMarketPath), aMarket.toMap());
    });

    batch
        .commit()
        .then((value) => print('commitMarket success'))
        .catchError((err) => print(err));
  }

  void createMarket() {
    List<M_Markets> markets = [];

    markets.add(M_Markets(
        documentID: 'sapporo',
        name: '札幌',
        currentMaterials: 3,
        price: 10,
        maxPrice: 40,
        maxVolume: 3));

    markets.add(M_Markets(
        documentID: 'sendai',
        name: '仙台',
        currentMaterials: 4,
        price: 11,
        maxPrice: 36,
        maxVolume: 4));
    markets.add(M_Markets(
        documentID: 'tokyo',
        name: '東京',
        currentMaterials: 6,
        price: 12,
        maxPrice: 32,
        maxVolume: 6));
    markets.add(M_Markets(
        documentID: 'nagoya',
        name: '名古屋',
        currentMaterials: 9,
        price: 13,
        maxPrice: 28,
        maxVolume: 9));
    markets.add(M_Markets(
        documentID: 'osaka',
        name: '大阪',
        currentMaterials: 13,
        price: 14,
        maxPrice: 24,
        maxVolume: 13));
    markets.add(M_Markets(
        documentID: 'fukuoka',
        name: '福岡',
        currentMaterials: 20,
        price: 15,
        maxPrice: 20,
        maxVolume: 20));

    commitMarket(markets);
  }
}

class BlocMarket with ChangeNotifier {
  M_Markets _market;
  String path;
  final Firestore _db = Firestore.instance;
  StreamSubscription _marketSubsc;

  BlocMarket({this.path}) {
    if (this.path.length > 0) updateMarketPath(path);
  }

  void updateMarketPath(String marketName) {
    String path = rootCollectionName + '/games/markets/' + marketName;
    this.path = path;
    _marketSubsc = _db
        .document(path)
        .snapshots()
        .map((doc) => M_Markets.fromFirestore(doc))
        .listen((newMarket) {
      _market = newMarket;
    });
  }

  M_Markets get market => _market;

  void cancel() {
    _marketSubsc.cancel();
  }
}

class MarketName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BlocMarket>(
      builder: (context, blocMarket, child) {
        if (blocMarket == null) {
          return Text('loading...');
        }
        return Text(
          blocMarket.market.name,
          style: TextStyle(color: Colors.black, fontSize: 30),
        );
      },
    );
  }
}

class MaxPrice extends StatelessWidget {
  final int index;
  const MaxPrice({Key key, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<BlocMarkets>(
      builder: (context, blocMarket, child) {
        if (blocMarket == null) {
          return Text('loading...');
        }
        return Text(
          blocMarket.markets[index].maxPrice.toString(),
          style: TextStyle(color: Colors.black, fontSize: 30),
        );
      },
    );
  }
}
