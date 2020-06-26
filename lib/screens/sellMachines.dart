import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_SellMachines extends StatefulWidget {
  @override
  _S_SellMachinesState createState() => _S_SellMachinesState();
}

class _S_SellMachinesState extends State<S_SellMachines> {
  CompanyBoard myBoard;
  List<Widget> result = [];
  List<bool> checkList;
  StreamSubscription myBoardSubsc;
  String cashBookPath = rootCollectionName +
      '/games/users/' +
      localuser.uid +
      '/cashbook/' +
      globalPeriod.toString();

  @override
  void initState() {
    myBoardSubsc = Firestore.instance
        .document(rootCollectionName + '/games/users/' + localuser.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          myBoard = CompanyBoard.fromFirestore(snapshot);
          checkList = List.generate(myBoard.machines.length, (index) => false);
          print('CHECKLIST :' + checkList.length.toString());
        });
      }
    });
    super.initState();
  }

  List<Widget> makeMachineData() {
    List<Widget> result = [];

    for (int index = 0; index < myBoard.machines.length; index++) {
      result.add(createMachineData(myBoard.machines[index], index));
    }

    return result;
  }

  void makeNewMachineList() {
    for (int index = checkList.length - 1; index >= 0; index--) {
      if (checkList[index]) {
        Firestore.instance.document(cashBookPath).updateData({
          'sold_machine': FieldValue.arrayUnion([myBoard.machines[index]]),
        });
        //cashBook.sold_machine.add(myBoard.machines[index]);
        myBoard.machines.removeAt(index);
      }
    }
  }

  int calcSold() {
    int result = 0;
    for (int index = 0; index < checkList.length; index++) {
      if (checkList[index]) {
        if (myBoard.machines[index].containsKey('big')) {
          result += 100;
          continue;
        }
        if (myBoard.machines[index].containsKey('attach')) {
          result += 60;
          continue;
        }
        if (myBoard.machines[index].containsKey('small')) {
          result += 50;
          continue;
        }
      }
    }
    return result;
  }

  Widget createMachineData(Map data, int index) {
    if (data.containsKey('big')) {
      return Column(
        children: <Widget>[
          Text('大型機械'),
          Text('簿　　価 : ' + data['big'].toString()),
          Text('売却価格 : 50'),
          Checkbox(
            value: checkList[index],
            onChanged: (bool value) {
              setState(() {
                checkList[index] = !checkList[index];
              });
            },
          ),
          //CheckboxListTile(),
        ],
      );
    }

    if (data.containsKey('attach')) {
      return Column(
        children: <Widget>[
          Text('アタッチ付き小型機械'),
          Text('簿　　価 : ' + (data['attach'] + data['small']).toString()),
          Text('売却価格 : 60'),
          Checkbox(
            value: checkList[index],
            onChanged: (bool value) {
              setState(() {
                checkList[index] = !checkList[index];
              });
            },
          ),

          //CheckboxListTile(),
        ],
      );
    }

    if (data.containsKey('small')) {
      return Column(
        children: <Widget>[
          Text('小型機械'),
          Text('簿　　価 : ' + data['small'].toString()),
          Text('売却価格 : 50'),
          Checkbox(
            value: checkList[index],
            onChanged: (bool value) {
              setState(() {
                checkList[index] = !checkList[index];
              });
            },
          ),
        ],
      );
    }

    ;
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
        ? Loading()
        : Scaffold(
            body: Column(
              children: <Widget>[
                Text('売却対象の機械を選択してください。'),
                Wrap(
                  children: makeMachineData(),
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'CASH : ' + myBoard.cash.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Text(
                      ' 売値 : ' + calcSold().toString(),
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ],
                ),
                Row(
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
                      onPressed: () {
                        myBoard.cash += calcSold();
                        makeNewMachineList();

                        DatabaseService().commitCompanyBoard(myBoard);
                        Navigator.popUntil(
                            context, ModalRoute.withName('/companyBoard'));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
