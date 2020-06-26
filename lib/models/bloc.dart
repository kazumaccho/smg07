import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import 'company_board.dart';

class Bloc_CompanyBoard with ChangeNotifier {
  CompanyBoard myBoard;
  String path = '';
  Bloc_CompanyBoard({this.path});
  int cash;

  Stream<CompanyBoard> get boardStream {
    return Firestore.instance
        .document(path)
        .snapshots()
        .map((doc) => CompanyBoard.fromFirestore(doc));
  }
}
