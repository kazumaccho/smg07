import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smg07/models/cashbook.dart';
import 'package:smg07/models/company_board.dart';
import 'package:smg07/shared/global.dart';

class M_PLBS {
  final int period;
  final int cash;
  final List<dynamic> machines;
  final int boka;
  final int stock_room_boka;
  final int stock_room_materials;
  final int factory_room_boka;
  final int factory_room_materials;
  final int shop_room_boka;
  final int shop_room_materials;

  final int tax;
  final int haitou;
  final int dept;
  final int shihon;
  final int rieki;
  final int touki;
  final int higai;
  final int kimatu;

  final int P;
  final int V;
  final int Q;
  final int M;
  final int F;
  final int G;

  M_PLBS(
      {this.period,
      this.cash,
      this.machines,
      this.boka,
      this.stock_room_boka,
      this.stock_room_materials,
      this.factory_room_boka,
      this.factory_room_materials,
      this.shop_room_boka,
      this.shop_room_materials,
      this.tax,
      this.haitou,
      this.dept,
      this.shihon,
      this.rieki,
      this.touki,
      this.higai,
      this.P,
      this.V,
      this.M,
      this.Q,
      this.F,
      this.G,
      this.kimatu});

  factory M_PLBS.fromFirestore(DocumentSnapshot data) {
    Map doc = data.data;
    return M_PLBS(
        period: doc['period'],
        cash: doc['cash'],
        machines: doc['machines'],
        boka: doc['boka'],
        stock_room_boka: doc['stock_room_boka'],
        stock_room_materials: doc['stock_room_materials'],
        factory_room_boka: doc['factory_room_boka'],
        factory_room_materials: doc['factory_room_materials'],
        shop_room_boka: doc['shop_room_boka'],
        shop_room_materials: doc['shop_room_materials'],
        tax: doc['tax'],
        haitou: doc['haitou'],
        dept: doc['dept'],
        shihon: doc['shihon'],
        rieki: doc['rieki'],
        touki: doc['touki'],
        higai: doc['higai'],
        P: doc['P'],
        V: doc['V'],
        M: doc['M'],
        Q: doc['Q'],
        F: doc['F'],
        G: doc['G'],
        kimatu: doc['kimatu']);
  }

  factory M_PLBS.createPeriod_0() {
    return M_PLBS(
        period: 0,
        cash: 0,
        machines: [],
        boka: 0,
        stock_room_boka: 0,
        stock_room_materials: 0,
        factory_room_boka: 0,
        factory_room_materials: 0,
        shop_room_boka: 0,
        shop_room_materials: 0,
        tax: 0,
        haitou: 0,
        dept: 0,
        shihon: 0,
        rieki: 0,
        touki: 0,
        higai: 0,
        P: 0,
        V: 0,
        M: 0,
        Q: 0,
        F: 0,
        G: 0,
        kimatu: 0);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = Map<String, dynamic>();

    result['period'] = period;
    result['cash'] = cash;
    result['machines'] = machines;
    result['boka'] = boka;
    result['stock_room_boka'] = stock_room_boka;
    result['stock_room_materials'] = stock_room_materials;
    result['factory_room_boka'] = factory_room_boka;
    result['factory_room_materials'] = factory_room_materials;
    result['shop_room_boka'] = shop_room_boka;
    result['shop_room_materials'] = shop_room_materials;
    result['tax'] = tax;
    result['haitou'] = haitou;
    result['dept'] = dept;
    result['shihon'] = shihon;
    result['rieki'] = rieki;
    result['touki'] = touki;
    result['higai'] = higai;
    result['P'] = P;
    result['V'] = V;
    result['M'] = M;
    result['Q'] = Q;
    result['F'] = F;
    result['G'] = G;
    result['kimatu'] = kimatu;

    return result;
  }

  calcPLBS(CompanyBoard board, CashBook book, M_PLBS previousPLBS) {
    //現金
    //資本金 previousPLBS.shihon,
    //借入金
    //利益余剰金
    //tax
    //在庫
    //
    //print('----------- KESSAN  CASHBOOK --------------');
    //print(book.toMap().toString());
    int keihi = calcMachineKeihi(board);
    print('機械減価償却費:' + keihi.toString());
    //人件費と機械経費ケイさん
    keihi += (board.worker + board.salesman + board.retires) *
        (15 + (board.priod - 1) * 2);
    board.cash -= (board.worker + board.salesman + board.retires) *
        (15 + (board.priod - 1) * 2);

    keihi += (board.worker + board.salesman) * (10 + (board.priod - 1));
    board.cash -= (board.worker + board.salesman) * (10 + (board.priod - 1));

    for (int index = 0; index < board.machines.length; index++) {
      keihi += 20 + (board.priod - 1) * 2;
      board.cash -= 20 + (board.priod - 1) * 2;
    }

    int kimatu = keihi;
    print('期末人件費機械経費合計:' + kimatu.toString());
    /*
      そうこの簿価ケイさん
      購入金額 + 繰越金額
      -------------------- => 平均単価（四捨五入)
      購入個数 + 繰越個数

      ロスト金額 倉庫　

     */

    //倉庫在庫　---------------------------------------------------------
    int stock_room_tanka = 0;

    //倉庫単価計算
    if ((book.sumMaterials + previousPLBS.stock_room_boka) == 0) {
    } else {
      stock_room_tanka = ((book.sumMaterials + previousPLBS.stock_room_boka) /
              (book.buyMaterials + previousPLBS.stock_room_materials))
          .floor();
    }
    print('倉庫在庫単価:' + stock_room_tanka.toString());
    //火事被害額
    int higai = stock_room_tanka * board.stock_lost;
    int stock_room_boka = 0;
    print('倉庫火災被害:' + higai.toString());

    //工場簿価の計算
    int tounyuBoka = previousPLBS.stock_room_boka + book.sumMaterials;
    tounyuBoka -= stock_room_tanka * book.lost_stock;

    if (book.tounyu > 0) {
      stock_room_boka = stock_room_tanka * board.stock_room;
      tounyuBoka -= stock_room_boka;
    } else {
      stock_room_boka = tounyuBoka;
      tounyuBoka = 0;
    }

    print('倉庫の投入材料金額:' + tounyuBoka.toString());

    //工場在庫 ---------------------------------------------------------
    //構造在庫単価計算
    int factory_room_tanka = 0;
    if ((tounyuBoka + previousPLBS.factory_room_boka) == 0) {
    } else {
      factory_room_tanka =
          ((tounyuBoka + previousPLBS.factory_room_boka + book.tounyu * 2) /
                  (book.tounyu + previousPLBS.factory_room_materials))
              .floor();
    }
    print('工場の材料単価:' + factory_room_tanka.toString());
    //製造ミス金額
    higai += factory_room_tanka * board.factory_lost;
    print('工場の被害額:' + (factory_room_tanka * board.factory_lost).toString());
    //工場在庫簿価計算
    int factory_room_boka = 0;

    //工場簿価の計算
    int kanseiBoka =
        previousPLBS.factory_room_boka + book.tounyu * 2 + tounyuBoka;
    kanseiBoka -= factory_room_tanka * book.lost_factory;

    if (book.kansei > 0) {
      factory_room_boka = factory_room_tanka * board.factory_room;
      kanseiBoka -= factory_room_boka;
    } else {
      factory_room_boka = kanseiBoka;
      kanseiBoka = 0;
    }

    print('工場の完成簿価:' + kanseiBoka.toString());
    //---------------------------------------------------------
    //営業所簿価
    int shop_room_tanka = 0;
    if ((kanseiBoka + previousPLBS.shop_room_boka + book.kansei) == 0) {
    } else {
      shop_room_tanka =
          ((kanseiBoka + previousPLBS.shop_room_boka + book.kansei) /
                  (book.kansei + previousPLBS.shop_room_materials))
              .floor();
    }
    print('営業所の商品単価:' + shop_room_tanka.toString());

    //盗難被害
    higai += shop_room_tanka * board.shop_lost;
    print('営業所の被害:' + (shop_room_tanka * board.shop_lost).toString());
    //営業所簿価
    int shop_room_boka = 0;

    //変動費の計算
    int hendohi = previousPLBS.shop_room_boka + book.kansei + kanseiBoka;
    hendohi -= shop_room_tanka * book.lost_shop;

    if (book.sales > 0) {
      shop_room_boka = shop_room_tanka * board.shop_room;
      hendohi -= shop_room_boka;
    } else {
      shop_room_boka = hendohi;
      hendohi = 0;
    }

    print('sales = ' + book.sales.toString() + ' 変動費=' + hendohi.toString());

    //営業外損益の計算
    int touki = book.uriage - hendohi - book.keihi - keihi;
    higai += book.hoken;
    touki -= higai;

    for (int index = 0; index < book.sold_machine.length; index) {
      if (board.machines[index].containsKey('big')) {
        touki += 100 - board.machines[index]['big'];
      }
      if (board.machines[index].containsKey('attach')) {
        touki += 10 - board.machines[index]['attach'];
      }
      if (board.machines[index].containsKey('small')) {
        touki += 50 - board.machines[index]['small'];
      }
    }

    //税金の計算
    int tax = 0;
    if (touki > 0) {
      if (previousPLBS.rieki < 0) {
        tax = (((touki + previousPLBS.rieki) / 2) + 0.5).floor();
        if (tax < 0) tax = 0;
      } else {
        tax = ((touki / 2) + 0.5).floor();
      }
    }
    touki -= tax;
    //配当金の計算
    int haitou = 0;
    if (tax > 0) {
      haitou = (touki * 0.15).floor();
    }
    touki -= previousPLBS.haitou;
    int dept;
    if (book.depts.length == 0) {
      dept = 0;
    } else {
      dept = book.depts.reduce((value, element) => value + element);
    }

    Firestore.instance.document(myBoardPath).updateData({'cash': board.cash});

    return M_PLBS(
        period: board.priod,
        cash: board.cash,
        shihon: previousPLBS.shihon + book.shihon,
        dept: previousPLBS.dept + dept,
        stock_room_materials: board.stock_room,
        factory_room_materials: board.factory_room,
        shop_room_materials: board.shop_room,
        boka: calcMachineBoka(board),
        stock_room_boka: stock_room_boka,
        factory_room_boka: factory_room_boka,
        shop_room_boka: shop_room_boka,
        V: hendohi,
        P: book.uriage,
        M: book.uriage - hendohi,
        F: book.keihi + keihi,
        G: book.uriage - hendohi - book.keihi - keihi,
        Q: book.sales,
        higai: higai,
        touki: touki,
        rieki: touki + previousPLBS.rieki,
        haitou: haitou,
        tax: tax,
        machines: board.machines,
        kimatu: kimatu);
  }

  int calcMachineKeihi(CompanyBoard board) {
    int result = 0;
    for (int index = 0; index < board.machines.length; index++) {
      if (board.machines[index].containsKey('big')) {
        if (board.machines[index]['big'] != 0) {
          board.machines[index]['big'] -= 20;
          result += 20;
        }
        continue;
      }
      ;
      if (board.machines[index].containsKey('attach')) {
        if (board.machines[index]['attach'] != 0) {
          board.machines[index]['attach'] -= 2;
          result += 2;
        }
      }
      ;
      if (board.machines[index].containsKey('small')) {
        if (board.machines[index]['small'] != 0) {
          board.machines[index]['small'] -= 10;
          result += 10;
        }
      }
      print('減価償却：' + result.toString());
    }
    Firestore.instance
        .document(myBoardPath)
        .updateData({'machines': board.machines});
    return result;
  }

  int calcMachineBoka(CompanyBoard board) {
    int result = 0;
    for (int index = 0; index < board.machines.length; index++) {
      board.machines[index].forEach((key, value) => {result += value});
    }
    return result;
  }
}
