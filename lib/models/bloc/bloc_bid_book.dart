import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/bid_book.dart';

class BlocBidBook with ChangeNotifier {
  BidBook _book;
  String path;
  final Firestore _db = Firestore.instance;
  StreamSubscription _bookSubsc;

  BlocBidBook({this.path}) {
    if (this.path.length > 0) updateBidBookPath(path);
  }

  void updateBidBookPath(String path) {
    this.path = path;

    _bookSubsc = _db
        .document(path)
        .snapshots()
        .map((doc) => BidBook.fromFirestore(doc))
        .listen((newBook) {
      _book = newBook;
      notifyListeners();
    });
  }

  bool isAllBid() {
    if (_book == null) return false;
    if (_book.joins.length ==
        _book.joins.values.where((element) => element == true).length)
      return true;
    return false;
  }

  BidBook get bidBook => _book;
  int get status => _book?.status;

  void cancel() {
    _bookSubsc.cancel();
  }
}

class BidMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BlocBidBook>(
      builder: (context, blockBidBook, child) {
        if (blockBidBook.bidBook == null) {
          return Text('loading...');
        } else {
          String result = blockBidBook.bidBook.owner + 'さんが入札を開始\n';
          for (int index = 0;
              index < blockBidBook.bidBook.markets.length;
              index++) {
            result += blockBidBook.bidBook.markets[index] +
                ' ( ' +
                blockBidBook.bidBook.volumes[index].toString() +
                ' ) \n';
          }
          return Center(
              child: Text(result,
                  style: TextStyle(fontSize: 20.0, color: Colors.white)));
          //TextStyle(fontSize: 15.0, color: Colors.white));
        }
      },
    );
  }
}
