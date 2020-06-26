import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/screens/countdown_timer.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_CompanyBoards extends StatefulWidget {
  @override
  _S_CompanyBoardsState createState() => _S_CompanyBoardsState();
}

class _S_CompanyBoardsState extends State<S_CompanyBoards> {
  String hokenPath = 'images/companyboard/noneHokenChip.png';
  String mdPath = 'images/companyboard/noneMdChip.png';
  String pacPath = 'images/companyboard/nonePacChip.png';
  String mrPath = 'images/companyboard/noneMrChip.png';
  String chipPath = 'images/companyboard/chip.png';
  CompanyBoard myBoard;
  BidBook book;
  StreamSubscription myBoardSubsc;
  StreamSubscription bookSubsc;
  StreamSubscription serialSubsc;
  int status = 0;
  List<dynamic> messages = [];

  String cashBookPath;
  bool isPressed = false;

  @override
  void initState() {
    serialSubsc = Firestore.instance
        .document(rootCollectionName + '/games')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data['serialNo'] != globalSerialNo) {
          setState(() {
            globalSerialNo = snapshot.data['serialNo'];
            print('SET SERIALNO : ' + globalSerialNo.toString());
            reSetBookSubsc();
          });
        }
      }
    });
    //print('rootCollectionName userid' + rootCollectionName + localuser.uid);

    myBoardSubsc = Firestore.instance
        .document(rootCollectionName + '/games/users/' + localuser.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          myBoard = CompanyBoard.fromFirestore(snapshot);
          //shareMyBoard = myBoard;
//          print('myBoard :' + myBoard.toMap().toString());
          cashBookPath = rootCollectionName +
              '/games/users/' +
              localuser.uid +
              '/cashbook/' +
              myBoard.priod.toString();
        });
      }
    });

    super.initState();
  }

  void reSetBookSubsc() {
    //bookSubsc.cancel();
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    //print('PATH SERIALNO : ' + globalSerialNo.toString());

    bookSubsc = Firestore.instance
        .document(path)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          book = BidBook.fromFirestore(snapshot);
          status = book.status;
          //print('bidbook status :' + book.status.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bookSubsc.cancel();
    myBoardSubsc.cancel();
    serialSubsc.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> viewMachines() {
      //print('index : ' + index.toString());
      //print('machines length : ' + myBoard.machines.length.toString());

      List<Widget> result = List<Widget>();
      for (int index = 0; index < myBoard.machines.length; index++) {
        if (myBoard.machines[index].containsKey('attach')) {
          result.add(Image.asset(
            'images/companyboard/attach.png',
            width: 30,
            height: 30,
          ));
          continue;
        }
        if (myBoard.machines[index].containsKey('small'))
          result.add(Image.asset(
            'images/companyboard/small.png',
            height: 30,
            width: 30,
          ));
        if (myBoard.machines[index].containsKey('big'))
          result.add(Image.asset(
            'images/companyboard/big.png',
            height: 30,
            width: 30,
          ));
      }
      return result;
    }

    return status == 1
        ? CountDownTimer()
        : MaterialApp(
            home: myBoard == null
                ? Loading()
                : Scaffold(
                    appBar: AppBar(
                      title: Text(myBoard.companyName),
                      actions: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: Icon(Icons.build),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/SellMachine');
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Icon(Icons.directions_walk),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/Jinji');
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Icon(Icons.account_balance),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/bank');
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Image.asset(
                                myBoard.HOKEN ? chipPath : hokenPath,
                                height: 40,
                                width: 40,
                                fit: BoxFit.fill),
                            onPressed: () {
                              setState(() {
                                myBoard.HOKEN = true;
                                myBoard.cash -= 5;

                                Firestore.instance
                                    .document(cashBookPath)
                                    .updateData(
                                        {'keihi': FieldValue.increment(5)});
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(myBoard.cash.toString(),
                              style: Theme.of(context).textTheme.headline4),
                        ),
                      ],
                    ),
                    body: Column(
                      children: <Widget>[
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1.0)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyan,
                                  child: Text(
                                    '倉庫',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: FlatButton(
                                  child: Image.asset(
                                      myBoard.MD ? chipPath : mdPath,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.fill),
                                  onPressed: () {
                                    setState(() {
                                      myBoard.MD = true;
                                      myBoard.cash -= 10;
                                      Firestore.instance
                                          .document(cashBookPath)
                                          .updateData({
                                        'keihi': FieldValue.increment(10)
                                      });
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1.0))),
                          //color: Colors.black12,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyanAccent,
                                  decoration: BoxDecoration(
                                      //color: Colors.cyanAccent,
                                      border: Border(
                                          right: BorderSide(width: 1.0))),
                                  child: Wrap(
                                    children: <Widget>[
                                      for (int index = 0;
                                          index < myBoard.RD;
                                          index++)
                                        Image.asset(
                                          'images/companyboard/kokoku.jpg',
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.fitWidth,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  //color: Colors.black45,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      for (int index = 0;
                                          index < myBoard.stock_room;
                                          index++)
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1.0)),
                                            child: Image.asset(
                                                'images/companyboard/material.jpg')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1.0)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyan,
                                  child: Text(
                                    '工場',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              for (int index = 0;
                                  index < myBoard.worker;
                                  index++)
                                Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                              Expanded(
                                flex: 1,
                                child: FlatButton(
                                  child: Image.asset(
                                      myBoard.PAC ? chipPath : pacPath,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.fill),
                                  onPressed: () {
                                    setState(() {
                                      myBoard.PAC = true;
                                      myBoard.cash -= 10;
                                      Firestore.instance
                                          .document(cashBookPath)
                                          .updateData({
                                        'keihi': FieldValue.increment(10)
                                      });
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1.0))),
                          //color: Colors.black12,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyanAccent,
                                  decoration: BoxDecoration(
                                      //color: Colors.cyanAccent,
                                      border: Border(
                                          right: BorderSide(width: 1.0))),
                                  child: Wrap(
                                    children: viewMachines(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  //color: Colors.black45,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      for (int index = 0;
                                          index < myBoard.factory_room;
                                          index++)
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1.0)),
                                            child: Image.asset(
                                                'images/companyboard/material.jpg')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1.0)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyan,
                                  child: Text(
                                    '営業所',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              for (int index = 0;
                                  index < myBoard.salesman;
                                  index++)
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                              Expanded(
                                flex: 1,
                                child: FlatButton(
                                  child: Image.asset(
                                      myBoard.MR ? chipPath : mrPath,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.fill),
                                  onPressed: () {
                                    setState(() {
                                      myBoard.MR = true;
                                      myBoard.cash -= 10;
                                      Firestore.instance
                                          .document(cashBookPath)
                                          .updateData({
                                        'keihi': FieldValue.increment(10)
                                      });
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1.0))),
                          //color: Colors.black12,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.cyanAccent,
                                  decoration: BoxDecoration(
                                      //color: Colors.cyanAccent,
                                      border: Border(
                                          right: BorderSide(width: 1.0))),
                                  child: Wrap(
                                    children: <Widget>[
                                      for (int index = 0;
                                          index < myBoard.kokoku;
                                          index++)
                                        Image.asset(
                                          'images/companyboard/kokoku.jpg',
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.fitWidth,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  //color: Colors.black45,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      for (int index = 0;
                                          index < myBoard.shop_room;
                                          index++)
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1.0)),
                                            child: Image.asset(
                                                'images/companyboard/material.jpg')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder(
                          stream: Firestore.instance
                              .document(rootCollectionName + '/games')
                              .snapshots(),
                          builder: (context2, snapshot) {
                            print(snapshot.connectionState.toString());
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              int index = snapshot.data['parentCnt'];
                              if (snapshot.data['users'][index] ==
                                      localuser.uid &&
                                  snapshot.data['status'] != 2) {
                                return RaisedButton(
                                  color: Colors.blue[400],
                                  child: Text(
                                    'カードを引く',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: isPressed
                                      ? null
                                      : () async {
                                          isPressed = true;
                                          await DatabaseService()
                                              .commitCompanyBoard(myBoard);
                                          isPressed = false;
                                          Navigator.of(context)
                                              .pushNamed('/pickCard');
                                        },
                                );
                              }
                              if (snapshot.data['status'] == 2) {
                                return RaisedButton(
                                  color: Colors.blue[400],
                                  child: Text(
                                    '決算画面へ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/plbs');
                                  },
                                );
                              }
                            }
                            return Text('親の順番が来たらボタンが表示されます');
                          },
                        ),
                      ],
                    ),
                  ),
          );
  }
}
