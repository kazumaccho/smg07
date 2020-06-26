import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/bloc/bloc_bid_book.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/markets.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_BiddersList extends StatefulWidget {
  @override
  _S_BiddersListState createState() => _S_BiddersListState();
}

/*
    オーナーが入札開始したら、
    この画面で全員が入札参加可否と
    マーケットごとの入札数を閲覧

             ower user1 user2 user3
    開発チップ　 2   1      2     0
    マーケット   3   1
    マーケット   2   2
    参加可否   OK   NG     OK    OK

      　　入札価格ボタン表示
    　　　userNには待つようにメッセージが表示
    　　　親にボタンが押すように表示される
 ---------------------------
    価格入札画面
    上記表に価格入力ボタンを表示して
    価格を決める

----------------------------
    入札状況を表示する画面
             ower user1 user2 user3
    入札状況   OK   NG     OK    OK

    　親に全員されたらボタンが表示
----------------------------

　　　落札順に表示
          マーケット名
          数(競争力)
　落札者1
  落札者2
  落選

 */

class _S_BiddersListState extends State<S_BiddersList> {
  StreamSubscription marketSubsc;
  List<M_Markets> markets;
  List<int> materials;
  int overSeaMaterials = 0;
  int cost = 0;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  BlocBidBook _blocBidBook;

  int calcCost() {
    int result = 0;

    for (int index = 0; index < markets.length; index++) {
      result +=
          (markets[index].price - (myBoard.MD ? 2 : 0)) * materials[index];
    }
    ;
    result += overSeaMaterials * 16;
    return result;
  }

  @override
  void initState() {
    //localBoard = shareMyBoard;
    // TODO: implement initState
    marketSubsc = Firestore.instance
        .collection(rootCollectionName + '/games/markets')
        .orderBy('maxPrice', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        markets = snapshot.documents
            .map((doc) => M_Markets.fromFirestore(doc))
            .toList();
        print('markets : ' + markets.length.toString());
      });
    });
    materials = [0, 0, 0, 0, 0, 0];

    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    marketSubsc.cancel();
    super.dispose();
  }

  Widget getMarket(int index) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(width: 1.0))),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            markets[index].name ?? '',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              markets[index].currentMaterials.toString() ?? 0,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              markets[index].price.toString() ?? 0,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        MaterialButton(
                          height: 15.0,
                          color: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            if (materials[index] != 0) {
                              setState(() => materials[index]--);
                            }
                          },
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        MaterialButton(
                          height: 15.0,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            'MAX',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              materials[index] =
                                  markets[index].currentMaterials;
                            });
                          },
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        MaterialButton(
                          height: 15.0,
                          color: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            if (markets[index].currentMaterials >
                                materials[index]) {
                              setState(() => materials[index]++);
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  materials[index].toString(),
                  style: TextStyle(color: Colors.red, fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _blocBidBook = Provider.of<BlocBidBook>(context);
    return markets == null || myBoard == null
        ? Loading()
        : MaterialApp(
            home: Scaffold(
              body: Container(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    jointatusInfo(),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        RaisedButton(
                            child: Text("入札価格を決めてください"),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.popUntil(context,
                                  ModalRoute.withName('/companyBoard'));
                            }),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
