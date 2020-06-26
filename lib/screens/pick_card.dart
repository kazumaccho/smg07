import 'package:flutter/material.dart';
import 'package:smg07/screens/RiskCards/riskcards.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/shared/global.dart';

class S_PickCard extends StatefulWidget {
  @override
  _S_PickCardState createState() => _S_PickCardState();
}

class _S_PickCardState extends State<S_PickCard> {
  MGCard mgcard = MGCard();
  int status = 0; // 1 disicion
  //CardType card = Omote();
  AuthService _auth = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    mgcard.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(globalCompanyName + ' 第' + globalPeriod.toString() + '期'),
        ),
        body: Column(
          children: <Widget>[
            getPickCardMain(),
            if (status != 0)
              RaisedButton(
                  color: Colors.greenAccent[400],
                  child: Text(
                    'DO NOTHING',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    //await DatabaseService().commitCompanyBoard(myB);
                    _auth.changeCurrentOwner();
                    Navigator.popUntil(
                        context, ModalRoute.withName("/companyBoard"));
                  }),
          ],
        ),
      ),
    );
  }

  Widget getPickCardMain() {
    return status != 0
        ? mgcard.pickCardWidget()
        : Container(
            child: Column(
              children: <Widget>[
                Text(
                  'カードを引く画面',
                  style: TextStyle(fontSize: 18.0),
                ),
                FlatButton(
                  child: Image.asset('images/omote.png'),
                  onPressed: () {
                    setState(() {
                      status = 1;
                      //card = mgcard.pickCard();
                    });
                  },
                ),
              ],
            ),
          );
  }
}

/*

  Widget switcStatus() {
    if (status == 1) {
      return S_MenuA();
    }
    return getPickCardMain();
  }
  Widget viewCard() {
    //card.calc();
    return Column(
      children: <Widget>[
        Expanded(flex: 2, child: card.image),
        Text(card.title),
        for (int index = 0; index < card.messeages.length; index++)
          Text(card.messeages[index]),
        Expanded(flex: 5, child: Column(children: card.flatbuttons())),
        RaisedButton(
          color: Colors.greenAccent[400],
          child: Text(
            'DO NOTHING',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            //await DatabaseService().commitCompanyBoard(myB);
            _auth.changeCurrentOwner();
            Navigator.popUntil(context, ModalRoute.withName("/companyBoard"));
          },
        ),
      ],
    );
  }

 */
