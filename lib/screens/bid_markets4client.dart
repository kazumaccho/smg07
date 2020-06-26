import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/markets.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';



class S_BidMarkets4Client extends StatefulWidget {
  @override
  _S_BidMarkets4ClientState createState() => _S_BidMarkets4ClientState();
}

class _S_BidMarkets4ClientState extends State<S_BidMarkets4Client> {

  List<M_Markets> markets;
  List<int> materials;
  CompanyBoard myBoard;
  int shop_room_materials;
  AuthService _auth = AuthService();
  //bool loading = false;
  BidBook book;
  List<String> marketName = [] ;
  List<int> maxPrice = [];

  List<String> bidMarkets(){
    List<String> result = List<String>();
    for(int index = 0 ; index < book.markets.length ; index++){
      if(materials[index] > 0)
        result.add(book.markets[index]);
    }
    return result;
  }

  @override
  void initState() {
/*
    DatabaseService().getBidBook().then((value) => {
      book = value,
      materials = List.generate( book.volumes.length, (index) => 0 ),
    }).catchError((err) => print(err.toString()));
    */

    String path = rootCollectionName + '/combat_data/combat_history/' + globalSerialNo.toString() ;
    Firestore.instance.document(path).snapshots().listen((event) {
      setState( () {
        book = BidBook.fromFirestore( event );
        materials = List.generate( book.volumes.length, (index) => 0 );
        materials = List.generate( book.volumes.length, (index) => 0 );
      } );
    });


    DatabaseService().getCompanyBoard(localuser.uid).then((value) => {
    setState(() {
      myBoard = value;
      shop_room_materials = myBoard.shop_room;
    }),

    }).catchError((err) => print(err.toString()));
    super.initState();
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

  Widget getMarket(int index) {
    marketName.add(null);
    maxPrice.add(0);
    materials.add(0);
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
                          child: marketName[index] != null ? Text(marketName[index],style:
                          TextStyle(color: Colors.black, fontSize: 30),) : FutureBuilder(
                            future: Firestore.instance.document(rootCollectionName+'/games/markets/'+ book.markets[index]).get(),
                            builder: (context,snapshot){
                              if(snapshot.connectionState != ConnectionState.done)  return Text('Loading...');

                              if(snapshot.hasData){

                                marketName[index] = snapshot.data['name'];

                                return Text(marketName[index],
                                  style:
                                  TextStyle(color: Colors.black, fontSize: 30),
                                );
                              }else{
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
                            child:  maxPrice[index] != 0 ? Text(maxPrice[index].toString(),style:
                            TextStyle(color: Colors.black, fontSize: 30)) : FutureBuilder(
                              future: Firestore.instance.document(rootCollectionName+'/games/markets/'+ book.markets[index]).get(),
                              builder: (context,snapshot){
                                if(snapshot.connectionState != ConnectionState.done)  return Text('Loading...');
                                if(snapshot.hasData){
                                  maxPrice[index] = snapshot.data['maxPrice'];
                                  return Text(maxPrice[index].toString(),
                                    style:
                                    TextStyle(color: Colors.black, fontSize: 30),
                                  );
                                }else{
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
                            if (materials[index] > 0 ) {
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
                            int result = book.volumes[index]; //
                            // (markets[index].maxVolume - markets[index].currentMaterials);

                            // 既に入札した分を能力から引く
                            if(result > (calcPower() - materials.reduce((a,b) => a+b))){
                              result = calcPower() - materials.reduce((a,b) => a+b);
                            }else{
                              result -= materials[index];
                            }
                            //入札可能な余地
                            //result -= materials.reduce((a,b) => a+b);

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
                            if(shop_room_materials > 0 && materials.reduce((a,b) => a+b) < calcPower() && materials[index] < book.volumes[index]){
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
    //print('MYBOARD = '+ myBoard.toMap().toString());
    return book == null || myBoard == null
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
                            '親入札数',
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
                      '入札可能数(' + shop_room_materials.toString() +') ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
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
                      onPressed: () async {

                        //setState(() => loading = true);

                        dynamic result = await _auth.bidMarkets4Client(
                            book.markets, materials);
                        //await DatabaseService().commitCompanyBoard(shareMyBoard);
                        //await DatabaseService().commitCashBook(shareMyBoard.priod);
                        if (result == null) {
                          //setState(() => loading = false);
                        } else {
                          Navigator.of(context).pushNamed('/S_BidPrice4Client');
                        }
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

