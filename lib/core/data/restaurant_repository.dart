import 'package:uuid/uuid.dart';

import '../models/document_record.dart';
import '../models/restaurant_models.dart';
import 'local_database.dart';
import 'seed_data.dart';

class Collections {
  static const packages = 'packages';
  static const products = 'products';
  static const tables = 'tables';
  static const groups = 'groups';
  static const reservations = 'reservations';
  static const orders = 'orders';
  static const payments = 'payments';
}

class RestaurantRepository {
  RestaurantRepository(this._database);

  final LocalDatabase _database;
  final Uuid _uuid = const Uuid();

  String nextId() => _uuid.v4();

  Future<void> seedIfEmpty() async {
    if (await _database.count(Collections.tables) > 0) return;
    for (var i = 0; i < seedPackages.length; i++) {
      final item = Map<String, dynamic>.from(seedPackages[i]);
      final id = item.remove('id')! as String;
      await _put(Collections.packages, id, item);
    }
    for (var i = 0; i < seedProducts.length; i++) {
      final item = Map<String, dynamic>.from(seedProducts[i]);
      item.putIfAbsent('cost', () => 0);
      item['active'] = true;
      await _put(Collections.products, 'product-${i + 1}', item);
    }
    for (var i = 1; i <= 12; i++) {
      await _put(Collections.tables, 'principal-$i', {
        'zoneId': 'principal',
        'zoneName': 'Zona Principal',
        'number': i,
        'status': 'free',
        'groupId': null,
        'groupName': null,
      });
    }
  }

  Future<List<ServicePackage>> packages() async =>
      (await _database.list(Collections.packages))
          .map((record) => ServicePackage.fromJson(record.id, record.data))
          .toList();

  Future<List<MenuProduct>> products() async =>
      (await _database.list(Collections.products))
          .map((record) => MenuProduct.fromJson(record.id, record.data))
          .toList();

  Future<List<DiningTable>> tables() async =>
      (await _database.list(Collections.tables))
          .map((record) => DiningTable.fromJson(record.id, record.data))
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  Future<List<GuestGroup>> groups() async =>
      (await _database.list(Collections.groups))
          .map((record) => GuestGroup.fromJson(record.id, record.data))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<List<Reservation>> reservations() async =>
      (await _database.list(Collections.reservations))
          .map((record) => Reservation.fromJson(record.id, record.data))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  Future<List<RestaurantOrder>> orders() async =>
      (await _database.list(Collections.orders))
          .map((record) => RestaurantOrder.fromJson(record.id, record.data))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<GuestGroup> registerGroup({
    required String leader,
    required String whatsapp,
    required int adults,
    required int minors,
    required int pets,
    required ServicePackage servicePackage,
    required String paymentMethod,
    required List<String> vehicles,
  }) async {
    final group = GuestGroup(
      id: nextId(),
      leader: leader,
      whatsapp: whatsapp,
      adults: adults,
      minors: minors,
      pets: pets,
      packageId: servicePackage.id,
      packageName: servicePackage.name,
      packageColor: servicePackage.color,
      totalPaid:
          adults * servicePackage.priceAdult +
          minors * servicePackage.priceMinor,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now().toUtc(),
      vehicles: vehicles,
    );
    await _put(Collections.groups, group.id, group.toJson());
    await _put(Collections.payments, nextId(), {
      'type': 'entrance',
      'groupId': group.id,
      'amount': group.totalPaid,
      'method': paymentMethod,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    return group;
  }

  Future<void> addReservation(Reservation reservation) =>
      _put(Collections.reservations, reservation.id, reservation.toJson());

  Future<void> assignTable(DiningTable table, GuestGroup group) async {
    await _put(
      Collections.tables,
      table.id,
      table
          .copyWith(
            status: 'occupied',
            groupId: group.id,
            groupName: group.leader,
          )
          .toJson(),
    );
    await _put(
      Collections.groups,
      group.id,
      group.copyWith(tableId: table.id).toJson(),
    );
  }

  Future<void> releaseTable(DiningTable table, GuestGroup? group) async {
    await _put(
      Collections.tables,
      table.id,
      table.copyWith(status: 'free', clearGroup: true).toJson(),
    );
    if (group != null) {
      await _put(
        Collections.groups,
        group.id,
        group.copyWith(active: false).toJson(),
      );
    }
  }

  Future<void> saveOrder(RestaurantOrder order) async {
    await _put(Collections.orders, order.id, order.toJson());
    final currentProducts = await products();
    for (final line in order.lines) {
      final product = currentProducts
          .where((item) => item.id == line.productId)
          .firstOrNull;
      if (product != null) {
        await _put(
          Collections.products,
          product.id,
          product
              .copyWith(stock: (product.stock - line.quantity).clamp(0, 999999))
              .toJson(),
        );
      }
    }
  }

  Future<void> updateOrder(RestaurantOrder order) =>
      _put(Collections.orders, order.id, order.toJson());

  Future<void> settleTable(
    DiningTable table,
    Iterable<RestaurantOrder> orders,
    String paymentMethod,
  ) async {
    var total = 0;
    for (final order in orders.where((item) => !item.paid)) {
      total += order.total;
      await updateOrder(
        order.copyWith(paid: true, paymentMethod: paymentMethod),
      );
    }
    await _put(Collections.payments, nextId(), {
      'type': 'table',
      'tableId': table.id,
      'amount': total,
      'method': paymentMethod,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    final group = (await groups())
        .where((item) => item.id == table.groupId)
        .firstOrNull;
    await releaseTable(table, group);
  }

  Future<void> saveProduct(MenuProduct product) =>
      _put(Collections.products, product.id, product.toJson());

  Future<void> _put(String collection, String id, Map<String, dynamic> data) {
    return _database
        .put(
          DocumentRecord(
            collection: collection,
            id: id,
            data: data,
            updatedAt: DateTime.now().toUtc(),
            deviceId: _database.deviceId,
          ),
        )
        .then((_) {});
  }
}
