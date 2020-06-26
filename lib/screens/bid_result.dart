import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/bid_result.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_BidResult extends StatefulWidget {
  @override
  _S_BidResultState createState() => _S_BidResultState();
}

class _S_BidResultState extends State<S_BidResult> {
  final AuthService _auth = AuthService();
  bool isloding = true;
  int status = 0;
  String owner = '';
  CompanyBoard myBoard;
  BidBook book;
  bool isPressed = false;
  //StreamSubscription myBoardSubsc;
  StreamSubscription bookSubsc;
  bool isCommiting = false;

  @override
  void initState() {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    //print('PATH SERIALNO : ' + globalSerialNo.toString());
    bookSubsc =
        Firestore.instance.document(path).snapshots().listen((snapshot) {
      if (status != 4 && BidBook.fromFirestore(snapshot).status == 4) {
        setState(() {
          book = BidBook.fromFirestore(snapshot);
          owner = book.owner;
          status = book.status;
        });
      }
    });

    super.initState();
  }

  Future<List<BidResult>> getBidResult(String aMartket) async {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString() +
        '/markets/' +
        aMartket +
        '/bidders';
    final Stream<List<BidResult>> stream = Firestore.instance
        .collection(path)
        .where('sold', isGreaterThan: 0)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.documents
            .map((doc) => BidResult.fromFirestore(doc))
            .toList());

    await for (var data in stream) {
      //print('await for data length :' + data.length.toString());
      return data;
    }
  }

  void commitResult() async {
    WriteBatch batch = Firestore.instance.batch();
    //入札市場毎にループ
    for (int index = 0; index < book.markets.length; index++) {
      //入札結果を取得 soldが0より大きいレコードのみ
      List<BidResult> bidResults = await getBidResult(book.markets[index]);

      //結果を会社盤にupdate
      for (int cnt = 0; cnt < bidResults.length; cnt++) {
        //落札者の会社盤を取得
        CompanyBoard board =
            await DatabaseService().getCompanyBoard(bidResults[cnt].documentID);

        int price = bidResults[cnt].price;

        if (bidResults[cnt].mr) {
          if ((price + 1) >= bidResults[cnt].maxPrice) {
            price = bidResults[cnt].maxPrice;
          } else {
            price += 2;
          }
        }
        batch.updateData(
            Firestore.instance.document(rootCollectionName +
                '/games/users/' +
                bidResults[cnt].documentID),
            {
              'cash': FieldValue.increment(price * bidResults[cnt].sold),
              'shop_room': FieldValue.increment(-bidResults[cnt].sold),
            });
        //現金出納帳へのupdate
        batch.updateData(
            Firestore.instance.document(rootCollectionName +
                '/games/users/' +
                bidResults[cnt].documentID +
                '/cashbook/' +
                board.priod.toString()),
            {
              'uriage': FieldValue.increment(price * bidResults[cnt].sold),
              'sales': FieldValue.increment(bidResults[cnt].sold)
            });

        //marketボードへのupdate currentMaterials
        batch.updateData(
            Firestore.instance.document(
                rootCollectionName + '/games/markets/' + book.markets[index]),
            {'currentMaterials': FieldValue.increment(bidResults[cnt].sold)});
      }
    }
    await batch
        .commit()
        .then((value) => print('commitResult success'))
        .catchError((err) => print(err));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bookSubsc.cancel();
    //myBoardSubsc.cancel();
    super.dispose();
  }

  Widget winnerList(String aMarket) {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString() +
        '/markets/' +
        aMarket +
        '/bidders';
    List<Widget> result = [];
    List<BidResult> bidResults = [];

    /*
          aMarkets
          落札順位 落札数　競争力　落札者

     */
    result.add(Row(
      children: <Widget>[Text(aMarket)],
    ));
    result.add(Row(
      children: <Widget>[
        Text(
          '順位',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        Text('落札数', style: TextStyle(color: Colors.black, fontSize: 20)),
        Text('競争力', style: TextStyle(color: Colors.black, fontSize: 20)),
        Text('落札者', style: TextStyle(color: Colors.black, fontSize: 20)),
      ],
    ));

    return FutureBuilder(
      initialData: null,
      future: Firestore.instance.collection(path).getDocuments(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data.documents == null ||
            !snapshot.hasData) return Text('Loading...');

        snapshot.data.documents
            .toList()
            .forEach((doc) => bidResults.add(BidResult.fromFirestore(doc)));

        for (int index = 0; index < bidResults.length; index++) {
          if (bidResults[index].sold > 0) {
            result.add(
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text((index + 1).toString(),
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                  Expanded(
                    child: Text(bidResults[index].sold.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                  Expanded(
                    child: Text((bidResults[index].power).toString(),
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                  Expanded(
                    child: Text(bidResults[index].companyName,
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                ],
              ),
            );
          }
        }
        return Column(children: result);
      },
    );
  }

  Widget viewNormal() {
    isPressed = false;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: 50.0,
        ),
        child: Column(
          children: <Widget>[
            for (int index = 0; index < book.markets.length; index++)
              winnerList(book.markets[index]),
            if (owner == localuser.uid) RaiseParentButton(),
            if (owner != localuser.uid) RaiseChildButton(),
          ],
        ),
      ),
    );
  }

  Widget RaiseParentButton() {
    return RaisedButton(
        color: Colors.pink[400],
        child: isCommiting
            ? Text('Please wait ...')
            : Text(
                '最初に戻る',
                style: TextStyle(color: Colors.white),
              ),
        onPressed: () async => {
              if (!isPressed)
                {
                  isPressed = true,
                  await commitResult(),
                  await _auth.changeCurrentOwner(),
                },
              isPressed = false,
              //await bookSubsc.cancel(),

              Navigator.popUntil(context, ModalRoute.withName("/companyBoard"))
            });
  }

  Widget RaiseChildButton() {
    return RaisedButton(
        color: Colors.pink[400],
        child: isPressed
            ? Text('Please wait ...')
            : Text(
                '最初に戻る',
                style: TextStyle(color: Colors.white),
              ),
        onPressed: () async => {
              //shareMyBoard = await DatabaseService().getCompanyBoard(localuser.uid),
              //cashBook = await DatabaseService().getCashBook(localuser.uid, shareMyBoard.priod),
              //print('RESULT BOARD = ' + shareMyBoard.toMap().toString()),
              //print('RESULT CASHBOOK = ' + cashBook.toMap().toString()),
              Navigator.popUntil(context, ModalRoute.withName("/companyBoard"))
            });
  }

  @override
  Widget build(BuildContext context) {
    if (book == null) Loading();
    //bookSubsc.cancel();
    return status < 4 ? Loading() : viewNormal();
  }
}
