import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_Bank extends StatefulWidget {
  @override
  _S_BankState createState() => _S_BankState();
}

class _S_BankState extends State<S_Bank> {
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

  int money = 0;
  int calcRate() {
    return (money * 0.1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return myBoard == null
        ? Loading()
        : Scaffold(
            body: Column(
              children: <Widget>[
                Text('銀行借入れ'),
                Text('与信枠 400, 現在の借入額200'),
                Text('借り入れ可能金額 : 200'),
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              '借入金額(' + money.toString() + ')',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            MaterialButton(
                              height: 15.0,
                              color: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                '- (100)',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                if (money >= 100) {
                                  setState(() {
                                    money -= 100;
                                  });
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
                                '+ (100)',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  money += 100;
                                });
                              },
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'CASH : ' + myBoard.cash.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Text(
                      ' 金利 : ' + calcRate().toString(),
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
                        myBoard.cash += money - calcRate();
                        Firestore.instance.document(cashBookPath).updateData({
                          'depts': FieldValue.arrayUnion([money]),
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
