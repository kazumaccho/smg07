import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smg07/models/user.dart';
import 'package:smg07/shared/global.dart';

import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  // catch sign in or sign out
  Stream<User> get user {
    return _auth.onAuthStateChanged
        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  /*
  // sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
*/

  // sign in with email  & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void setGoogleUserSignIn(FirebaseUser user) {
    _userFromFirebaseUser(user);
  }

  // create BidBook
  Future createBidBook(Map<String, int> markets) async {
    //localuser = await _auth.currentUser();
    try {
      await db.createBidderBook(localuser.uid, markets);
      return localuser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future assignUser(String nickName, String companyName) async {
    localuser = await _auth.currentUser();
    /*
    try {
      await db.assignUser(localuser.uid, nickName, companyName);
      return localuser;
    } catch (e) {
      print(e.toString());
      return null;
    }
    */
  }

  Future bidPrice(List<dynamic> markets, List<int> prices, int rd,
      String companyName, bool mr, List<int> maxPrice) async {
    //localuser = await _auth.currentUser();
    try {
      await DatabaseService().bidPrice(
          localuser.uid, markets, prices, rd, companyName, mr, maxPrice);
      return localuser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future bidMarkets4Client(List<dynamic> markets, List<int> volumes) async {
    //localuser = await _auth.currentUser();
    try {
      await DatabaseService()
          .bidMarkets4Client(localuser.uid, markets, volumes);
      return localuser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void firstJoin() {
    String path = rootCollectionName + '/games';
    //DocumentSnapshot aDoc;
    //print('path :' + path);
    List<dynamic> data;
    Firestore.instance
        .document(path)
        .get()
        .then((aDoc) => {
              if (!aDoc.data.containsKey('users'))
                {
                  Firestore.instance.document(path).updateData({
                    'users': [localuser.uid],
                    'parentCnt': 0
                  }),
                  Firestore.instance
                      .document(rootCollectionName + '/combat_data')
                      .updateData({'joins': 1})
                }
              else
                {
                  data = aDoc.data['users'],
                  if (aDoc.data['users'].contains(localuser.uid))
                    {
                      //do nothing
                    }
                  else
                    {
                      data.add(localuser.uid),
                      Firestore.instance
                          .document(path)
                          .updateData({'users': data}),
                      Firestore.instance
                          .document(rootCollectionName + '/combat_data')
                          .updateData({'joins': data.length})
                    }
                }
            })
        .catchError((err) => print(err));
    /*
    Firestore.instance
        .document(rootCollectionName + '/games/users/' + localuser.uid)
        .setData({'dmm': localuser.uid});

     */
  }

  changeCurrentOwner() {
    //parentCntを取り出して
    //parentCntを更新
    //そしてcurrentOwnerも更新
    //変更したOwnerは通知する
    int cnt;
    int direction;
    int result;
    Firestore.instance
        .document(rootCollectionName + '/games')
        .get()
        .then((aDoc) => {
              cnt = aDoc.data['parentCnt'],
              direction = aDoc.data['direction'],
              // -4(2)  -3(0) -2(1)  -1(2) ,0 ,1 ,2
              cnt += direction,
              result = cnt % aDoc.data['users'].length,
              /*
              print('result : ' +
                  result.toString() +
                  ' cnt : ' +
                  cnt.toString() +
                  ' users.length : ' +
                  aDoc.data['users'].length.toString()),

       */
              Firestore.instance
                  .document(rootCollectionName + '/games')
                  .updateData({
                'parentCnt': result,
                'currentOwner': aDoc.data['users'][result]
              }),
            });
  }
}
