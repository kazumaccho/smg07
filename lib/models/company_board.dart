import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyBoard {
  int priod = 0;
  final String companyName;
  final String nickName;
  int cash = 0;
  bool MR = false;
  bool MD = false;
  bool PAC = false;
  bool HOKEN = false;
  int worker = 0;
  int salesman = 0;
  int RD = 0;
  int kokoku = 0;
  int stock_room = 0;
  int factory_room = 0;
  int shop_room = 0;
  int retires = 0;
  int factory_lost = 0;
  int shop_lost = 0;
  int stock_lost = 0;
  //meishou boka
  //List<Map<String, int>> machines = List<Map<String, int>>();
  List<dynamic> machines = List<dynamic>();

  CompanyBoard(
      {this.priod,
      this.companyName,
      this.nickName,
      this.cash,
      this.MR,
      this.MD,
      this.PAC,
      this.HOKEN,
      this.worker,
      this.salesman,
      this.RD,
      this.kokoku,
      this.stock_room,
      this.factory_room,
      this.shop_room,
      this.retires,
      this.machines,
      this.factory_lost,
      this.shop_lost,
      this.stock_lost});

  factory CompanyBoard.first(int priod,String nickName,String companyName) {
    return CompanyBoard(
      priod: priod,
      companyName: companyName,
      nickName: nickName,
      cash: 0,
      MR: false,
      MD: false,
      PAC: false,
      HOKEN: false,
      worker: 0,
      salesman: 0,
      RD: 0,
      kokoku: 0,
      stock_room: 0,
      factory_room: 0,
      shop_room: 0,
      stock_lost: 0,
      factory_lost: 0,
      shop_lost: 0,
      retires: 0,
      machines: [],
    );
  }

  factory CompanyBoard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return CompanyBoard(
      priod: doc['priod'] ?? 0,
      companyName: doc['companyName'] ?? '',
      nickName: doc['nickName'],
      cash: doc['cash'] ?? 0,
      MR: doc['MR'] ?? false,
      MD: doc['MD'] ?? false,
      PAC: doc['PAC'] ?? false,
      HOKEN: doc['HOKEN'] ?? false,
      worker: doc['worker'] ?? 0,
      salesman: doc['salesman'] ?? 0,
      RD: doc['RD'] ?? 0,
      kokoku: doc['kokoku'] ?? 0,
      stock_room: doc['stock_room'] ?? 0,
      factory_room: doc['factory_room'] ?? 0,
      shop_room: doc['shop_room'] ?? 0,
      retires: doc['retires'] ?? 0,
      machines: doc['machines'] ?? [],
      factory_lost: doc['factory_lost'] ?? 0,
      stock_lost: doc['stock_lost'] ?? 0,
      shop_lost: doc['shop_lost'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = Map<String, dynamic>();

    result['priod'] = priod;
    result['companyName'] = companyName;
    result['nickName'] = nickName;
    result['cash'] = cash;
    result['MR'] = MR;
    result['MD'] = MD;
    result['PAC'] = PAC;
    result['HOKEN'] = HOKEN;
    result['worker'] = worker;
    result['salesman'] = salesman;
    result['RD'] = RD;
    result['kokoku'] = kokoku;
    result['stock_room'] = stock_room;
    result['factory_room'] = factory_room;
    result['shop_room'] = shop_room;
    result['retires'] = retires;
    result['machines'] = machines;
    result['factory_lost'] = factory_lost;
    result['stock_lost'] = stock_lost;
    result['shop_lost'] = shop_lost;

    return result;
  }
}
