import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/markets.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_Markets extends StatefulWidget {
  @override
  _S_MarketsState createState() => _S_MarketsState();
}

class _S_MarketsState extends State<S_Markets> {
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

  Widget getOverseaMarket() {
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
                  Row(
                    children: <Widget>[
                      Text(
                        '海外(16)',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(
                        width: 30,
                      ),
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
                          if (overSeaMaterials != 0)
                            setState(() => overSeaMaterials--);
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
                        onPressed: () => setState(() => overSeaMaterials++),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  overSeaMaterials.toString(),
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
    return markets == null || myBoard == null
        ? Loading()
        : MaterialApp(
            home: Scaffold(
              body: Container(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1.0))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            '市場',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          )),
                          Expanded(
                              child: Center(
                            child: Text(
                              'vol',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Center(
                            child: Text(
                              '単価',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Center(
                            child: Text(
                              '購入数',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )),
                        ],
                      ),
                    ),
                    for (int index = 0; index < markets.length; index++)
                      getMarket(index),
                    getOverseaMarket(),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          RaisedButton(
                            child: Text("Cancel"),
                            color: Colors.black12,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          RaisedButton(
                            child: Text("COMMIT"),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: myBoard.cash < calcCost() ||
                                    myBoard.cash == 0
                                ? null
                                : () {
                                    for (int index = 0;
                                        index < markets.length;
                                        index++) {
                                      markets[index].currentMaterials -=
                                          materials[index];
                                    }
                                    ;

                                    int sum = materials.reduce((a, b) => a + b);
                                    sum += overSeaMaterials;

                                    myBoard.stock_room += sum;
                                    myBoard.cash -= calcCost();
                                    Firestore.instance
                                        .document(cashBookPath)
                                        .updateData({
                                      'buyMaterials': FieldValue.increment(sum),
                                      'sumMaterials':
                                          FieldValue.increment(calcCost()),
                                    });
                                    //cashBook.buyMaterials += sum;
                                    //cashBook.sumMaterials += calcCost();
                                    DatabaseService()
                                        .commitCompanyBoard(myBoard);
                                    DatabaseService().commitMarket(markets);
                                    _auth.changeCurrentOwner();
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/companyBoard'));
                                  },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'CASH: ' + myBoard.cash.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Text(
                            ' COST: ' + calcCost().toString(),
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class V_Markets extends StatefulWidget {
  @override
  _V_MarketsState createState() => _V_MarketsState();
}

class _V_MarketsState extends State<V_Markets> {
  StreamSubscription marketSubsc;
  List<M_Markets> markets;

  @override
  void initState() {
    marketSubsc = Firestore.instance
        .collection(rootCollectionName + '/games/markets')
        .orderBy('maxPrice', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((QuerySnapshot snapshot) {
      setState(() {
        markets = snapshot.documents
            .map((doc) => M_Markets.fromFirestore(doc))
            .toList();
        print('markets : ' + markets.length.toString());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
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
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  markets[index].maxVolume.toString() ?? 0,
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  markets[index].maxPrice.toString() ?? 0,
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  markets[index].price.toString() ?? 0,
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getOverseaMarket() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(width: 1.0))),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '海外(16)',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return markets == null
        ? Loading()
        : MaterialApp(
            home: Scaffold(
              body: Container(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1.0))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Text(
                                '市場',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  '市場ニーズ',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  '市場規模',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  '単価',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  '入札上限',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              )),
                        ],
                      ),
                    ),
                    for (int index = 0; index < markets.length; index++)
                      getMarket(index),
                    getOverseaMarket(),
                  ],
                ),
              ),
            ),
          );
  }
}
