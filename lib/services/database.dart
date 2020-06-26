import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smg07/models/bid_book.dart';
import 'package:smg07/models/cashbook.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/models/markets.dart';
import 'package:smg07/models/pbbs.dart';
import 'package:smg07/shared/global.dart';

class DatabaseService {
  DatabaseService();

  Future createBidderBook(String userid, Map<String, int> markets) async {
    await this.incrementSerialNo();
    print(' call ###### createBidderBook');
    globalSerialNo = await this.getSerialNo();
    globalJoins = await this.getJoinUsers();
    Map<String, bool> joins = Map<String, bool>();
    joins[userid] = true;
    CollectionReference colRef = firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets');
    DocumentReference docRef = firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString());
    await docRef.setData({
      'markets': markets.keys.toList(),
      'volumes': markets.values.toList(),
      'joins': joins,
      'owner': userid,
      'isOn': true,
      'status': 1
    });

    int index = 0;
    markets.keys.toList().forEach((aMarket) => {
          colRef
              .document(aMarket)
              .collection('bidders')
              .document(userid)
              .setData({'volume': markets.values.toList()[index]}),
          index++
        });

    return await markets.forEach((String key, int value) {
      colRef.document(key).setData({'volume': value});
      colRef
          .document(key + '/bidders/' + userid)
          .setData({'volume': value, 'isParent': true});
    });
  }

  bool setIsOff() {
    DocumentReference docRef = firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString());
    docRef.updateData({'isOn': false});

    return true;
  }

  Future<bool> getIsOn() async {
    bool result;

    await firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) => {
              result = doc.data['isOn'],
            });
    print('///////////////' + result.toString());
    return result;
  }

  Future bidPrice(String userid, List<dynamic> markets, List<int> prices,
      int rd, String companyName, mr, maxPrice) async {
    //ref 入札マーケットの参照
    CollectionReference ref = firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets');
    Map<dynamic, dynamic> joins;
    int index = 0;

    //joins 参加者の入札状況の更新
    firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) => {
              joins = doc.data['joins'] == null
                  ? Map<dynamic, dynamic>()
                  : doc.data['joins'],
              //joins.add(userid),
              joins[userid] = true,
              doc.reference.updateData({'joins': joins})
            });

    markets.forEach((aMarket) => {
          ref
              .document(aMarket)
              .collection('bidders')
              .document(userid)
              .updateData({
            'price': prices[index],
            'rd': rd,
            'companyName': companyName,
            'power': prices[index] - rd * 2,
            'mr': mr,
            'maxPrice': maxPrice[index],
          }),
          index++
        });
  }

  Future bidMarkets4Client(
      String userid, List<dynamic> markets, List<int> volumes) async {
    CollectionReference ref = firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets');
    Map<dynamic, dynamic> joins;
    int index = 0;

    markets.forEach((aMarket) => {
          ref
              .document(aMarket)
              .collection('bidders')
              .document(userid)
              .setData({'volume': volumes[index]}),
          index++
        });

    return firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) => {
              joins = doc.data['joins'] == null
                  ? Map<dynamic, dynamic>()
                  : doc.data['joins'],
              //joins.add(userid),
              joins[userid] = true,
              doc.reference.updateData({'joins': joins})
            });
  }

  Future notJoin() async {
    Map<dynamic, dynamic> joins;
    return firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) => {
              joins = doc.data['joins'] == null
                  ? Map<dynamic, dynamic>()
                  : doc.data['joins'],
              joins[localuser.uid] = false,
              doc.reference.updateData({'joins': joins})
            });
  }

// event20200419
  /*
  Stream<BidBook> get bidBook {
    return firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .snapshots(includeMetadataChanges: true)
        .map(_bidBookFromSnapshot);
  }
  */
  Stream<BidBook> get bidBook {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();
    //String path = '{eventId}/combat_data/combat_history/{serialNo}';

    return Firestore()
        .document(path)
        .snapshots(includeMetadataChanges: true)
        .map((aDoc) => BidBook.fromFirestore(aDoc));
  }

/*
  Stream<List<int>> get joins2 {
    return firestore.collection(rootCollectionName)
            .document('combat_data')
            .collection('combat_history')
            .document(globalSerialNo.toString())
            .snapshots(includeMetadataChanges: true).map(_answerUsers);
  }

  List<int> _answerUsers(DocumentSnapshot snapshot) {
    List<int> result = List<int>();
    int index = 0;
    result.add(snapshot.data['joins'].length);
    snapshot.data['joins'].values.forEach((value) =>{
      if(value) index++,
    });
    result.add(index);

    return result;
  }
*/
  Stream<DocumentSnapshot> get updateCurrentOwner {
    return firestore
        .collection(rootCollectionName)
        .document('games')
        .snapshots(includeMetadataChanges: true);
  }

  /*
  Stream<BidResult> get bidResultStream {
    StreamController controller = StreamController<BidResult>();
    BidResult result;
    int allusers = 0;
    int acceptUsers = 0;
    int joinUsers = 0;
    int bidUsers = 0;
    bool isOn = true;
    print('----------############# bidResultStream');
    getJoinUsers().then((onValue) => allusers = onValue);
    print('----------############# STEP1');
    if (rootCollectionName == null) {
      return null;
    }

    firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .snapshots(includeMetadataChanges: true)
        .map(_bidBookFromSnapshot)
        .listen((onData) => {
              acceptUsers = onData.joins.length,
              onData.joins.values.forEach((isTrue) async => {
                    // ignore: sdk_version_set_literal
                    if (isTrue)
                      await joinUsers++,
                  })
            });
    print('----------############# STEP2');
    if (globalSerialNo == null) return null;
    firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets')
        .document('sapporo')
        .collection('bidders')
        .where('price', isGreaterThanOrEqualTo: 0)
        .snapshots()
        .listen((onData) async => {
              bidUsers = await onData.documents.length,
            });
    print('----------############# STEP3');
    this.getIsOn().then((onValue) async => {
          isOn = await onValue,
        });

    print('allusers    : ' + allusers.toString());
    print('acceptUsers : ' + acceptUsers.toString());
    print('joinUsers   : ' + joinUsers.toString());
    print('bidUsers    : ' + bidUsers.toString());

    if (allusers > 0 && acceptUsers > 0 && joinUsers > 0 && bidUsers > 0) {
      result = BidResult(allusers, acceptUsers, joinUsers, bidUsers, isOn);
      controller.sink.add(result);
      return controller.stream;
    } else {
      return null;
    }
  }
  */

  BidBook _bidBookFromSnapshot(QuerySnapshot snapshot) {
    //print('&&&&&&&&&&&&&&&&');
    this.getSerialNo();
    DocumentSnapshot doc = snapshot.documents.singleWhere(
        (doctest) => doctest.documentID == globalSerialNo.toString(),
        orElse: () => null);

//    print('&&&&&&& docment ID = '+doc.documentID);
    //return null;

    return BidBook(
      owner: doc.data['owner'],
      markets: doc.data['markets'],
      volumes: doc.data['volumes'],
      joins: doc.data['joins'],
      isOn: doc.data['isOn'],
    );
  }

  /*
  void assignUser(String userid, String nickName, String companyName) async {
    DocumentReference ref = firestore
        .collection(rootCollectionName)
        .document('games')
        .collection('users')
        .document(userid);
    ref.setData(
        {'nickName': nickName, 'companyName': companyName, 'cash': 500});
  }

   */

  Future incrementSerialNo() async {
    await firestore
        .collection(rootCollectionName)
        .document('games')
        .get()
        .then((doc) => {
              firestore
                  .collection(rootCollectionName)
                  .document('games')
                  .updateData({'serialNo': doc.data['serialNo'] + 1}),
            });
  }

  Future setCurrentOwner() async {
    await firestore
        .collection(rootCollectionName)
        .document('games')
        .updateData({'currentOwner': localuser.uid});
  }

  Future<int> getSerialNo() async {
    int result = 0;
    await firestore
        .collection(rootCollectionName)
        .document('games')
        .get()
        .then((doc) => {
              result = doc.data['serialNo'],
            });
    globalSerialNo = result;
    return result;
  }

  Future<int> getJoinUsers() async {
    int result = 0;
    print('000000000000000000000000000000000000');
    await Firestore.instance
        .collection(rootCollectionName)
        .document('combat_data')
        .get()
        .then((doc) => {
              //print('#### check1:' + doc.data['joins'].toString()),
              result = doc.data['joins'],
            });
    return result;
  }

  Future<String> getMarketName() async {
    String result = '';

    await firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) => {
              // print('name get ' + doc.data['markets'][0]),
              result = doc.data['markets'][0],
            });
    return result;
  }

  void calcResult() async {
    //ユーザーデータの取り出し
    //bidBookの取り出し
    //
    firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets');

    List<dynamic> markets;
    List<dynamic> volumes;
    await firestore
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .get()
        .then((doc) =>
            {markets = doc.data['markets'], volumes = doc.data['volumes']});

    print(markets);
    for (int index = 0; index < markets.length; index++) {
//      print('for loop : ' + markets[index] + 'globalserialno : ' + globalSerialNo.toString() );
      QuerySnapshot qs = await firestore
          .collection(rootCollectionName)
          .document('combat_data')
          .collection('combat_history')
          .document(globalSerialNo.toString())
          .collection('markets')
          .document(markets[index])
          .collection('bidders')
          .orderBy('price', descending: false)
          .getDocuments();

      qs.documents.forEach((DocumentSnapshot aUser) => {
//        print(" forEach start ###### volumes[index] >= aUser.data['volume']"+ volumes[index].toString() +' : '+ aUser.data['volume'].toString()),
            if (volumes[index] >= aUser.data['volume'])
              {
                volumes[index] -= aUser.data['volume'],
//          print("volumes[index] : " + volumes[index].toString()),
                firestore
                    .collection(rootCollectionName)
                    .document('combat_data')
                    .collection('combat_history')
                    .document(globalSerialNo.toString())
                    .collection('markets')
                    .document(markets[index])
                    .collection('bidders')
                    .document(aUser.documentID)
                    .updateData({'sold': aUser.data['volume']}),
//          print('check ### 1###'),
              }
            else
              {
//          print('amari : ' + (volumes[index] %  aUser.data['volume']).toString()),
                firestore
                    .collection(rootCollectionName)
                    .document('combat_data')
                    .collection('combat_history')
                    .document(globalSerialNo.toString())
                    .collection('markets')
                    .document(markets[index])
                    .collection('bidders')
                    .document(aUser.documentID)
                    .updateData(
                        {'sold': (volumes[index] % aUser.data['volume'])}),
                //         print('check ### 2 ###'),
                volumes[index] =
                    volumes[index] - (volumes[index] % aUser.data['volume']),

//          print("else volumes[index] : " + volumes[index].toString()),
              },
//        print('for Each end'),
          });
    }

    QuerySnapshot qs;
    List<DocumentSnapshot> docSnap;
    markets.forEach((aMarket) async => {
          qs = await firestore
              .collection(rootCollectionName)
              .document('combat_data')
              .collection('combat_history')
              .document(globalSerialNo.toString())
              .collection('markets')
              .document(aMarket)
              .collection('bidders')
              .orderBy('dd', descending: true)
              .getDocuments(),
          docSnap = qs.documents,
          docSnap.forEach((DocumentSnapshot doc) => {
                //doc.documentID doc.data['price']
              })
        });
  }

  Future<int> joinsData() async {
    // print('bidUsers method called : '+ globalSerialNo.toString());
    // print(globalSerialNo.toString() +'................');
    //await firestore.collection(rootCollectionName).document('combat_data').collection('combat_history').document(globalSerialNo.toString())
    String market = await getMarketName();
    //print('market name : '+market);

    //int index = 0;
    /*
    QuerySnapshot qs = await firestore.collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets')
        .document(market).collection('bidders').getDocuments();
*/
    int index = 0;
    List<int> indexList = List<int>();
    await Firestore.instance
        .collection(rootCollectionName)
        .document('combat_data')
        .collection('combat_history')
        .document(globalSerialNo.toString())
        .collection('markets')
        .document(market)
        .collection('bidders')
        .where('price', isGreaterThanOrEqualTo: 0)
        .snapshots()
        .listen((data) => {
              //data.documents.forEach((doc) => print(doc.documentID)),
              data.documents.forEach((doc) => indexList.add(1)),
            });
    index = indexList.length;
    print('index : ' + index.toString());

    return index;
  }

  void createMarket() {
    //Firestore.instance.collectionGroup(path).;
    //CollectionReference cr =
    //    Firestore.instance.collection(rootCollectionName + '/games/markets');

    //if (cr != null) return null;

    List<M_Markets> markets = [];

    markets.add(M_Markets(
        documentID: 'sapporo',
        name: '札幌',
        currentMaterials: 3,
        price: 10,
        maxPrice: 40,
        maxVolume: 3));

    markets.add(M_Markets(
        documentID: 'sendai',
        name: '仙台',
        currentMaterials: 4,
        price: 11,
        maxPrice: 36,
        maxVolume: 4));
    markets.add(M_Markets(
        documentID: 'tokyo',
        name: '東京',
        currentMaterials: 6,
        price: 12,
        maxPrice: 32,
        maxVolume: 6));
    markets.add(M_Markets(
        documentID: 'nagoya',
        name: '名古屋',
        currentMaterials: 9,
        price: 13,
        maxPrice: 28,
        maxVolume: 9));
    markets.add(M_Markets(
        documentID: 'osaka',
        name: '大阪',
        currentMaterials: 13,
        price: 14,
        maxPrice: 24,
        maxVolume: 13));
    markets.add(M_Markets(
        documentID: 'fukuoka',
        name: '福岡',
        currentMaterials: 20,
        price: 15,
        maxPrice: 20,
        maxVolume: 20));

    commitMarket(markets);
  }

  void commitMarket(List<M_Markets> markets) {
    WriteBatch batch = Firestore.instance.batch();

    markets.forEach((aMarket) {
      String path = rootCollectionName + '/games/markets/' + aMarket.documentID;
      batch.setData(Firestore.instance.document(path), aMarket.toMap());
    });

    batch
        .commit()
        .then((value) => print('commitMarket success'))
        .catchError((err) => print(err));
  }

  Future<void> commitKessan(M_PLBS kessan) async {
    WriteBatch batch = Firestore.instance.batch();

    String path = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/plbs/' +
        kessan.period.toString();
    batch.setData(Firestore.instance.document(path), kessan.toMap());

    await batch
        .commit()
        .then((value) => print('commitKessan success'))
        .catchError((err) => print(err));
  }

  Future<void> commitCashBook(int period, CashBook cashBook) async {
    WriteBatch batch = Firestore.instance.batch();

    String path = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/cashbook/' +
        period.toString();
    batch.setData(Firestore.instance.document(path), cashBook.toMap());

    await batch
        .commit()
        .then((value) => print('commitCashBook success'))
        .catchError((err) => print(err));
  }

  Future<void> commitCompanyBoard(CompanyBoard myBoard) async {
    WriteBatch batch = Firestore.instance.batch();
    String path = rootCollectionName + '/games/users/' + localuser.uid;
    batch.setData(Firestore.instance.document(path), myBoard.toMap());

    await batch
        .commit()
        .then((value) => print('commitCompanyBoard success'))
        .catchError((err) => print(err));
  }

  Future<M_PLBS> getPLBS(int targetPeriod) async {
    String path = rootCollectionName +
        '/games/users/' +
        localuser.uid +
        '/plbs/' +
        targetPeriod.toString();

    final Stream<M_PLBS> stream = Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => M_PLBS.fromFirestore(doc));

    await for (var data in stream) {
      return data;
    }
  }

  Future<BidBook> getBidBook() async {
    String path = rootCollectionName +
        '/combat_data/combat_history/' +
        globalSerialNo.toString();

    final Stream<BidBook> stream = Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => BidBook.fromFirestore(doc));

    await for (var data in stream) {
      return data;
    }
  }

  Future<CashBook> getCashBook(String documentID, int localPeriod) async {
    String path = rootCollectionName +
        '/games/users/' +
        documentID +
        '/cashbook/' +
        localPeriod.toString();

    final Stream<CashBook> stream = Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => CashBook.fromFirestore(doc));

    await for (var data in stream) {
      return data;
    }
  }

  Future<CompanyBoard> getCompanyBoard(String documentID) async {
    String path = rootCollectionName + '/games/users/' + documentID;

    final Stream<CompanyBoard> stream = Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => CompanyBoard.fromFirestore(doc));

    await for (var data in stream) {
      return data;
    }
  }

  Stream<CompanyBoard> streamMyCompanyBoard(path) {
    print('CALL STREAM ## METHOD ####');
    if (rootCollectionName.length == 0 || localuser == null) return null;
    String path = rootCollectionName + '/games/users/' + localuser.uid;
    print('CALL STREAM ## COMPANY BOARD' + path);
    return Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => CompanyBoard.fromFirestore(doc));
  }
}
