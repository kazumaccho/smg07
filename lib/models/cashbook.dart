import 'package:cloud_firestore/cloud_firestore.dart';

class CashBook {
  /*
  ・経費
  ・売上個数
  ・売上高
  ・倉庫在庫数
  ・倉庫在庫高
  ・工場在庫数
  ・工場在庫高
  ・営業所在庫数
  ・営業所在庫高
  ・完成数
  ・投入数
  ・機械の簿価・機械の種類・機械数
  ・借入金・借入金利
  ・研究開発投資
  ・広告宣伝投資
   */

  int keihi = 0;
  int sales = 0;
  int uriage = 0;
  int kansei = 0;
  int tounyu = 0;
  int hoken = 0;
  int retires = 0;
  int lost_stock = 0;
  int lost_factory = 0;
  int lost_shop = 0;
  int buyMaterials = 0;
  int sumMaterials = 0;
  int shihon = 0;

  //List<Map<String, int>> sold_machine = [];
  List<dynamic> sold_machine = [];
  // List<int> depts = [];
  List<dynamic> depts = [];

  CashBook(
      {this.keihi,
      this.sales,
      this.uriage,
      this.kansei,
      this.tounyu,
      this.hoken,
      this.retires,
      this.lost_factory,
      this.lost_shop,
      this.lost_stock,
      this.buyMaterials,
      this.sumMaterials,
      this.shihon,
      this.depts,
      this.sold_machine});

  factory CashBook.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return CashBook(
      keihi: data['keihi'] ?? 0,
      sales: data['sales'] ?? 0,
      uriage: data['uriage'] ?? 0,
      kansei: data['kansei'] ?? 0,
      tounyu: data['tounyu'] ?? 0,
      hoken: data['hoken'] ?? 0,
      retires: data['retires'] ?? 0,
      lost_stock: data['lost_stock'] ?? 0,
      lost_shop: data['lost_shop'] ?? 0,
      lost_factory: data['lost_factory'] ?? 0,
      buyMaterials: data['buyMaterials'] ?? 0,
      sumMaterials: data['sumMaterials'] ?? 0,
      shihon: data['shihon'] ?? 0,
      sold_machine: data['sold_machine'] ?? [],
      depts: data['depts'] ?? [],
    );
  }

  factory CashBook.First() {
    return CashBook(
      keihi: 0,
      sales: 0,
      uriage: 0,
      kansei: 0,
      tounyu: 0,
      hoken: 0,
      retires: 0,
      lost_stock: 0,
      lost_shop: 0,
      lost_factory: 0,
      buyMaterials: 0,
      sumMaterials: 0,
      shihon: 0,
      sold_machine: [],
      depts: [],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = Map<String, dynamic>();

    result['keihi'] = keihi;
    result['sales'] = sales;
    result['uriage'] = uriage;
    result['kansei'] = kansei;
    result['tounyu'] = tounyu;
    result['hoken'] = hoken;
    result['retires'] = retires;
    result['lost_stock'] = lost_stock;
    result['lost_factory'] = lost_factory;
    result['lost_shop'] = lost_shop;
    result['buyMaterials'] = buyMaterials;
    result['sumMaterials'] = sumMaterials;
    result['sold_machine'] = sold_machine;
    result['depts'] = depts;
    result['shihon'] = shihon;
    return result;
  }
}
