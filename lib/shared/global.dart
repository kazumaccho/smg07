import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/bid_users.dart';
import 'package:smg07/services/database.dart';

final Firestore firestore = Firestore.instance;
String rootCollectionName = '';
DatabaseService db;

FirebaseUser localuser;
bool isBid = false;
int globalSerialNo = 0;
int globalJoins = 0;
String globalCheckMarket = '';
//CompanyBoard shareMyBoard;
//CashBook cashBook;
//M_PLBS previousPLBS;
int globalPeriod;
String globalCompanyName;
String myBoardPath = rootCollectionName + '/games/users/' + localuser.uid;

class Global {
  // Data Models

  static final Map models = {
    BidUser: (data) => BidUser.formFireStore(data),
    BidBook: (data) => BidBook.fromFirestore(data),
  };
}
