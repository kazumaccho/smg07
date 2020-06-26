import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/screens/bid_markets.dart';
import 'package:smg07/screens/markets.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';

class S_MenuA extends StatefulWidget {
  final bool visibleImage;
  final bool visibleBuyMaterials;
  final bool visibleBid;
  final int visibleTonyu;
  final bool visible;
  const S_MenuA(
      {Key key,
      this.visibleImage,
      this.visibleBuyMaterials,
      this.visibleBid,
      this.visible,
      this.visibleTonyu})
      : super(key: key);

  @override
  _S_MenuAState createState() => _S_MenuAState();
}

enum Answer { YES, NO }

class _S_MenuAState extends State<S_MenuA> {
  int visible_status = 0;
  int value = 0;
  //bool visibleBuyMaterials = true;
  //bool visibleBid = true;
  bool visibleKnatou = true;
  //bool visible = true;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  int calcCost() {
    return 20;
  }

  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });
    super.initState();
  }

  Widget getKantou() {
    if (widget.visibleTonyu == 0) {
      return Text('');
    }
    if (widget.visibleTonyu == 1) {
      return RaisedButton(
        color: Colors.greenAccent[400],
        child: Text(
          '投入',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: !widget.visibleBuyMaterials
            ? null
            : () async {
                int result = await showDialog<int>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return D_Tonyu();
                    });
              },
      );
    }

    return RaisedButton(
      color: Colors.greenAccent[400],
      child: Text(
        '完成・投入',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: !widget.visibleBuyMaterials
          ? null
          : () async {
              int result = await showDialog<int>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return D_Kantou(visible: !widget.visibleBid);
                  });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    //CompanyBoard myBoard = Provider.of<CompanyBoard>(context);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            if (widget.visibleImage)
              Image.asset(
                'images/normal.png',
                scale: 1.2,
              ),
            Text('意思決定出来ます。'),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '材料購入',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visibleBuyMaterials
                        ? null
                        : () async {
                            int result = await showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return S_Markets();
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '入札ボタン',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visibleBid
                        ? null
                        : () async {
                            await showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return S_BidMarkets2();
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '広告チップ',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visible
                        ? null
                        : () async {
                            int result = await showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AwesomeDialog();
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '研究開発チップ',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visible
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('研究開発チップ購入'),
                                    content: Text('1枚２０で購入しますか？'),
                                    actions: <Widget>[
                                      Text(
                                        'CASH : ' + myBoard.cash.toString(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                      Text(
                                        ' COST : ' + calcCost().toString(),
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      ),
                                      RaisedButton(
                                        child: Text('cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(0),
                                      ),
                                      RaisedButton(
                                        child: Text('OK'),
                                        onPressed: myBoard.cash < calcCost()
                                            ? null
                                            : () => {
                                                  myBoard.RD++,
                                                  DatabaseService()
                                                      .commitCompanyBoard(
                                                          myBoard),
                                                  Firestore.instance
                                                      .document(cashBookPath)
                                                      .updateData({
                                                    'keihi':
                                                        FieldValue.increment(
                                                            20),
                                                  }),
                                                  //cashBook.keihi += 20,
                                                  _auth.changeCurrentOwner(),
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          '/companyBoard')),
                                                },
                                      ),
                                    ],
                                  );
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '機械購入',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visible
                        ? null
                        : () async {
                            int result = await showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return D_BuyMachines();
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: RaisedButton(
                    color: Colors.greenAccent[400],
                    child: Text(
                      '採用',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: !widget.visible
                        ? null
                        : () async {
                            int result = await showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return D_Saiyo();
                                });
                          },
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: getKantou(),
                ),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AwesomeDialog extends StatefulWidget {
  @override
  _AwesomeDialogState createState() => _AwesomeDialogState();
}

class _AwesomeDialogState extends State<AwesomeDialog> {
  AuthService _auth = AuthService();
  bool _isAwesome;
  String _awesomeText;
  int value = 0;
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  int calcCost() {
    return value * 10;
  }

  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //CompanyBoard myBoard = Provider.of<CompanyBoard>(context);
    return myBoard == null
        ? Text('Loading...')
        : AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text('広告チップ'),
            content: Text('1枚１０で購入しますか？'),
            actions: <Widget>[
              Container(
                width: 330.0,
                //color: Colors.lime,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '-',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                if (value != 0) value--;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + value.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '+',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                value++;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'CASH : ' + myBoard.cash.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          width: 80.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            ' COST : ' + calcCost().toString(),
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('cancel'),
                            onPressed: () => Navigator.of(context).pop(0),
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('OK'),
                            onPressed: myBoard.cash < calcCost() ||
                                    myBoard.cash <= 0
                                ? null
                                : () => {
                                      myBoard.kokoku += value,
                                      myBoard.cash -= calcCost(),
                                      //cashBook.keihi += calcCost(),
                                      Firestore.instance
                                          .document(cashBookPath)
                                          .updateData({
                                        'keihi':
                                            FieldValue.increment(calcCost()),
                                      }),
                                      DatabaseService()
                                          .commitCompanyBoard(myBoard),
                                      _auth.changeCurrentOwner(),
                                      Navigator.popUntil(context,
                                          ModalRoute.withName('/companyBoard')),
                                    },
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class D_Saiyo extends StatefulWidget {
  @override
  _D_SaiyoState createState() => _D_SaiyoState();
}

class _D_SaiyoState extends State<D_Saiyo> {
  int worker = 0;
  int salesman = 0;
  //CompanyBoard localMyBoard;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  int calcCost() {
    return (worker + salesman) * 5;
  }

  @override
  void initState() {
    // TODO: implement initState
    Future.wait([
      DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
            setState(() {
              myBoard = value;
            }),
          })
    ]).then((value) => print(value.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //CompanyBoard myBoard = Provider.of<CompanyBoard>(context);
    return myBoard == null
        ? Text('Loading...')
        : AlertDialog(
            title: Text('社員採用'),
            content: Text('1名５でワーカー、セールスマンを採用出来ます'),
            actions: <Widget>[
              Container(
                width: 330.0,
                //color: Colors.limeAccent,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(flex: 3, child: Text('ワーカー採用人数')),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 40.0,
                            child: RaisedButton(
                              child: Text(
                                '-',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (worker != 0) worker--;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + worker.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 40.0,
                            child: RaisedButton(
                              child: Text(
                                '+',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  worker++;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(flex: 3, child: Text('セールス採用人数')),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 40.0,
                            child: RaisedButton(
                              child: Text(
                                '-',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (salesman != 0) salesman--;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + salesman.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 40.0,
                            child: RaisedButton(
                              child: Text(
                                '+',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  salesman++;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            'CASH : ' + myBoard.cash.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          width: 50.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            ' COST : ' + calcCost().toString(),
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('cancel'),
                            onPressed: () => Navigator.of(context).pop(0),
                          ),
                        ),
                        SizedBox(width: 50.0),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('OK'),
                            onPressed: myBoard.cash < calcCost() ||
                                    myBoard.cash <= 0
                                ? null
                                : () => {
                                      myBoard.salesman += salesman,
                                      myBoard.worker += worker,
                                      myBoard.cash -= calcCost(),
                                      //cashBook.keihi += calcCost(),
                                      Firestore.instance
                                          .document(cashBookPath)
                                          .updateData({
                                        'keihi':
                                            FieldValue.increment(calcCost()),
                                      }),
                                      DatabaseService()
                                          .commitCompanyBoard(myBoard),
                                      _auth.changeCurrentOwner(),
                                      Navigator.popUntil(context,
                                          ModalRoute.withName('/companyBoard')),
                                    },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
    ;
  }
}

class D_BuyMachines extends StatefulWidget {
  @override
  _D_BuyMachinesState createState() => _D_BuyMachinesState();
}

class _D_BuyMachinesState extends State<D_BuyMachines> {
  int small = 0;
  int attach = 0;
  int big = 0;
  StreamSubscription myBoardSubsc;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;

  int calcCost() {
    return small * 100 + attach * 20 + big * 200;
  }

  @override
  void initState() {
    // TODO: implement initState
    myBoardSubsc = Firestore.instance
        .document(rootCollectionName + '/games/users/' + localuser.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          myBoard = CompanyBoard.fromFirestore(snapshot);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myBoardSubsc.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Text('Loading...')
        : AlertDialog(
            title: Text('機械購入'),
            content: Text('同時に複数購入可能です'),
            actions: <Widget>[
              Column(
                children: <Widget>[
                  Text('生産能力(1)',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  Row(
                    children: <Widget>[
                      Text('小型機械 単価:100'),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (small != 0) small--;
                            });
                          },
                        ),
                      ),
                      Text(
                        ' ' + small.toString() + ' ',
                        style: TextStyle(color: Colors.black, fontSize: 30),
                      ),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              small++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Text('小型機械の生産能力を＋１',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  Row(
                    children: <Widget>[
                      Text('アタッチメント 単価:20'),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (attach != 0) attach--;
                            });
                          },
                        ),
                      ),
                      Text(
                        ' ' + attach.toString() + ' ',
                        style: TextStyle(color: Colors.black, fontSize: 30),
                      ),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              attach++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Text('生産能力(4)',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  Row(
                    children: <Widget>[
                      Text('大型機械 単価:200'),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (big != 0) big--;
                            });
                          },
                        ),
                      ),
                      Text(
                        ' ' + big.toString() + ' ',
                        style: TextStyle(color: Colors.black, fontSize: 30),
                      ),
                      SizedBox(
                        width: 40.0,
                        child: RaisedButton(
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              big++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'CASH : ' + myBoard.cash.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(
                        width: 30.0,
                      ),
                      Text(
                        ' COST : ' + calcCost().toString(),
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        child: Text('cancel'),
                        onPressed: () => Navigator.of(context).pop(0),
                      ),
                      RaisedButton(
                        child: Text('OK'),
                        onPressed: myBoard.cash < calcCost() ||
                                myBoard.cash <= 0
                            ? null
                            : () {
                                for (int index = 0; index < small; index++) {
                                  Map<String, int> buff = Map<String, int>();
                                  buff['small'] = 100;
                                  myBoard.machines.add(buff);
                                }
                                ;
                                for (int index = 0; index < big; index++) {
                                  Map<String, int> buff = Map<String, int>();
                                  buff['big'] = 200;
                                  myBoard.machines.add(buff);
                                }
                                ;
                                for (int index = 0; index < attach; index++) {
                                  myBoard.machines.forEach((aMachine) {
                                    if (aMachine.containsKey('small')) {
                                      if (!aMachine.containsKey('attach')) {
                                        aMachine['attach'] = 20;
                                      }
                                      ;
                                    }
                                    ;
                                  });
                                }
                                ;
                                myBoard.cash -= calcCost();
                                DatabaseService().commitCompanyBoard(myBoard);
                                _auth.changeCurrentOwner();
                                Navigator.popUntil(context,
                                    ModalRoute.withName('/companyBoard'));
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
  }
}

class D_Kantou extends StatefulWidget {
  final bool visible;
  const D_Kantou({Key key, this.visible}) : super(key: key);

  @override
  _D_KantouState createState() => _D_KantouState();
}

class _D_KantouState extends State<D_Kantou> {
  int souko = 0;
  int factory = 0;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });
    super.initState();
  }

  int calcCost() {
    return souko * 2 + factory;
  }

  int calcPower() {
    int result = 0;
    int pacChip = myBoard.PAC ? 1 : 0;
    List<String> array = [];
    int big = 0;
    int small = 0;
    int attach = 0; //small with attach
    print('PAC ?' + myBoard.PAC.toString());
    print('machines :' + myBoard.machines.toString());
    print('worker : ' + myBoard.worker.toString());
    for (int index = 0; index < myBoard.machines.length; index++) {
      if (myBoard.machines[index].containsKey('attach')) {
        attach++;
        continue;
      }
      if (myBoard.machines[index].containsKey('big')) {
        big++;
        continue;
      }
      if (myBoard.machines[index].containsKey('small')) {
        small++;
      }
    }
    print('BIG :' +
        big.toString() +
        ' attach : ' +
        attach.toString() +
        ' small : ' +
        small.toString());

    for (int index = 0; index < myBoard.worker; index++) {
      if (index < big) {
        result += pacChip + 4;
        continue;
      }
      if (index < (big + attach)) {
        result += pacChip + 2;
        continue;
      }
      if (index < (big + attach + small)) result += pacChip + 1;
    }
    return result;
  }

/*
  int calcPower() {
    int result = 0;
    int pacChip = myBoard.PAC ? 1 : 0;
    List<String> array = [];
    int big =0;
    int small = 0;
    int attach = 0; //small with attach


    for (int index = 0; index < myBoard.machines.length; index++) {
      Map<String, dynamic> buff = myBoard.machines[0];
      if (buff.containsKey('attach')) {
        array.add('attach');
        continue;
      }
      if (buff.containsKey('big')) {
        array.add('big');
        continue;
      }
      if (buff.containsKey('small')) {
        array.add('small');
      }
    }

    for (int index = 0; index < myBoard.worker; index++) {
      int cnt = array.indexOf('big');
      if (cnt >= 0) {
        array.removeAt(cnt);
        result += 4 + pacChip;
        continue;
      }
      cnt = array.indexOf('attach');
      if (cnt >= 0) {
        array.removeAt(cnt);
        result += 2 + pacChip;
        continue;
      }
      cnt = array.indexOf('small');
      if (cnt >= 0) {
        array.removeAt(cnt);
        result += 1 + pacChip;
        continue;
      }
    }
    return result;
  }

 */
  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Text('Loading...')
        : AlertDialog(
            title: Text('完成投入'),
            content: Text('完成・投入個別に出来ます。'),
            actions: <Widget>[
              Container(
                //color: Colors.limeAccent,
                width: 330.0,
                child: Column(
                  children: <Widget>[
                    Text('生産能力(' + calcPower().toString() + ')',
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Text(
                                '倉庫在庫(' + myBoard.stock_room.toString() + ')')),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '-',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                if (souko != 0) souko--;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + souko.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '+',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              if (souko < myBoard.stock_room &&
                                  souko < calcPower()) {
                                setState(() {
                                  souko++;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Text('工場在庫(' +
                                myBoard.factory_room.toString() +
                                ')')),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '-',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: widget.visible
                                ? null
                                : () {
                                    setState(() {
                                      if (factory != 0) factory--;
                                    });
                                  },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + factory.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '+',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: widget.visible
                                ? null
                                : () {
                                    if (factory < myBoard.factory_room &&
                                        factory < calcPower()) {
                                      setState(() {
                                        factory++;
                                      });
                                    }
                                  },
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text(
                              '生産能力最大で完成・投入',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: widget.visible
                                ? null
                                : () {
                                    if (myBoard.stock_room >= calcPower()) {
                                      setState(() {
                                        souko = calcPower();
                                      });
                                    } else {
                                      setState(() {
                                        souko = myBoard.stock_room;
                                      });
                                    }
                                    ;
                                    if (myBoard.factory_room >= calcPower()) {
                                      setState(() {
                                        factory = calcPower();
                                      });
                                    } else {
                                      setState(() {
                                        factory = myBoard.factory_room;
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            'CASH : ' + myBoard.cash.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            ' COST : ' + calcCost().toString(),
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('cancel'),
                            onPressed: () => Navigator.of(context).pop(0),
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('OK'),
                            onPressed: myBoard.cash < calcCost() ||
                                    myBoard.cash <= 0
                                ? null
                                : () {
                                    myBoard.stock_room -= souko;
                                    myBoard.factory_room =
                                        myBoard.factory_room - factory + souko;
                                    myBoard.shop_room += factory;

                                    myBoard.cash -= souko * 2;
                                    myBoard.cash -= factory;
                                    Firestore.instance
                                        .document(cashBookPath)
                                        .updateData({
                                      'kansei': FieldValue.increment(factory),
                                      'tounyu': FieldValue.increment(souko),
                                    });
                                    //cashBook.kansei += factory;
                                    //cashBook.tounyu += souko;
                                    DatabaseService()
                                        .commitCompanyBoard(myBoard);
                                    _auth.changeCurrentOwner();
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/companyBoard'));
                                  },
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class D_Tonyu extends StatefulWidget {
  @override
  _D_TonyuState createState() => _D_TonyuState();
}

class _D_TonyuState extends State<D_Tonyu> {
  int souko = 0;
  int factory = 0;
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
          }),
        });
    super.initState();
  }

  int calcCost() {
    return souko * 2 + factory;
  }

  int calcPower() {
    int result = 0;
    int pacChip = myBoard.PAC ? 1 : 0;
    List<String> array = [];
    int big = 0;
    int small = 0;
    int attach = 0; //small with attach
    print('PAC ?' + myBoard.PAC.toString());
    print('machines :' + myBoard.machines.toString());
    print('worker : ' + myBoard.worker.toString());
    for (int index = 0; index < myBoard.machines.length; index++) {
      if (myBoard.machines[index].containsKey('attach')) {
        attach++;
        continue;
      }
      if (myBoard.machines[index].containsKey('big')) {
        big++;
        continue;
      }
      if (myBoard.machines[index].containsKey('small')) {
        small++;
      }
    }
    print('BIG :' +
        big.toString() +
        ' attach : ' +
        attach.toString() +
        ' small : ' +
        small.toString());

    for (int index = 0; index < myBoard.worker; index++) {
      if (index < big) {
        result += pacChip + 4;
        continue;
      }
      if (index < (big + attach)) {
        result += pacChip + 2;
        continue;
      }
      if (index < (big + attach + small)) result += pacChip + 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Text('Loading...')
        : AlertDialog(
            title: Text('投入'),
            content: Text('今回は投入のみ可能'),
            actions: <Widget>[
              Container(
                //color: Colors.limeAccent,
                width: 330.0,
                child: Column(
                  children: <Widget>[
                    Text('生産能力(' + calcPower().toString() + ')',
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Text(
                                '倉庫在庫(' + myBoard.stock_room.toString() + ')')),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '-',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                if (souko != 0) souko--;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + souko.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '+',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: () {
                              if (souko < myBoard.stock_room &&
                                  souko < calcPower()) {
                                setState(() {
                                  souko++;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Text('工場在庫(' +
                                myBoard.factory_room.toString() +
                                ')')),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: null,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              ' ' + factory.toString() + ' ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: null,
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            'CASH : ' + myBoard.cash.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            ' COST : ' + calcCost().toString(),
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('cancel'),
                            onPressed: () => Navigator.of(context).pop(0),
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text('OK'),
                            onPressed: myBoard.cash < calcCost() ||
                                    myBoard.cash <= 0
                                ? null
                                : () {
                                    myBoard.stock_room -= souko;
                                    myBoard.factory_room =
                                        myBoard.factory_room - factory + souko;
                                    myBoard.shop_room += factory;

                                    myBoard.cash -= souko * 2;
                                    myBoard.cash -= factory;
                                    Firestore.instance
                                        .document(cashBookPath)
                                        .updateData({
                                      'kansei': FieldValue.increment(factory),
                                      'tounyu': FieldValue.increment(souko),
                                    });
                                    //cashBook.kansei += factory;
                                    //cashBook.tounyu += souko;
                                    DatabaseService()
                                        .commitCompanyBoard(myBoard);
                                    _auth.changeCurrentOwner();
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('/companyBoard'));
                                  },
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
