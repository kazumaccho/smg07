import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/constants.dart';
import 'package:smg07/shared/global.dart';
import 'package:smg07/shared/loading.dart';

class S_MainMenu extends StatefulWidget {
  @override
  _S_MainMenuState createState() => _S_MainMenuState();
}

class _S_MainMenuState extends State<S_MainMenu> {
  final _formkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String nickName = '';
  String companyName = '';
  //_auth.assignUser();
  List<dynamic> eventList;

  @override
  void initState() {
/*
    // TODO: implement initState
    Firestore.instance.document('events/activelist').get().then((doc) => {
          setState(() async => {
                eventList = await doc.data['list'],
                print(eventList.toString()),
              })
        });
  */
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget createButton(int index) {
    return RaisedButton(
      color: Colors.blue[400],
      child: Text(
        eventList[index],
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        rootCollectionName = eventList[index];

        await _auth.assignUser(nickName, companyName);
        globalPeriod = 0;
        globalCompanyName = companyName;
        await DatabaseService().commitCompanyBoard(CompanyBoard.first(
          globalPeriod,
          companyName,
          nickName,
        ));

        //myBoard = _auth.createCompanyBorad();
        await _auth.firstJoin();
        await DatabaseService().createMarket();
        //cashBook = CashBook();
        Navigator.of(context)
            .pushNamed('/Shoki'); //, arguments: eventList[index]
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //CompanyBoard myBoard = Provider.of<CompanyBoard>(context);
    return FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance.document('events/activelist').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            eventList = snapshot.data['list'];

            return Scaffold(
              appBar: AppBar(
                title: Text('メインメニュー'),
                actions: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Icon(Icons.assignment_ind),
                      onPressed: () async {
                        await _auth.signOut();
                        //Navigator.of(context).pushNamed('/bank');
                      },
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.brown[100],
              body: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'メインメニュ',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'nick name'),
                          initialValue: nickName,
                          validator: (val) =>
                              val.isEmpty ? 'Enter an Email' : null,
                          onChanged: (val) {
                            nickName = val;
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'companyName'),
                          initialValue: companyName,
                          validator: (val) =>
                              val.isEmpty ? 'Enter an Email' : null,
                          onChanged: (val) {
                            companyName = val;
                          }),
                      SizedBox(height: 20.0),
                      for (int index = 0; index < eventList.length; index++)
                        createButton(index),
                      SizedBox(height: 20.0),
                    ],
                  )),
            );
          } else {
            return Loading();
          }
        });
  }
}
