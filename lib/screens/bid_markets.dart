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

class S_BidMarkets2 extends StatefulWidget {
  @override
  _S_BidMarkets2State createState() => _S_BidMarkets2State();
}

class _S_BidMarkets2State extends State<S_BidMarkets2> {
  StreamSubscription marketSubsc;
  //DocumentReference marketRef;
  List<M_Markets> markets;
  List<int> materials;
  int overSeaMaterials = 0;
  int cost = 0;
  CompanyBoard myBoard;
  int shop_room_materials;
  AuthService _auth = AuthService();
  //CompanyBoard localBoard;

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
        .collection(rootCollectionName+ '/games/markets')
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
    materials = [0, 0, 0, 0, 0, 0];
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
      setState(() {
        myBoard = value;
        shop_room_materials = myBoard.shop_room;
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

  int calcPower(){
    int result = 0;
    int chips = myBoard.kokoku;
    for(int index = 0; index < myBoard.salesman ; index++){

      result +=2;

      if(chips >2){
        chips -=2;
        result +=4;
      }else{
        result += chips * 2;
        chips =0;
      }

    }

    return result;
  }

  Map<String,int> setBids(){
    Map<String,int> result = Map<String,int>();
    for(int index = 0 ; index < markets.length ; index++){
      if(materials[index] > 0)
      result[markets[index].documentID] = materials[index];
    }
    return result;
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
                              (markets[index].maxVolume -
                                          markets[index].currentMaterials)
                                      .toString() ??
                                  0,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              markets[index].maxPrice.toString() ?? 0,
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
                            if (materials[index] != 0 && shop_room_materials < myBoard.shop_room) {
                              setState(() {
                                materials[index]--;
                                shop_room_materials++;
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
                            //手持ちの数 :   販売能力 :  販売可能数  1 2 3  3 2 1  3 2 3
                            //result 現在の販売可能数　
                            int result = (markets[index].maxVolume - markets[index].currentMaterials - materials[index]);
                            print('マーケット自体の最大入札可能数:'+result.toString());
                            // 入札可能数が販売可能数を超えていたら、販売可能数に制限
                            if(result > (calcPower() - materials.reduce((a,b) => a+b))) result = calcPower() - materials.reduce((a,b) => a+b);
                            //print('販売可能数に制限した場合:'+result.toString());
                            //入札可能な余地
                            //result -= materials.reduce((a,b) => a+b);
                            print('すでに入札した分を引く '+ result.toString());
                            if(result > 0){
                              if(result >= shop_room_materials){
                                setState(() {
                                  materials[index] += shop_room_materials;
                                  shop_room_materials = 0;
                                });
                              }else{
                                setState(() {
                                  shop_room_materials -= result;
                                  materials[index] += result;
                                });
                              }

                            }
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
                            //販売可能在庫が１以上　＆＆　入札数が 入札可能数以内 && 現在のマーケット入札数が、マーケットの空き数以内。
                            if(shop_room_materials > 0 && materials.reduce((a,b) => a+b) < calcPower() && materials[index] < (markets[index].maxVolume - markets[index].currentMaterials)){
                              setState(() {
                                shop_room_materials--;
                                materials[index]++;
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
                                  '販売可能数',
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
                                  '入札数',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              )),
                        ],
                      ),
                    ),
                    for (int index = 0; index < markets.length; index++)
                      getMarket(index),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          //Text(
                          //  '入札可能数(' + shop_room_materials.toString() +') ',
                          //  style: TextStyle(color: Colors.black, fontSize: 20),
                          //),
                          Text(
                            '販売能力(' + calcPower().toString() +') ',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          Text(
                            '営業所在庫(' + myBoard.shop_room.toString() +') ',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),

                        ],
                      ),),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 50.0,
                          ),
                          RaisedButton(
                            child: Text("Cancel"),
                            color: Colors.black12,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(
                            width: 100.0,
                          ),
                          RaisedButton(
                            child: Text("入札"),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed:  () async {
                                    //print('setBid : ' + setBids().toString());

                                    await _auth.createBidBook(this.setBids());
                                    //await DatabaseService().commitCompanyBoard(myBoard);
                                    //await DatabaseService().commitCashBook(globalPeriod);

                                    Navigator.of(context).pushNamed('/bidPrice');


                                  },
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


class DokusenMarkets extends StatefulWidget {
  @override
  _DokusenMarketsState createState() => _DokusenMarketsState();
}

class _DokusenMarketsState extends State<DokusenMarkets> {
  StreamSubscription marketSubsc;
  //DocumentReference marketRef;
  List<M_Markets> markets;
  List<int> materials;
  int overSeaMaterials = 0;
  int cost = 0;
  CompanyBoard myBoard;
  int shop_room_materials;
  AuthService _auth = AuthService();
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();
  BlocBidBook _blocBidBook;


  @override
  void initState() {
    //localBoard = shareMyBoard;
    // TODO: implement initState
    marketSubsc = Firestore.instance
        .collection(rootCollectionName+ '/games/markets')
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
    materials = [0, 0, 0, 0, 0, 0];
    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
      setState(() {
        myBoard = value;
        shop_room_materials = myBoard.shop_room;
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

  int calcPower(){
    int result = 0;
    if(myBoard.salesman == 0) return result;
    for(int index = 0; index < myBoard.kokoku ; index++){
      if(myBoard.salesman * 2 < index){
        result +=2;
      }
    }

    return result;
  }

  void setBids(){
    Map<String,int> result = Map<String,int>();
    for(int index = 0 ; index < markets.length ; index++){
      if(materials[index] > 0){
        myBoard.cash += markets[index].maxPrice * materials[index];
        myBoard.shop_room -= materials[index];
        DatabaseService().commitCompanyBoard(myBoard);
        Firestore.instance.document(cashBookPath).updateData({
          'uriage': FieldValue.increment(markets[index].maxPrice * materials[index]),
          'sales': FieldValue.increment(materials[index]),
        });
      }
        result[markets[index].documentID] = materials[index];
    }

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
                              (markets[index].maxVolume -
                                  markets[index].currentMaterials)
                                  .toString() ??
                                  0,
                              style:
                              TextStyle(color: Colors.black, fontSize: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              markets[index].maxPrice.toString() ?? 0,
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
                            if (materials[index] != 0 && shop_room_materials < myBoard.shop_room) {
                              setState(() {
                                materials[index]--;
                                shop_room_materials++;
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
                            //手持ちの数 :   販売能力 :  販売可能数  1 2 3  3 2 1  3 2 3
                            //result 現在の販売可能数　
                            int result = (markets[index].maxVolume - markets[index].currentMaterials - materials[index]);
                            print('マーケット自体の最大入札可能数:'+result.toString());
                            // 入札可能数が販売可能数を超えていたら、販売可能数に制限
                            if(result > (calcPower() - materials.reduce((a,b) => a+b))) result = calcPower() - materials.reduce((a,b) => a+b);
                            //print('販売可能数に制限した場合:'+result.toString());
                            //入札可能な余地
                            //result -= materials.reduce((a,b) => a+b);
                            print('すでに入札した分を引く '+ result.toString());
                            if(result > 0){
                              if(result >= shop_room_materials){
                                setState(() {
                                  materials[index] += shop_room_materials;
                                  shop_room_materials = 0;
                                });
                              }else{
                                setState(() {
                                  shop_room_materials -= result;
                                  materials[index] += result;
                                });
                              }

                            }
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
                            //販売可能在庫が１以上　＆＆　入札数が 入札可能数以内 && 現在のマーケット入札数が、マーケットの空き数以内。
                            if(shop_room_materials > 0 && materials.reduce((a,b) => a+b) < calcPower() && materials[index] < (markets[index].maxVolume - markets[index].currentMaterials)){
                              setState(() {
                                shop_room_materials--;
                                materials[index]++;
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
                            '販売可能数',
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
                            '入札数',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        )),
                  ],
                ),
              ),
              for (int index = 0; index < markets.length; index++)
                getMarket(index),
              Expanded(
                flex: 1,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    //Text(
                    //  '入札可能数(' + shop_room_materials.toString() +') ',
                    //  style: TextStyle(color: Colors.black, fontSize: 20),
                    //),
                    Text(
                      '販売能力(' + calcPower().toString() +') ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Text(
                      '営業所在庫(' + myBoard.shop_room.toString() +') ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),

                  ],
                ),),
              Expanded(
                flex: 1,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 50.0,
                    ),
                    RaisedButton(
                      child: Text("Cancel"),
                      color: Colors.black12,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 100.0,
                    ),
                    RaisedButton(
                      child: Text("販売"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed:  () async {
                        //print('setBid : ' + setBids().toString());
                        await this.setBids();
                        //await _auth.createBidBook(this.setBids());
                        //await DatabaseService().commitCompanyBoard(myBoard);
                        //await DatabaseService().commitCashBook(globalPeriod);
                        _blocBidBook = Provider.of<BlocBidBook>(context);
                        _blocBidBook.updateBidBookPath(rootCollectionName+'/games/combat_data/combat_history/'+ globalSerialNo.toString());
                        _auth.changeCurrentOwner();
                        Navigator.popUntil(
                            context, ModalRoute.withName('/companyBoard'));


                      },
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
