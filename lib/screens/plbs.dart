import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/cashbook.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/pbbs.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

/*
class S_PLBS extends StatefulWidget {
  @override
  _S_PLBSState createState() => _S_PLBSState();
}

class _S_PLBSState extends State<S_PLBS> {
  CompanyBoard myBoard;
  CashBook cashBook;
  M_PLBS previousPLBS;
  M_PLBS kessan;

  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });

    DatabaseService().getCashBook(localuser.uid, globalPeriod).then((value) => {
          setState(() {
            cashBook = value;
          }),
        });

    DatabaseService().getPLBS(globalPeriod - 1).then((value) => {
          setState(() {
            previousPLBS = value;
          }),
        });

    super.initState();
  }

  // M_PLBS kessan = M_PLBS().calcPLBS(shareMyBoard, cashBook, previousPLBS);

  @override
  Widget build(BuildContext context) {
    if (previousPLBS == null || cashBook == null || myBoard == null)
      return Loading();
    kessan = M_PLBS().calcPLBS(myBoard, cashBook, previousPLBS);
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Text(''),
            Text(''),
            Text('期数：' + kessan.period.toString()),
            Text('現金：' + kessan.cash.toString()),
            Text('倉庫在庫：' +
                kessan.stock_room_boka.toString() +
                '(' +
                kessan.stock_room_materials.toString() +
                ')'),
            Text('工場在庫：' +
                kessan.factory_room_boka.toString() +
                '(' +
                kessan.factory_room_materials.toString() +
                ')'),
            Text('営業所在庫：' +
                kessan.shop_room_boka.toString() +
                '(' +
                kessan.shop_room_materials.toString() +
                ')'),
            Text('機械簿価:' + kessan.boka.toString()),
            Text('総資産'),
            Text('借入金：' + kessan.dept.toString()),
            Text('税金：' + kessan.tax.toString()),
            Text('資本金：' + kessan.shihon.toString()),
            Text('利益余剰金：' + kessan.rieki.toString()),
            Text('総資産：'),
            Text('売上高：' + kessan.P.toString()),
            Text('変動費：' + kessan.V.toString()),
            Text('粗利益：' + kessan.M.toString()),
            Text('固定費：' + kessan.F.toString()),
            Text('営業利益：' + kessan.G.toString()),
            Text('営業外' + kessan.higai.toString()),
            Text('配当：' + kessan.haitou.toString()),
            Text('当期利益：' + kessan.touki.toString()),
            RaisedButton(
              color: Colors.blue[400],
              child: Text(
                '戻る',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                DatabaseService().commitKessan(kessan);
                //DatabaseService().commitCashBook(kessan.period);
                //previousPLBS = kessan;
                Navigator.popUntil(context, ModalRoute.withName("/Shoki"));
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/
class V_PLBS extends StatefulWidget {
  @override
  _V_PLBSState createState() => _V_PLBSState();
}

class _V_PLBSState extends State<V_PLBS> {
  CompanyBoard myBoard;
  CashBook cashBook;
  M_PLBS previousPLBS;
  M_PLBS kessan;
  bool isPressed = false;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  Future<void> initState() {
    // TODO: implement initState

    Firestore.instance
        .document(rootCollectionName + '/games/users/' + localuser.uid)
        .get()
        .then((value) => {
              setState(() {
                myBoard = CompanyBoard.fromFirestore(value);
              }),
            })
        .catchError((err) => print(err.toString()));

    Firestore.instance
        .document(cashBookPath)
        .get()
        .then((value) => {
              setState(() {
                cashBook = CashBook.fromFirestore(value);
              }),
            })
        .catchError((err) => print(err.toString()));

    Firestore.instance
        .document(rootCollectionName +
            '/games/users/' +
            localuser.uid +
            '/plbs/' +
            (globalPeriod - 1).toString())
        .get()
        .then((value) => {
              setState(() {
                previousPLBS = M_PLBS.fromFirestore(value);
              }),
            })
        .catchError((err) => print(err.toString()));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (previousPLBS == null || cashBook == null || myBoard == null)
      return Loading();
    print('MYBOARD = ' + myBoard.toMap().toString());
    //print('previousPLBS = ' + previousPLBS.toMap().toString());
    print('CASHBOOK = ' + cashBook.toMap().toString());
    if (kessan == null)
      kessan = M_PLBS().calcPLBS(myBoard, cashBook, previousPLBS);
    //print('KESSAN = ' + kessan.toMap().toString());

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              myBoard.companyName + '会社 ' + myBoard.priod.toString() + '期決算'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    color: Colors.cyan,
                    child: Text(
                      '現金：' + kessan.cash.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    //color: Colors.cyanAccent,
                    child: Text(
                      '借入金：' + kessan.dept.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    color: Colors.cyan,
                    child: Text(
                      '倉庫在庫(個数)：' +
                          kessan.stock_room_boka.toString() +
                          '(' +
                          kessan.stock_room_materials.toString() +
                          ')',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    //color: Colors.cyanAccent,
                    child: Text(
                      '税金：' + kessan.tax.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    color: Colors.cyan,
                    child: Text(
                      '工場在庫(個数)：' +
                          kessan.factory_room_boka.toString() +
                          '(' +
                          kessan.factory_room_materials.toString() +
                          ')',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    //color: Colors.cyanAccent,
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    color: Colors.cyan,
                    child: Text(
                      '営業所在庫(個数)：' +
                          kessan.shop_room_boka.toString() +
                          '(' +
                          kessan.shop_room_materials.toString() +
                          ')',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    //color: Colors.cyanAccent,
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    //color: Colors.blueAccent,
                    child: Text(
                      '機械簿価：' + kessan.boka.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    color: Colors.amber,
                    child: Text(
                      '資本金：' + kessan.shihon.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    //color: Colors.blueAccent,

                    child: Text(
                      '',
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    color: Colors.amber,
                    child: Text(
                      '利益余剰金：' + kessan.rieki.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    color: Colors.black12,
                    child: Text(
                      '資本合計' +
                          (kessan.cash +
                                  kessan.stock_room_boka +
                                  kessan.factory_room_boka +
                                  kessan.shop_room_boka +
                                  kessan.boka)
                              .toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    color: Colors.black12,
                    child: Text(
                      '資本合計:' +
                          (kessan.dept +
                                  kessan.tax +
                                  kessan.shihon +
                                  kessan.rieki)
                              .toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                        height: 150,
                        color: Colors.cyan,
                        child: Text(
                          '売上：' +
                              kessan.P.toString() +
                              '(' +
                              kessan.Q.toString() +
                              ')',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        height: 150,
                        color: Colors.cyanAccent,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 40.0,
                              child: Text(
                                '変動費：' + kessan.V.toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            Container(
                              height: 110.0,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.green,
                                      height: 150,
                                      child: Text(
                                        '粗利益：' + kessan.M.toString(),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      color: Colors.lime,
                                      height: 110.0,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            height: 55.0,
                                            child: Center(
                                              child: Text(
                                                '固定費：' + kessan.F.toString(),
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 55.0,
                                            width: 216.0,
                                            color: Colors.deepPurpleAccent,
                                            child: Center(
                                              child: Text(
                                                '営業利益：' + kessan.G.toString(),
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              Text(
                '期末調整金額：' + kessan.kimatu.toString(),
                style: TextStyle(fontSize: 15),
              ),
              Text(
                '損害金：' + kessan.higai.toString(),
                style: TextStyle(fontSize: 15),
              ),
              Text(
                '当期利益' + kessan.touki.toString(),
                style: TextStyle(fontSize: 15),
              ),
              Text(
                '配当' + kessan.haitou.toString(),
                style: TextStyle(fontSize: 15),
              ),
              RaisedButton(
                color: Colors.blue[400],
                child: Text(
                  '戻る',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: isPressed
                    ? null
                    : () {
                        isPressed = true;
                        DatabaseService().commitKessan(kessan);
                        //DatabaseService().commitCashBook(kessan.period);
                        //previousPLBS = kessan;
                        isPressed = false;
                        Navigator.popUntil(
                            context, ModalRoute.withName("/Shoki"));
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
