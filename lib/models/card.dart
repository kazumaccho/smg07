import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smg07/screens/menu_a.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';

import 'company_board.dart';

/*
  カードをシャッフルして、ルールAを表示するのか、
  リスクカードを表示する
　カード名がNavigatorの遷移先とする

 */

class MGCard {
  bool omote = true;
  List<String> org_array = List<String>();
  double kakuritu = 0.5; //0.25;
  int index = 0;
  List<CardType> cards;

  init() {
    createCards();
    int dicision_length = (1 / this.kakuritu).floor() * this.org_array.length -
        this.org_array.length;
    insertArray('dicisioncard', dicision_length);

    cards = createCard();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
  }

  createCards() {
    Map<String, int> hashcards = Map<String, int>();
    hashcards['risk_clarm'] = 1;
    hashcards['risk_fire'] = 1;
    hashcards['risk_matrouble'] = 1;
    hashcards['risk_miss'] = 1;
    hashcards['risk_nosell'] = 1;
    hashcards['risk_rdfail'] = 1;
    hashcards['risk_rdsuccess'] = 3;
    hashcards['risk_rousai'] = 1;
    hashcards['risk_sales'] = 3;
    hashcards['risk_salesmanretired'] = 1;
    hashcards['risk_service'] = 1;
    hashcards['risk_sick'] = 1;
    hashcards['risk_stocker'] = 1;
    hashcards['risk_stolen'] = 1;
    hashcards['risk_strike'] = 1;
    hashcards['risk_trouble'] = 1;
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

  createCard() {
    List<CardType> result = [];
    for (int cnt = 0; cnt < this.org_array.length; cnt++) {
      //dicisioncard

      if (org_array[cnt] == 'dicisioncard') result.add(Normal());
      if (org_array[cnt] == 'risk_clarm') result.add(Clarm());
      if (org_array[cnt] == 'risk_fire') result.add(Fire());
      if (org_array[cnt] == 'risk_rousai') result.add(Rousai());
      if (org_array[cnt] == 'risk_salesmanretired')
        result.add(SalesmanRetired());
      if (org_array[cnt] == 'risk_worker') result.add(WorkerRetired());
      if (org_array[cnt] == 'risk_matrouble') result.add(fixMachine());
      if (org_array[cnt] == 'risk_nosell') result.add(Consumer());
      if (org_array[cnt] == 'risk_matrouble') result.add(Sekkei());
      if (org_array[cnt] == 'risk_miss') result.add(Seizou());
      if (org_array[cnt] == 'risk_stolen') result.add(Stolen());
      if (org_array[cnt] == 'risk_sick') result.add(Sick());
      if (org_array[cnt] == 'risk_strike') result.add(Strake());
      if (org_array[cnt] == 'risk_turn') result.add(Reverse());
      if (org_array[cnt] == 'risk_rdsuccess') result.add(RDSuccess());
      if (org_array[cnt] == 'risk_sales') result.add(Dokusen());
      if (org_array[cnt] == 'risk_service') result.add(Tokubetu());
    }
    return result;
  }

  CardType pickCard() {
    int tmpIndex = index;
    if (index < cards.length) index++;
    if (index == cards.length) {
      index = 0;
      cards.shuffle();
      cards.shuffle();
      cards.shuffle();
    }
    return cards[tmpIndex];

    return Clarm();
  }
}

/*
    -1 omote
     0 normal
     1 itibu menu hanbai
     2 itibu menu tounyu
     3 menu nasi
     4 select
 */

abstract class CardType {
  final int cardType;
  final String title;
  final List<String> messeages;
  final Image image;

  CardType({this.cardType, this.title, this.messeages, this.image});

  void calc();
  List<Widget> flatbuttons();
}

class Omote extends CardType {
  Omote()
      : super(
          cardType: -1,
          title: '',
          messeages: [],
          image: Image.asset('images/omote.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Normal extends CardType {
  Normal()
      : super(
          cardType: 0,
          title: '',
          messeages: [],
          image: Image.asset('images/normal.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: true,
        visibleBid: true,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class Clarm extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  Clarm()
      : super(
          cardType: 2,
          title: 'クレーム発生',
          messeages: ['お客様から「商品」に欠陥が', 'あるとクレームがつきました', 'クレーム処理費５支払う'],
          image: Image.asset('images/clarm.png'),
        );

  @override
  void calc() {
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: false,
        visibleBuyMaterials: true,
      )
    ];
    //this.visibleBuyMaterials, this.visibleBid, this.visible
  }
}

class Consumer extends CardType {
  Consumer()
      : super(
          cardType: 2,
          title: '消費者運動発生',
          messeages: ['不買運動のため今回商品の', '販売は出来ません'],
          image: Image.asset('images/consumer.png'),
        );

  @override
  void calc() {
    //
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: false,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class SalesmanRetired extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  SalesmanRetired()
      : super(
          cardType: 2,
          title: 'セールスマン退職',
          messeages: ['セールスマン１名退職', 'しました', '退職金５'],
          image: Image.asset('images/retired.png'),
        );

  @override
  void calc() {
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
    //if (shareMyBoard.salesman > 0) {

    //shareMyBoard.salesman--;
    //shareMyBoard.retires++;
    //}
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: false,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class Rousai extends CardType {
  Rousai()
      : super(
          cardType: 1,
          title: '労災発生',
          messeages: ['ワーカーが怪我をしました。', '今回は生産活動ができません'],
          image: Image.asset('images/rousai.png'),
        );

  @override
  void calc() {
    //shareMyBoard.cash -= 5;
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: true,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class fixMachine extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  fixMachine()
      : super(
          cardType: 1,
          title: '機械故障',
          messeages: ['修理費５を支払う'],
          image: Image.asset('images/broke.png'),
        );

  @override
  void calc() {
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: true,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class WorkerRetired extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  WorkerRetired()
      : super(
          cardType: 1,
          title: 'ワーカー退職',
          messeages: ['習熟したワーカーが１名退職', 'しました', '退職金５'],
          image: Image.asset('images/retired.png'),
        );

  @override
  void calc() {
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
    /*
    if (shareMyBoard.worker > 0) {
      ;
      //shareMyBoard.worker--;
      //shareMyBoard.retires++;
    }

     */
  }

  @override
  List<Widget> flatbuttons() {
    return [
      S_MenuA(
        visible: false,
        visibleBid: true,
        visibleBuyMaterials: true,
      )
    ];
  }
}

class Sekkei extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  Sekkei()
      : super(
          cardType: 3,
          title: '設計トラブル',
          messeages: ['改修費として５支払う'],
          image: Image.asset('images/miss.png'),
        );

  @override
  void calc() {
    //shareMyBoard.cash -= 5;
    Firestore.instance.document(myBoardPath).updateData({
      'cash': FieldValue.increment(-5),
    });
    //cashBook.keihi += 5;
    Firestore.instance.document(cashBookPath).updateData({
      'keihi': FieldValue.increment(5),
    });
  }

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Seizou extends CardType {
  Seizou()
      : super(
          cardType: 3,
          title: '製造ミス',
          messeages: ['手違いで仕掛品１個不良品', 'にしてしまいました', '仕掛品１個廃棄'],
          image: Image.asset('images/miss.png'),
        );

  @override
  void calc() {
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
    /*
    if (shareMyBoard.factory_room > 0) {
      Firestore.instance.document(myBoardPath).updateData({
        'factory_room': FieldValue.increment(-1),
        'factory_lost': FieldValue.increment(1),
      });
      //shareMyBoard.factory_room--;
      //shareMyBoard.factory_lost++;
    }
    */
  }

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Stolen extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  Stolen()
      : super(
          cardType: 3,
          title: '盗難発生',
          messeages: ['営業所内の商品２個', '盗まれているのを発見', '保険適用があれば１個につき１０受け取れます'],
          image: Image.asset('images/stoled.png'),
        );

  @override
  void calc() {
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
/*
    if (shareMyBoard.shop_room > 2) {
      shareMyBoard.factory_room -= 2;
      shareMyBoard.factory_lost += 2;
      if (shareMyBoard.HOKEN) {
        shareMyBoard.HOKEN = false;
        shareMyBoard.cash += 20;
        //cashBook.hoken += 20;
        Firestore.instance.document(cashBookPath).updateData({
          'hoken': FieldValue.increment(20),
        });
      }
    } else if (shareMyBoard == 1) {
      shareMyBoard.factory_room--;
      shareMyBoard.factory_lost++;
      if (shareMyBoard.HOKEN) {
        shareMyBoard.HOKEN = false;
        shareMyBoard.cash += 10;
        //cashBook.hoken += 10;
        Firestore.instance.document(cashBookPath).updateData({
          'hoken': FieldValue.increment(10),
        });
      }
    }
    */
  }

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Fire extends CardType {
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  Fire()
      : super(
          cardType: 3,
          title: '火災発生',
          messeages: ['倉庫内の材料が全て燃えました', '保険適用があれば１個につき８受け取れます'],
          image: Image.asset('images/fire.png'),
        );

  @override
  void calc() {
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
    /*
    if (shareMyBoard.stock_room > 0) {
      shareMyBoard.stock_lost += shareMyBoard.stock_room;
      if (shareMyBoard.HOKEN) {
        shareMyBoard.HOKEN = false;
        shareMyBoard.cash += shareMyBoard.stock_room * 8;
        //cashBook.hoken += shareMyBoard.stock_room * 8;
        Firestore.instance.document(cashBookPath).updateData({
          'hoken': FieldValue.increment(shareMyBoard.stock_room * 8),
        });
      }
      shareMyBoard.stock_room = 0;
    }
    */
  }

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Sick extends CardType {
  Sick()
      : super(
          cardType: 3,
          title: '社長病気で倒れる',
          messeages: ['重要な意思決定者である', 'あなたは休養を取る必要があります', '今回はおやすみ'],
          image: Image.asset('images/sick.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Strake extends CardType {
  Strake()
      : super(
          cardType: 3,
          title: 'ストライク',
          messeages: ['今回はおやすみ'],
          image: Image.asset('images/strake.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class Reverse extends CardType {
  Reverse()
      : super(
          cardType: 3,
          title: '逆回り',
          messeages: ['親になる順番が逆になります'],
          image: Image.asset('images/reverse.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [];
  }
}

class S_RDSuccess extends StatefulWidget {
  @override
  _S_RDSuccessState createState() => _S_RDSuccessState();
}

class _S_RDSuccessState extends State<S_RDSuccess> {
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

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Text('Loading...')
        : Container(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 20.0,
                ),
                RaisedButton(
                  child: Text('cancel'),
                  onPressed: () => Navigator.popUntil(
                      context, ModalRoute.withName('/companyBoard')),
                ),
                SizedBox(
                  width: 20.0,
                ),
                RaisedButton(
                    child: Text('販売'),
                    onPressed: myBoard.RD == 0
                        ? null
                        : () async => {
                              if ((myBoard.RD * 2) >= myBoard.shop_room)
                                {
                                  myBoard.cash += myBoard.shop_room * 32,
                                  Firestore.instance
                                      .document(cashBookPath)
                                      .updateData({
                                    'sales':
                                        FieldValue.increment(myBoard.shop_room),
                                    'uriage': FieldValue.increment(
                                        myBoard.shop_room * 32),
                                  }),
                                  //cashBook.sales += shareMyBoard.shop_room,
                                  //cashBook.uriage += shareMyBoard.shop_room * 32,
                                  myBoard.shop_room = 0,
                                }
                              else
                                {
                                  myBoard.cash += myBoard.RD * 2 * 32,
                                  Firestore.instance
                                      .document(cashBookPath)
                                      .updateData({
                                    'sales':
                                        FieldValue.increment(myBoard.RD * 2),
                                    'uriage': FieldValue.increment(
                                        myBoard.RD * 2 * 32),
                                  }),
                                  //cashBook.sales += shareMyBoard.RD * 2,
                                  //cashBook.uriage += shareMyBoard.RD * 2 * 32,
                                  myBoard.shop_room -= myBoard.RD * 2,
                                },
                              await DatabaseService()
                                  .commitCompanyBoard(myBoard),
                              AuthService().changeCurrentOwner(),
                              Navigator.popUntil(context,
                                  ModalRoute.withName('/companyBoard')),
                            }),
              ],
            ),
          );
  }
}

class RDSuccess extends CardType {
  RDSuccess()
      : super(
          cardType: 4,
          title: '研究開発成功',
          messeages: ['研究開発チップ１につき２個売れる', '１個３２で'],
          image: Image.asset('images/success.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    return [S_RDSuccess()];
  }
}

class Dokusen extends CardType {
  Dokusen()
      : super(
          cardType: 4,
          title: '商品独占販売',
          messeages: ['以下から１つを選択'],
          image: Image.asset('images/reverse.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    /*
              title: '商品独占販売',
          messeages: ['以下から１つを選択'],
          image: Image.asset('images/reverse.png'),

      セールスマンの努力が実る
      セールスマン１人につき、２個売れます。
      １個３２で

      広告効果があらあれる。
      広告チップ１毎につき２個まで
      あいた市場に独占販売可能.

     */
    return [];
  }
}

class S_Tokubetu extends StatefulWidget {
  @override
  _S_TokubetuState createState() => _S_TokubetuState();
}

class _S_TokubetuState extends State<S_Tokubetu> {
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

  @override
  Widget build(BuildContext context) {
    /*
    　材料の特別購入
    　１個１０で５個まで購入可

    　広告の特別サービス
　　　 １個５で何個でも買えます

     */
    double value = 1.0;
    int kokoku = 0;
    return Container(
      child: Column(
        children: <Widget>[
          //１個10で５個まで　材料
          Text('特別購入'),
          Text('以下の２つから一つを選択可能'),
          Text('１個１０で５個まで材料購入可能'),
          Row(
            children: <Widget>[
              Slider(
                value: value,
                onChanged: (newRating) {
                  if (myBoard.cash >= value.toInt() * 5) {
                    setState(() {
                      value = newRating;
                    });
                  }
                },
                max: 5,
                min: 1,
                label: value.toString(),
              ),
              RaisedButton(
                  child: Text('販売'),
                  onPressed: () async => {
                        myBoard.stock_room += value.toInt(),
                        myBoard.cash -= value.toInt() * 10,
                        //cashBook.buyMaterials += value.toInt(),
                        Firestore.instance.document(cashBookPath).updateData({
                          'buyMaterials': FieldValue.increment(value.toInt()),
                        }),
                        await DatabaseService().commitCompanyBoard(myBoard),
                        AuthService().changeCurrentOwner(),
                        Navigator.popUntil(
                            context, ModalRoute.withName('/companyBoard')),
                      }),
            ],
          ),
          //1個５で何個でも　広告
          Text('１個５で何個でも広告を購入可能'),
          Row(
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
                  if (kokoku > 0) {
                    setState(() {
                      kokoku--;
                    });
                  }
                },
              ),
              Text(value.toString()),
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
                  if (myBoard.cash >= (kokoku + 1) * 5) {
                    kokoku++;
                  }
                },
              ),
              FlatButton(
                  child: Text('広告購入'),
                  onPressed: () async => {
                        myBoard.kokoku += kokoku,
                        myBoard.cash -= kokoku * 5,
                        //cashBook.keihi += kokoku * 5,
                        Firestore.instance.document(cashBookPath).updateData({
                          'keihi': FieldValue.increment(kokoku * 5),
                        }),
                        await DatabaseService().commitCompanyBoard(myBoard),
                        AuthService().changeCurrentOwner(),
                        Navigator.popUntil(
                            context, ModalRoute.withName('/companyBoard')),
                      }),
            ],
          ),
        ],
      ),
    );
  }
}

class Tokubetu extends CardType {
  Tokubetu()
      : super(
          cardType: 4,
          title: '特別サービス',
          messeages: ['以下から１つを選択'],
          image: Image.asset('images/success.png'),
        );

  @override
  void calc() {}

  @override
  List<Widget> flatbuttons() {
    /*
    　材料の特別購入
    　１個１０で５個まで購入可

    　広告の特別サービス
　　　 １個５で何個でも買えます

     */
    return [S_Tokubetu()];
  }
}
