import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/screens/RiskCards/riskcards.dart';
import 'package:smg07/screens/bank.dart';
import 'package:smg07/screens/bid_markets.dart';
import 'package:smg07/screens/bid_markets4client.dart';
import 'package:smg07/screens/bid_price.dart';
import 'package:smg07/screens/bid_result.dart';
import 'package:smg07/screens/company_board.dart';
import 'package:smg07/screens/countdown_timer.dart';
import 'package:smg07/screens/jinji.dart';
import 'package:smg07/screens/menu_a.dart';
import 'package:smg07/screens/pick_card.dart';
import 'package:smg07/screens/plbs.dart';
import 'package:smg07/screens/sellMachines.dart';
import 'package:smg07/screens/shoki.dart';
import 'package:smg07/screens/wrapper.dart';
import 'package:smg07/services/auth.dart';
import 'package:smg07/services/database.dart';
import 'package:smg07/shared/global.dart';

import 'models/bloc/bloc_bid_book.dart';
import 'models/bloc/bloc_markets.dart';
import 'models/company_board.dart';
import 'models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    db = DatabaseService();
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(value: AuthService().user),
        StreamProvider<CompanyBoard>.value(
            value: DatabaseService().streamMyCompanyBoard('')),
        ChangeNotifierProvider<BlocBidBook>.value(value: BlocBidBook(path: '')),
        ChangeNotifierProvider<BlocMarkets>.value(value: BlocMarkets(path: '')),

        //StreamProvider<M_Markets>.value(value: Collection().streamMarkets()),
        //StreamProvider<BidBook>.value(value: DatabaseService().bidBook),
        //StreamProvider<List<BidUser>>.value(value: Collection().streamData()),

        /*
        StreamProvider<BidBook>.value(value: DatabaseService().bidBook),
        //StreamProvider<List<int>>.value(value: DatabaseService().joins2),
        StreamProvider<DocumentSnapshot>.value(value: DatabaseService().updateCurrentOwner),
        StreamProvider<BidResult>.value(value: DatabaseService().bidResultStream),
         */
      ],
      child: MaterialApp(initialRoute: '/', routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => Wrapper(),
        '/companyBoard': (BuildContext context) => S_CompanyBoards(),
        '/pickCard': (BuildContext context) => S_PickCard(),
        '/menuA': (BuildContext context) => S_MenuA(),
        //'/bidMarkets': (BuildContext context) => S_BidMarkets(),
        '/bidPrice': (BuildContext context) => S_BidPrice2(),
        '/bidMarketsbidMarkets': (BuildContext context) => S_BidMarkets2(),
        '/bidResult': (BuildContext context) => S_BidResult(),
        '/timer': (BuildContext context) => CountDownTimer(),
        '/bidMarkets4Client': (BuildContext context) => S_BidMarkets4Client(),
        '/S_BidPrice4Client': (BuildContext context) => S_BidPrice4Client(),
        //'/bidPrice4Client': (BuildContext context) => S_BidPrice4Client(),
        '/SellMachine': (BuildContext context) => S_SellMachines(),
        '/bank': (BuildContext context) => S_Bank(),
        '/dokusenSalesman': (BuildContext context) => DokusenSalesMan(),
        '/Jinji': (BuildContext context) => S_Jinji(),

        '/Shoki': (BuildContext context) => Shoki(),
        '/plbs': (BuildContext context) => V_PLBS(),
      }),
    );
  }
}
