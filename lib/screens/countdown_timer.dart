import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/bloc/bloc_bid_book.dart';
import 'package:smg07/screens/custom_painter.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';

class CountDownTimer extends StatefulWidget {
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  BlocBidBook blocB1idBook;
  AnimationController controller;
  String path = rootCollectionName +
      '/combat_data/combat_history/' +
      globalSerialNo.toString();

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 15),
    );
    controller.forward();
  }

  Widget joinTimeOver() {
    DatabaseService().notJoin();
    return Text('Done');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final books = Provider.of<BidBook>(context);
    blocB1idBook = Provider.of<BlocBidBook>(context);
    blocB1idBook.updateBidBookPath(path);
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white10,
      body: (controller.status == AnimationStatus.completed)
          ? joinTimeOver()
          : AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                if (controller.status == AnimationStatus.completed) {
                  DatabaseService().notJoin();
                }
                return Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: CustomPaint(
                                          painter: CustomTimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.red,
                                        color: themeData.indicatorColor,
                                      )),
                                    ),
                                    Align(
                                      alignment: FractionalOffset.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          BidMessage(),
                                          Text(
                                            "入札に参加しますか？",
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.white),
                                          ),
                                          RaisedButton(
                                            color: Colors.pink[400],
                                            child: Text(
                                              '入札参加',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () => {
                                              Navigator.of(context).pushNamed(
                                                  '/bidMarkets4Client')
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.blue[400],
                                            child: Text(
                                              '不参加',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              //
                                              DatabaseService().notJoin();

                                              //Navigator.of(context).pop();
                                            },
                                          ),
                                          Text(
                                            timerString,
                                            style: TextStyle(
                                                fontSize: 40.0,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
    );
  }
}

/*
class CountDownTimer extends StatefulWidget {
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController controller;
  String path = rootCollectionName +
      '/combat_data/combat_history/' +
      globalSerialNo.toString();

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 15),
    );
    controller.forward();
  }

  Widget joinTimeOver() {
    DatabaseService().notJoin();
    return Text('Done');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final books = Provider.of<BidBook>(context);

    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white10,
      body: (controller.status == AnimationStatus.completed)
          ? joinTimeOver()
          : AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                if (controller.status == AnimationStatus.completed) {
                  DatabaseService().notJoin();
                }
                return Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: CustomPaint(
                                          painter: CustomTimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.red,
                                        color: themeData.indicatorColor,
                                      )),
                                    ),
                                    Align(
                                      alignment: FractionalOffset.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          StreamBuilder(
                                            stream: Firestore.instance
                                                .document(rootCollectionName +
                                                    '/combat_data/combat_history/' +
                                                    globalSerialNo.toString())
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              print('STREAM ' +
                                                  rootCollectionName +
                                                  globalSerialNo.toString());
                                              if (snapshot.connectionState !=
                                                  ConnectionState.done)
                                                return Text('Loadin...');
                                              if (!snapshot.hasData ||
                                                  snapshot.data['owner'] ==
                                                      null)
                                                return Text('Loading..');
                                              String result =
                                                  snapshot.data['ower'] +
                                                      'が入札開始しました。';
                                              return Text(
                                                result,
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              );
                                            },
                                          ),
                                          /*
                                          Text(
                                            "Aさんが入札を開始しました。\n 札幌(2) \n 仙台 (1) ",
                                            style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.white),
                                          ),*/

                                          Text(
                                            "入札に参加しますか？",
                                            style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.white),
                                          ),
                                          RaisedButton(
                                            color: Colors.pink[400],
                                            child: Text(
                                              '入札参加',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () => {
                                              Navigator.of(context).pushNamed(
                                                  '/bidMarkets4Client')
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.blue[400],
                                            child: Text(
                                              '不参加',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              //
                                              DatabaseService().notJoin();

                                              //Navigator.of(context).pop();
                                            },
                                          ),
                                          Text(
                                            timerString,
                                            style: TextStyle(
                                                fontSize: 40.0,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
    );
  }
}

 */
