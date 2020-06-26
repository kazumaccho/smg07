import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_Jinji extends StatefulWidget {
  @override
  _S_JinjiState createState() => _S_JinjiState();
}

class _S_JinjiState extends State<S_Jinji> {
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
            List.generate(myBoard.machines.length, (index) => false);
          }),
        });
    super.initState();
  }

  int worker = 0;
  int salesman = 0;

  int calcRate() {
    return worker.abs() * 5;
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Scaffold(
            body: Column(
              children: <Widget>[
                Text('人事異動'),
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'ワーカー(' + myBoard.worker.toString() + ')',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            MaterialButton(
                              height: 15.0,
                              color: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                '<--- ',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                if (myBoard.salesman > 0) {
                                  setState(() {
                                    myBoard.salesman--;
                                    worker++;
                                    salesman--;
                                    myBoard.worker++;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                          ],
                        )
                      ],
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '',
                          style: TextStyle(color: Colors.red, fontSize: 30),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'セールスマン(' + myBoard.salesman.toString() + ')',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    MaterialButton(
                      height: 15.0,
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '<---- ',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        if (myBoard.worker > 0) {
                          setState(() {
                            myBoard.worker--;
                            myBoard.salesman++;
                            worker--;
                            salesman++;
                          });
                        }
                      },
                    ),
                  ],
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
                      ' COST : ' + calcRate().toString(),
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
                      child: Text("異動"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        myBoard.cash += -calcRate();
                        Firestore.instance.document(cashBookPath).updateData({
                          'keihi': FieldValue.increment(calcRate()),
                        });
                        //cashBook.depts.add(money);
                        //cashBook.keihi += calcRate();
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
