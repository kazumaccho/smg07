import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/screens/bid_markets.dart';
import 'package:smg07/screens/menu_a.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class MGCard {
  bool omote = true;
  List<String> org_array = List<String>();
  double kakuritu = 0.1; //0.25;
  int index = 0;
  //List<CardType> cards;

  init() {
    createCards();
    print('LENGTH:' + org_array.length.toString());
    int dicision_length = (1 / this.kakuritu).floor() * this.org_array.length -
        this.org_array.length;
    print('DICISION LENGTH' + dicision_length.toString());
    insertArray('dicisioncard', dicision_length);

    print('LENGTH:' + org_array.length.toString());
    //cards = createCard();

    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
    org_array.shuffle();
  }

  createCards() {
    Map<String, int> hashcards = Map<String, int>();
    hashcards['risk_clarm'] = 1;
    hashcards['risk_fire'] = 1;
    hashcards['risk_matrouble'] = 1;
    hashcards['risk_miss'] = 1;
    hashcards['risk_nosell'] = 1;
    hashcards['risk_rdsuccess'] = 3;
    hashcards['risk_rousai'] = 1;
    hashcards['risk_sales'] = 3;
    hashcards['risk_salesmanretired'] = 1;
    hashcards['risk_service'] = 1;
    hashcards['risk_sick'] = 1;
    hashcards['risk_stolen'] = 1;
    hashcards['risk_strike'] = 1;
    hashcards['risk_turn'] = 1;
    hashcards['risk_worker'] = 1;

    hashcards.forEach((key, value) {
      insertArray(key, value);
    });
  }

  insertArray(cardname, cnt) {
    for (var i = 0; i < cnt; i++) {
      this.org_array.add(cardname);
    }
  }

  int pickCard() {
    int tmpIndex = index;
    if (index < org_array.length) index++;
    if (index == org_array.length) {
      index = 0;
      org_array.shuffle();
      org_array.shuffle();
      org_array.shuffle();
    }
    return tmpIndex;

    //return Clarm();
  }

  Widget pickCardWidget() {
    int tmpIndex = index;
    if (index < org_array.length) index++;
    if (index == org_array.length) {
      index = 0;
      org_array.shuffle();
      org_array.shuffle();
      org_array.shuffle();
    }

    if (org_array[tmpIndex] == 'dicisioncard')
      return S_MenuA(
        visibleImage: true,
        visible: true,
        visibleBid: true,
        visibleBuyMaterials: true,
        visibleTonyu: 2,
      );

    print('pickCardWidget -> (' +
        tmpIndex.toString() +
        ') ' +
        org_array[tmpIndex]);

    if (org_array[tmpIndex] == 'risk_clarm') return Clarm();
    if (org_array[tmpIndex] == 'risk_sick') return Sick();
    if (org_array[tmpIndex] == 'risk_strike') return Strake();
    if (org_array[tmpIndex] == 'risk_fire') return Fire();
    if (org_array[tmpIndex] == 'risk_miss') return Seizo();
    if (org_array[tmpIndex] == 'risk_stolen') return Stolen();
    if (org_array[tmpIndex] == 'risk_matrouble') return Sekkei();
    if (org_array[tmpIndex] == 'risk_rousai') return Rousai();
    if (org_array[tmpIndex] == 'risk_nosell') return MayDay();
    if (org_array[tmpIndex] == 'risk_salesmanretired') return SalesmanRetired();
    if (org_array[tmpIndex] == 'risk_worker') return WorkerRetired();
    if (org_array[tmpIndex] == 'risk_service') return TokubetuSale();
    if (org_array[tmpIndex] == 'risk_rdsuccess') return RDSuccess();
    //showDialog(context: context, child: RDSuccess());
    if (org_array[tmpIndex] == 'risk_turn') return Turn();
    if (org_array[tmpIndex] == 'risk_sales') return Dokusen();
  }
}

class TokubetuSale extends StatefulWidget {
  @override
  _TokubetuSaleState createState() => _TokubetuSaleState();
}

class _TokubetuSaleState extends State<TokubetuSale> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/success.png',
            scale: 1.2,
          ),
          Text('特別サービス', style: Theme.of(context).textTheme.headline5),
          Text('以下から１つを選択(タップで選択)',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 20.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: RaisedButton(
                    color: Colors.blueAccent,
                    child: Text(
                      '材料の特別購入　\n 1個１０で５個まで購入可能',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    onPressed: () async {
                      int result = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return TokubetuMaterials();
                          });
                    }),
              ),
              SizedBox(
                width: 50.0,
              ),
            ],
          ),
          SizedBox(
            height: 50.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: RaisedButton(
                    color: Colors.amber,
                    child: Text(
                      '広告の特別サービス \n １個５で何個でも買えます',
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                    ),
                    onPressed: () async {
                      int result = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return TokubetuKokoku();
                          });
                    }),
              ),
              SizedBox(
                width: 50.0,
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}

class TokubetuMaterials extends StatefulWidget {
  @override
  _TokubetuMaterialsState createState() => _TokubetuMaterialsState();
}

class _TokubetuMaterialsState extends State<TokubetuMaterials> {
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  int materials = 0;
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

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Scaffold(
            body: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  Image.asset(
                    'images/success.png',
                    scale: 1.2,
                  ),
                  Text('材料の特別購入(５個まで）',
                      style: Theme.of(context).textTheme.headline5),
                  Text('何個購入しますか(１個１０)',
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(flex: 2, child: Text('上限　５個まで')),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (materials != 0) materials--;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            ' ' + materials.toString() + ' ',
                            style: TextStyle(color: Colors.black, fontSize: 30),
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
                            if (materials < 5 &&
                                (myBoard.cash - materials * 10) > 0) {
                              setState(() {
                                materials++;
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
                          onPressed: () {
                            myBoard.stock_room += materials;
                            myBoard.cash -= materials * 12;
                            Firestore.instance
                                .document(cashBookPath)
                                .updateData({
                              'sumMaterials':
                                  FieldValue.increment(materials * 10),
                              'buyMaterials': FieldValue.increment(materials),
                            });

                            DatabaseService().commitCompanyBoard(myBoard);
                            _auth.changeCurrentOwner();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/companyBoard'));
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
          );
  }
}

class TokubetuKokoku extends StatefulWidget {
  @override
  _TokubetuKokokuState createState() => _TokubetuKokokuState();
}

class _TokubetuKokokuState extends State<TokubetuKokoku> {
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  int kokoku = 0;
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

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Scaffold(
            body: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  Image.asset(
                    'images/success.png',
                    scale: 1.2,
                  ),
                  Text('広告の特別サービス',
                      style: Theme.of(context).textTheme.headline5),
                  Text('何個購入しますか(１個５)',
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(flex: 2, child: Text('上限　なし')),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (kokoku != 0) kokoku--;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            ' ' + kokoku.toString() + ' ',
                            style: TextStyle(color: Colors.black, fontSize: 30),
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
                            if ((myBoard.cash - kokoku * 5) > 0) {
                              setState(() {
                                kokoku++;
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
                          onPressed: () {
                            myBoard.kokoku += kokoku;
                            myBoard.cash -= kokoku * 5;
                            Firestore.instance
                                .document(cashBookPath)
                                .updateData({
                              'keihi': FieldValue.increment(kokoku * 5),
                            });

                            DatabaseService().commitCompanyBoard(myBoard);
                            _auth.changeCurrentOwner();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/companyBoard'));
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
          );
  }
}

class RDSuccess extends StatefulWidget {
  @override
  _RDSuccessState createState() => _RDSuccessState();
}

class _RDSuccessState extends State<RDSuccess> {
  AuthService _auth = AuthService();

  CompanyBoard myBoard;
  int sales = 0;
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

  int calcPower() {
    int result = myBoard.shop_room;
    if (myBoard.salesman == 0 || myBoard.RD == 0) return 0;
    if (myBoard.RD * 2 >= result) {
      return result;
    } else {
      return myBoard.RD * 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                Image.asset(
                  'images/success.png',
                  scale: 1.2,
                ),
                Text('研究開発成功', style: Theme.of(context).textTheme.headline5),
                Text('研究開発チップ１につき２個売れる \n (１個３２)',
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(
                  height: 50.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: Text('販売可能数(' + calcPower().toString() + ')')),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(
                          '-',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            if (sales != 0) sales--;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          ' ' + sales.toString() + ' ',
                          style: TextStyle(color: Colors.black, fontSize: 30),
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
                          if (sales < calcPower()) {
                            setState(() {
                              sales++;
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
                        onPressed: () {
                          myBoard.shop_room -= sales;
                          myBoard.cash += sales * 32;
                          Firestore.instance.document(cashBookPath).updateData({
                            'uriage': FieldValue.increment(sales * 32),
                            'sales': FieldValue.increment(sales),
                          });
                          //ancestorWidgetOfExactType

                          DatabaseService().commitCompanyBoard(myBoard);
                          _auth.changeCurrentOwner();
                          Navigator.popUntil(
                              context, ModalRoute.withName('/companyBoard'));
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
          );
  }
}

class Dokusen extends StatefulWidget {
  @override
  _DokusenState createState() => _DokusenState();
}

class _DokusenState extends State<Dokusen> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/success.png',
            scale: 1.2,
          ),
          Text('商品独占販売', style: Theme.of(context).textTheme.headline5),
          Text('以下から１つを選択(タップで選択)',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 30.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 30.0,
              ),
              Expanded(
                child: RaisedButton(
                    color: Colors.blueAccent,
                    child: Text(
                      'セールスマンの努力が実る \n セールスマン１人につき、\n ２個売れます(１個３２)',
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                    onPressed: () async {
                      //Navigator.pushNamed(context, '/dokusenSalesman');
                      //Navigator.of(context).pushNamed('/dokusenSalesman');

                      int result = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return DokusenSalesMan();
                          });
                    }),
              ),
              SizedBox(
                width: 50.0,
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 30.0,
              ),
              Expanded(
                child: RaisedButton(
                    color: Colors.amber,
                    child: Text(
                      '広告効果があらわれる。\n 広告チップ１毎につき２個まで \n あいた市場に独占販売可能.',
                      style: TextStyle(color: Colors.black, fontSize: 15.0),
                    ),
                    onPressed: () async {
                      int result = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return DokusenMarkets();
                          });
                    }),
              ),
              SizedBox(
                width: 50.0,
              ),
            ],
          ),
          SizedBox(
            height: 40.0,
          ),
        ],
      ),
    );
  }
}

class DokusenSalesMan extends StatefulWidget {
  @override
  _DokusenSalesManState createState() => _DokusenSalesManState();
}

class _DokusenSalesManState extends State<DokusenSalesMan> {
  AuthService _auth = AuthService();
  CompanyBoard myBoard;
  int sales = 0;
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

  int calcPower() {
    int result = myBoard.shop_room;
    if (myBoard.salesman * 2 >= result) {
      return result;
    } else {
      return myBoard.salesman * 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Scaffold(
            body: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  Image.asset(
                    'images/success.png',
                    scale: 1.2,
                  ),
                  Text('商品独占販売', style: Theme.of(context).textTheme.headline5),
                  Text('何個販売しますか(１個３２)',
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Text('販売可能数(' + calcPower().toString() + ')')),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              if (sales != 0) sales--;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            ' ' + sales.toString() + ' ',
                            style: TextStyle(color: Colors.black, fontSize: 30),
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
                            if (sales < calcPower()) {
                              setState(() {
                                sales++;
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
                          onPressed: () {
                            myBoard.shop_room -= sales;
                            myBoard.cash += sales * 32;
                            Firestore.instance
                                .document(cashBookPath)
                                .updateData({
                              'uriage': FieldValue.increment(sales * 32),
                              'sales': FieldValue.increment(sales),
                            });

                            DatabaseService().commitCompanyBoard(myBoard);
                            _auth.changeCurrentOwner();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/companyBoard'));
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
          );
  }
}

class Clarm extends StatefulWidget {
  @override
  _ClarmState createState() => _ClarmState();
}

class _ClarmState extends State<Clarm> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/clarm.png',
            scale: 1.2,
          ),
          Text('クレーム発生', style: Theme.of(context).textTheme.headline4),
          Text('お客様から「商品」に欠陥が \n あるとクレームがつきました \n クレーム処理費５支払う',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }
}

class Sick extends StatefulWidget {
  @override
  _SickState createState() => _SickState();
}

class _SickState extends State<Sick> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    String cashBookPath = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/cashbook/' +
        globalPeriod.toString();
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/sick.png',
            scale: 1.2,
          ),
          Text('社長病気で倒れる', style: Theme.of(context).textTheme.headline4),
          Text('重要な意思決定者である \n あなたは休養を取る必要があります \n 今回はおやすみ',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }
}

class Strake extends StatefulWidget {
  @override
  _StrakeState createState() => _StrakeState();
}

class _StrakeState extends State<Strake> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    String cashBookPath = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/cashbook/' +
        globalPeriod.toString();
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/strake.png',
            scale: 0.8,
          ),
          Text('ストライキ', style: Theme.of(context).textTheme.headline4),
          Text('今回はおやすみ', style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}

class Turn extends StatefulWidget {
  @override
  _TurnState createState() => _TurnState();
}

class _TurnState extends State<Turn> {
  AuthService _auth = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    Firestore.instance
        .document(rootCollectionName + '/games')
        .get()
        .then((doc) => {
              Firestore.instance
                  .document(rootCollectionName + '/games')
                  .updateData({'direction': doc.data['direction'] * -1}),
            })
        .catchError((err) => print(err.toString()));
    //.updateData({'direction': -1});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String cashBookPath = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/cashbook/' +
        globalPeriod.toString();
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/reverse.png',
            scale: 0.8,
          ),
          Text('逆回り', style: Theme.of(context).textTheme.headline4),
          Text('親になる順番が逆になります', style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}

class Fire extends StatefulWidget {
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  void initState() {
    // TODO: implement initState
    Firestore.instance
        .document(myBoardPath)
        .get()
        .then((doc) => {
              if (doc.data['stock_room'] > 0)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'stock_lost': doc.data['stock_room'],
                    'stock_room': 0,
                  }),
                  if (doc.data['HOKEN'] == true)
                    {
                      Firestore.instance.document(myBoardPath).updateData({
                        'HOKEN': false,
                        'cash':
                            FieldValue.increment(doc.data['stock_room'] * 8),
                      }),
                      Firestore.instance.document(cashBookPath).updateData({
                        'hoken':
                            FieldValue.increment(doc.data['stock_room'] * 8),
                      }),
                    }
                }
            })
        .catchError((err) => print(err.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/fire.png',
            scale: 0.8,
          ),
          Text('火災発生', style: Theme.of(context).textTheme.headline4),
          Text('倉庫内の材料が全て燃えました \n 保険適用時１個につき８',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}

class Seizo extends StatefulWidget {
  @override
  _SeizoState createState() => _SeizoState();
}

class _SeizoState extends State<Seizo> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    Firestore.instance
        .document(myBoardPath)
        .get()
        .then((doc) => {
              if (doc.data['factory_room'] > 0)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'factory_room': FieldValue.increment(-1),
                    'factory_lost': FieldValue.increment(1),
                  }),
                }
            })
        .catchError((err) => print(err.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/miss.png',
            scale: 0.8,
          ),
          Text('製造ミス', style: Theme.of(context).textTheme.headline4),
          Text('手違いで仕掛品１個不良品 \n にしてしまいました \n 仕掛品１個廃棄',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }
}

class Stolen extends StatefulWidget {
  @override
  _StolenState createState() => _StolenState();
}

class _StolenState extends State<Stolen> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    Firestore.instance
        .document(myBoardPath)
        .get()
        .then((doc) => {
              if (doc.data['shop_room'] > 2)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'shop_room': FieldValue.increment(-2),
                    'shop_lost': FieldValue.increment(2),
                  }),
                  if (doc.data['HOKEN'] == true)
                    {
                      Firestore.instance.document(myBoardPath).updateData({
                        'HOKEN': false,
                        'cash': FieldValue.increment(20),
                      }),
                      Firestore.instance.document(cashBookPath).updateData({
                        'hoken': FieldValue.increment(20),
                      }),
                    }
                }
              else if (doc.data['shop_room'] == 1)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'shop_room': FieldValue.increment(-1),
                    'shop_lost': FieldValue.increment(1),
                  }),
                  if (doc.data['HOKEN'] == true)
                    {
                      Firestore.instance.document(myBoardPath).updateData({
                        'HOKEN': false,
                        'cash': FieldValue.increment(10),
                      }),
                      Firestore.instance.document(cashBookPath).updateData({
                        'hoken': FieldValue.increment(10),
                      }),
                    }
                }
            })
        .catchError((err) => print(err.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/stoled.png',
            scale: 1.5,
          ),
          Text('盗難発生', style: Theme.of(context).textTheme.headline5),
          Text('営業所内の商品２個 \n 盗まれているのを発見 \n 保険適用時１個につき１０',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}

class Sekkei extends StatefulWidget {
  @override
  _SekkeiState createState() => _SekkeiState();
}

class _SekkeiState extends State<Sekkei> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/broke.png',
            scale: 1.2,
          ),
          Text('機械故障', style: Theme.of(context).textTheme.headline4),
          Text('改修費として５支払う', style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 10.0,
          ),
          Container(
            //color: Colors.blueAccent,
            child: S_MenuA(
              visibleImage: false,
              visible: false,
              visibleBid: true,
              visibleBuyMaterials: true,
              visibleTonyu: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class Rousai extends StatefulWidget {
  @override
  _RousaiState createState() => _RousaiState();
}

class _RousaiState extends State<Rousai> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Image.asset(
            'images/rousai.png',
            scale: 1.5,
          ),
          Text('労災発生', style: Theme.of(context).textTheme.headline4),
          Text('ワーカーが怪我をしました。 \n 今回は生産活動ができません',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 10.0,
          ),
          Container(
              //color: Colors.blueAccent,
              child: S_MenuA(
            visibleImage: false,
            visible: false,
            visibleBid: true,
            visibleBuyMaterials: true,
            visibleTonyu: 0,
          )),
        ],
      ),
    );
  }
}

class MayDay extends StatefulWidget {
  @override
  _MayDayState createState() => _MayDayState();
}

class _MayDayState extends State<MayDay> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Image.asset(
            'images/consumer.png',
            scale: 1.5,
          ),
          Text('消費者運動発生', style: Theme.of(context).textTheme.headline5),
          Text('不買運動のため今回商品の \n 販売は出来ません',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 10.0,
          ),
          Container(
              //color: Colors.blueAccent,
              child: S_MenuA(
            visibleImage: false,
            visible: false,
            visibleBid: false,
            visibleBuyMaterials: true,
            visibleTonyu: 1,
          )),
        ],
      ),
    );
  }
}

class SalesmanRetired extends StatefulWidget {
  @override
  _SalesmanRetiredState createState() => _SalesmanRetiredState();
}

class _SalesmanRetiredState extends State<SalesmanRetired> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });

    Firestore.instance
        .document(myBoardPath)
        .get()
        .then((doc) => {
              if (doc.data['salesman'] > 0)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'salesman': FieldValue.increment(-1),
                    'retires': FieldValue.increment(1),
                  }),
                }
            })
        .catchError((err) => print(err.toString()));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/retired.png',
            scale: 1.2,
          ),
          Text('セールスマン退職', style: Theme.of(context).textTheme.headline5),
          Text('セールスマン１名退職しました \n 退職金５支払う',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 10.0,
          ),
          Container(
              //color: Colors.blueAccent,
              child: S_MenuA(
            visibleImage: false,
            visible: false,
            visibleBid: false,
            visibleBuyMaterials: true,
            visibleTonyu: 1,
          )),
        ],
      ),
    );
  }
}

class WorkerRetired extends StatefulWidget {
  @override
  _WorkerRetiredState createState() => _WorkerRetiredState();
}

class _WorkerRetiredState extends State<WorkerRetired> {
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  @override
  void initState() {
    // TODO: implement initState
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });
    Firestore.instance
        .document(myBoardPath)
        .get()
        .then((doc) => {
              if (doc.data['worker'] > 0)
                {
                  Firestore.instance.document(myBoardPath).updateData({
                    'worker': FieldValue.increment(-1),
                    'retires': FieldValue.increment(1),
                  }),
                }
            })
        .catchError((err) => print(err.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Image.asset(
            'images/retired.png',
            scale: 1,
          ),
          Text('ワーカー退職', style: Theme.of(context).textTheme.headline5),
          Text('習熟したワーカーが１名退職 \n 退職金５支払う',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(
            height: 10.0,
          ),
          Container(
              //color: Colors.blueAccent,
              child: S_MenuA(
            visibleImage: false,
            visible: false,
            visibleBid: true,
            visibleBuyMaterials: true,
            visibleTonyu: 0,
          )),
        ],
      ),
    );
  }
}
