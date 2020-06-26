//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/cashbook.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/pbbs.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';

class Shoki extends StatefulWidget {
  @override
  _ShokiState createState() => _ShokiState();
}

class _ShokiState extends State<Shoki> {
  CompanyBoard myBoard;
  M_PLBS previousPLBS;
  bool isPressed = false;
  int localPeriod = 0;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  void initState() {
    // TODO: implement initState
    Future.wait([
      DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
            setState(() {
              myBoard = value;
            }),
          })
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Center(
              child:
                  Text('設定情報', style: Theme.of(context).textTheme.headline4)),
          SizedBox(
            height: 10.0,
          ),
          Center(
              child: Text('資本金:400',
                  style: Theme.of(context).textTheme.headline4)),
          SizedBox(
            height: 10.0,
          ),
          Center(
              child: Text('ジュニアルール',
                  style: Theme.of(context).textTheme.headline4)),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: StreamBuilder(
              stream: Firestore.instance
                  .document(rootCollectionName + '/games')
                  .snapshots(),
              builder: (context, snapshot) {
                //print(snapshot.connectionState.toString());
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data['status'] == 1) {
                    return RaisedButton(
                      color: Colors.blue[400],
                      child: Text(
                        '開始ボタン',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: isPressed
                          ? null
                          : () async {
                              //isPressed = true;

                              // 現金出納帳　１回目新規に作成　２回目機首処理　納税、金利支払い
                              setState(() {
                                globalPeriod++;
                                cashBookPath = rootCollectionName +
                                    '/games/users/' +
                                    localuser.uid +
                                    '/cashbook/' +
                                    globalPeriod.toString();
                                isPressed = true;
                              });

                              //当期の現金出納帳の作成

                              await DatabaseService().commitCashBook(
                                  globalPeriod, CashBook.First());

                              //一番最初の時のみ、０期の決算書の作成、資本金の設定
                              if (globalPeriod == 1) {
                                //shareMyBoard = CompanyBoard.first();
                                await DatabaseService()
                                    .commitKessan(M_PLBS.createPeriod_0());
                                await Firestore.instance
                                    .document(cashBookPath)
                                    .updateData({'shihon': 400});
                                await Firestore.instance
                                    .document(myBoardPath)
                                    .updateData({'cash': 400});
                              } else {
                                await Firestore.instance
                                    .document(rootCollectionName +
                                        '/games/users/' +
                                        localuser.uid +
                                        '/plbs/' +
                                        (globalPeriod - 1).toString())
                                    .get()
                                    .then((value) => {
                                          previousPLBS =
                                              M_PLBS.fromFirestore(value),
                                        })
                                    .catchError((err) => print(err.toString()));

                                await Future.wait([
                                  Firestore.instance
                                      .document(cashBookPath)
                                      .updateData({
                                    'keihi': (previousPLBS.dept * 0.1).floor()
                                  }),
                                  Firestore.instance
                                      .document(myBoardPath)
                                      .updateData({
                                    'cash': FieldValue.increment(
                                        -(previousPLBS.dept * 0.1).floor() -
                                            previousPLBS.haitou -
                                            previousPLBS.tax)
                                  })
                                ]);
                                //cashBook.keihi += (previousPLBS.dept * 0.1).floor();

                                ;
                                //myBoard.cash -= (previousPLBS.dept * 0.1).floor();
                                //myBoard.cash -= previousPLBS.haitou;
                                //myBoard.cash -= previousPLBS.tax;
                              }
                              //会社盤 １回目　新規に作成前画面で作成　２回目 期を更新、retiresなどクリア
                              await Firestore.instance
                                  .document(myBoardPath)
                                  .updateData({
                                'priod': FieldValue.increment(1),
                                'retires': 0,
                                'PAC': false,
                                'HOKEN': false,
                                'MR': false,
                                'MD': false,
                                'RD': 0,
                                'shop_lost': 0,
                                'factory_lost': 0,
                                'stock_lost': 0,
                                'kokoku': 0,
                              });

                              //isPressed = false;
                              setState(() {
                                isPressed = false;
                              });
                              Navigator.of(context).pushNamed('/companyBoard');
                            },
                    );
                  }
                }
                return Text('開始ボタンが表示されるまでお待ちください。');
              },
            ),
          ),
        ],
      ),
    );
  }
}
