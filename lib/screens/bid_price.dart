import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/bloc/bloc_bid_book.dart';
import 'package:smg07/models/bloc/bloc_markets.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_BidPrice2 extends StatefulWidget {
  @override
  _S_BidPrice2State createState() => _S_BidPrice2State();
}

class _S_BidPrice2State extends State<S_BidPrice2> {
  //StreamSubscription bookSubsc;
  final AuthService _auth = AuthService();
  bool loading = false;
  List<int> prices = List<int>();
  List<int> maxPrice = List<int>();
  StreamSubscription myBoardSubsc;
  CompanyBoard myBoard;
  BlocBidBook blocBidBook;
  BlocMarket blocMarket;

  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  String path = rootCollectionName +
      '/combat_data/combat_history/' +
      globalSerialNo.toString();

  void initState() {
    // TODO: implement initState

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

  @override
  void dispose() {
    // TODO: implement dispose
    myBoardSubsc.cancel();
    //bookSubsc.cancel();
    super.dispose();
  }

  int calcPower() {
    int result = myBoard.RD * 2;

    return result;
  }

  Widget getMarket(int index) {
    prices.add(20);
    blocMarket.updateMarketPath(blocBidBook.bidBook.markets[index]);
    maxPrice.add(blocMarket.market.maxPrice);
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
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: MarketName(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              blocBidBook.bidBook.volumes[index].toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: MaxPrice(),
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
                            if (prices[index] > 20) {
                              setState(() {
                                prices[index]--;
                              });
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
                              prices[index] = blocMarket.market.maxPrice;
                            });
                            print(
                                'prices[index] = ' + prices[index].toString());
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
                            if (blocMarket.market.maxPrice > prices[index]) {
                              setState(() {
                                prices[index]++;
                              });
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
                  prices[index].toString(),
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
    blocBidBook = Provider.of<BlocBidBook>(context);
    blocBidBook.updateBidBookPath(path);
    blocMarket = Provider.of<BlocMarket>(context);

    return !blocBidBook.isAllBid()
        ? Loading()
        : Scaffold(
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '親入札数()',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'MAX価格',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '入札価格',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                      ],
                    ),
                  ),
                  for (int index = 0;
                      index < blocBidBook.bidBook.markets.length;
                      index++)
                    getMarket(index),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '価格競争力(' + calcPower().toString() + ') ',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50.0,
                        ),
                        SizedBox(
                          width: 100.0,
                        ),
                        RaisedButton(
                          child: Text("入札"),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            dynamic result = await _auth.bidPrice(
                                blocBidBook.bidBook.markets,
                                prices,
                                myBoard.RD,
                                myBoard.companyName,
                                myBoard.MR,
                                maxPrice);
                            if (result == null) {
                            } else {
                              Navigator.of(context).pushNamed('/bidResult');
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
    //});
  }
}

class S_BidPrice4Client extends StatefulWidget {
  @override
  _S_BidPrice4ClientState createState() => _S_BidPrice4ClientState();
}

class _S_BidPrice4ClientState extends State<S_BidPrice4Client> {
  final AuthService _auth = AuthService();
  bool loading = false;
  //BidBook book;
  List<int> prices;
  List<String> marketName = [];
  List<int> maxPrice = [];
  List<int> myBids = [];
  CompanyBoard myBoard;
  BlocBidBook blocBidBook;
  BlocMarket blockMarket;
  String path = rootCollectionName +
      '/combat_data/combat_history/' +
      globalSerialNo.toString();

  int calcPower() {
    int result = myBoard.RD * 2;

    return result;
  }

  Widget getMarket(int index) {
    marketName.add(null);
    maxPrice.add(0);
    myBids.add(0);
    blockMarket.updateMarketPath(blocBidBook.bidBook.markets[index]);
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
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: MarketName(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              blocBidBook.bidBook.volumes[index].toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: myBids[index] != 0
                              ? Text(myBids[index].toString(),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 30))
                              : FutureBuilder(
                                  future: Firestore.instance
                                      .document(rootCollectionName +
                                          '/combat_data/combat_history/' +
                                          globalSerialNo.toString() +
                                          '/markets/' +
                                          blocBidBook.bidBook.markets[index] +
                                          '/bidders/' +
                                          localuser.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done)
                                      return Text('Loading...');
                                    if (snapshot.hasData) {
                                      myBids[index] = snapshot.data['volume'];
                                      if (myBids[index] == 0) prices[index] = 0;
                                      return Text(
                                        myBids[index].toString(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 30),
                                      );
                                    } else {
                                      return Text('Loading...');
                                    }
                                  },
                                ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: MaxPrice(),
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
                          onPressed: myBids[index] == 0
                              ? null
                              : () {
                                  if (prices[index] > 20) {
                                    setState(() {
                                      prices[index]--;
                                    });
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
                          onPressed: myBids[index] == 0
                              ? null
                              : () {
                                  setState(() {
                                    prices[index] = maxPrice[index];
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
                          onPressed: myBids[index] == 0
                              ? null
                              : () {
                                  if (maxPrice[index] > prices[index])
                                    setState(() {
                                      prices[index]++;
                                    });
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
                  myBids[index] == 0
                      ? myBids[index].toString()
                      : prices[index].toString(),
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
  void initState() {
    // TODO: implement initState

    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
          setState(() {
            myBoard = value;
            List.generate(myBoard.machines.length, (index) => false);
          }),
        });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    blocBidBook = Provider.of<BlocBidBook>(context);
    blocBidBook.updateBidBookPath(path);
    blockMarket = Provider.of<BlocMarket>(context);
    prices = List.generate(blocBidBook.bidBook.volumes.length, (index) => 20);

    return Scaffold(
      body: Container(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 1.0))),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Text(
                        '市場',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '親入札数()',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '自入札数()',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          'MAX価格',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '入札価格',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      )),
                ],
              ),
            ),
            for (int index = 0;
                index < blocBidBook.bidBook.markets.length;
                index++)
              getMarket(index),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '価格競争力(' + calcPower().toString() + ') ',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 50.0,
                  ),
                  SizedBox(
                    width: 100.0,
                  ),
                  RaisedButton(
                    child: Text("入札"),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      dynamic result = await _auth.bidPrice(
                          blocBidBook.bidBook.markets,
                          prices,
                          myBoard.RD,
                          myBoard.companyName,
                          myBoard.MR,
                          maxPrice);

                      if (result == null) {
                      } else {
                        Navigator.of(context).pushNamed('/bidResult');
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
class S_BidPrice2 extends StatefulWidget {
  @override
  _S_BidPrice2State createState() => _S_BidPrice2State();
}

class _S_BidPrice2State extends State<S_BidPrice2> {
  //StreamSubscription bookSubsc;
  final AuthService _auth = AuthService();
  bool loading = false;
  DocumentReference marketRef;
  List<String> marketName = [];
  List<int> maxPrice = [];
  BidBook book;
  List<int> prices = List<int>();
  StreamSubscription myBoardSubsc;
  CompanyBoard myBoard;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  void initState() {
    /*
    // TODO: implement initState
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    //print('path : ' + path);

    bookSubsc = Firestore.instance.document(path).snapshots().listen((doc) {
      book = BidBook.fromFirestore(doc);
      prices = List.generate(book.volumes.length, (index) => 20);
    });

     */

    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    Firestore.instance.document(path).get().then((value) => {
          setState(() {
            book = BidBook.fromFirestore(value);
          }),
        });

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

  @override
  void dispose() {
    // TODO: implement dispose
    myBoardSubsc.cancel();
    //bookSubsc.cancel();
    super.dispose();
  }

  int calcPower() {
    int result = myBoard.RD * 2;

    return result;
  }

  Widget getMarket(int index) {
    marketName.add(null);
    maxPrice.add(0);
    prices.add(20);
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
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: marketName[index] != null
                              ? Text(
                                  marketName[index],
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 30),
                                )
                              : FutureBuilder(
                                  future: Firestore.instance
                                      .document(rootCollectionName +
                                          '/games/markets/' +
                                          book.markets[index])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done)
                                      return Text('Loading...');

                                    if (snapshot.hasData) {
                                      marketName[index] = snapshot.data['name'];

                                      return Text(
                                        marketName[index],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 30),
                                      );
                                    } else {
                                      return Text('Loading...');
                                    }
                                  },
                                ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              book.volumes[index].toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: maxPrice[index] != 0
                                ? Text(maxPrice[index].toString(),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 30))
                                : FutureBuilder(
                                    future: Firestore.instance
                                        .document(rootCollectionName +
                                            '/games/markets/' +
                                            book.markets[index])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState !=
                                          ConnectionState.done)
                                        return Text('Loading...');
                                      if (snapshot.hasData) {
                                        maxPrice[index] =
                                            snapshot.data['maxPrice'];
                                        return Text(
                                          maxPrice[index].toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 30),
                                        );
                                      } else {
                                        return Text('Loading...');
                                      }
                                    },
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
                            if (prices[index] > 20) {
                              setState(() {
                                prices[index]--;
                              });
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
                            print('maxPrice[index] = ' +
                                maxPrice[index].toString());
                            setState(() {
                              prices[index] = maxPrice[index];
                            });
                            print(
                                'prices[index] = ' + prices[index].toString());
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
                            if (maxPrice[index] > prices[index]) {
                              setState(() {
                                prices[index]++;
                              });
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
                  prices[index].toString(),
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
    /*
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    return StreamBuilder<DocumentSnapshot>(
        initialData: null,
        stream: Firestore.instance.document(path).snapshots(),
        builder: (context, snapshot) {
          if (snapshot == null) return Loading();
          if (snapshot.connectionState != ConnectionState.active)
            return Loading();
          if (!snapshot.hasData) return Loading();
          if (snapshot.data == null) return Loading();

          book = BidBook.fromFirestore(snapshot.data);
          //prices = List.generate(book.volumes.length, (index) => 20);

     */

    return book == null
        ? Loading()
        : Scaffold(
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '親入札数()',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'MAX価格',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '入札価格',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            )),
                      ],
                    ),
                  ),
                  for (int index = 0; index < book.markets.length; index++)
                    getMarket(index),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '価格競争力(' + calcPower().toString() + ') ',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50.0,
                        ),
                        SizedBox(
                          width: 100.0,
                        ),
                        RaisedButton(
                          child: Text("入札"),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            dynamic result = await _auth.bidPrice(
                                book.markets,
                                prices,
                                myBoard.RD,
                                myBoard.companyName,
                                myBoard.MR,
                                maxPrice);
                            if (result == null) {
                            } else {
                              Navigator.of(context).pushNamed('/bidResult');
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
    //});
  }
}

 */
