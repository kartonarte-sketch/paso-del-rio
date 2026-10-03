import 'package:flutter/foundation.dart';

import '../core/data/restaurant_repository.dart';
import '../core/models/restaurant_models.dart';
import '../core/web/browser_location.dart';
import 'app_sections.dart';

enum SyncIndicator { local, syncing, synced, error }

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final RestaurantRepository repository;

  UserRole? role;
  int sectionIndex = 0;
  String? pendingSectionSlug;
  SyncIndicator syncIndicator = SyncIndicator.local;
  List<ServicePackage> packages = [];
  List<MenuProduct> products = [];
  List<DiningTable> tables = [];
  List<GuestGroup> groups = [];
  List<Reservation> reservations = [];
  List<RestaurantOrder> orders = [];

  Future<void> initialize() async {
    await refresh();
    if (kIsWeb) {
      applyWebSlug(readAppHash());
      listenAppHash(applyWebSlug);
    }
  }

  Future<void> refresh() async {
    final values = await Future.wait([
      repository.packages(),
      repository.products(),
      repository.tables(),
      repository.groups(),
      repository.reservations(),
      repository.orders(),
    ]);
    packages = values[0] as List<ServicePackage>;
    products = values[1] as List<MenuProduct>;
    tables = values[2] as List<DiningTable>;
    groups = values[3] as List<GuestGroup>;
    reservations = values[4] as List<Reservation>;
    orders = values[5] as List<RestaurantOrder>;
    notifyListeners();
  }

  bool login(UserRole selectedRole, String pin) {
    const pins = {
      UserRole.admin: 'admin123',
      UserRole.reception: 'recep123',
      UserRole.waiter: 'mesero123',
      UserRole.kitchen: 'cocina123',
    };
    if (pins[selectedRole] != pin) return false;
    role = selectedRole;
    final pending = pendingSectionSlug;
    pendingSectionSlug = null;
    if (pending != null && applyWebSlug(pending)) {
      notifyListeners();
      return true;
    }
    sectionIndex = allowedSections.first;
    _syncWebHash();
    notifyListeners();
    return true;
  }

  void logout() {
    role = null;
    sectionIndex = 0;
    writeAppHash('');
    notifyListeners();
  }

  List<int> get allowedSections {
    if (role == null) return const [0];
    return [
      for (var i = 0; i < kAppSections.length; i++)
        if (kAppSections[i].roles.contains(role)) i,
    ];
  }

  bool applyWebSlug(String slug) {
    if (slug.isEmpty) return false;
    final index = kAppSections.indexWhere((section) => section.slug == slug);
    if (index < 0) return false;
    if (role == null) {
      pendingSectionSlug = slug;
      return false;
    }
    if (!allowedSections.contains(index)) return false;
    sectionIndex = index;
    _syncWebHash();
    notifyListeners();
    return true;
  }

  void selectSection(int index) {
    if (!allowedSections.contains(index)) return;
    sectionIndex = index;
    _syncWebHash();
    notifyListeners();
  }

  void _syncWebHash() {
    if (!kIsWeb) return;
    writeAppHash(kAppSections[sectionIndex].slug);
  }

  Future<void> registerGroup({
    required String leader,
    required String whatsapp,
    required int adults,
    required int minors,
    required int pets,
    required ServicePackage servicePackage,
    required String paymentMethod,
    required List<String> vehicles,
  }) async {
    await repository.registerGroup(
      leader: leader,
      whatsapp: whatsapp,
      adults: adults,
      minors: minors,
      pets: pets,
      servicePackage: servicePackage,
      paymentMethod: paymentMethod,
      vehicles: vehicles,
    );
    await refresh();
  }

  Future<void> createReservation({
    required String name,
    required String whatsapp,
    required int partySize,
    required DateTime scheduledAt,
    String? tableId,
  }) async {
    await repository.addReservation(
      Reservation(
        id: repository.nextId(),
        name: name,
        whatsapp: whatsapp,
        partySize: partySize,
        scheduledAt: scheduledAt,
        status: 'pending',
        tableId: tableId,
      ),
    );
    await refresh();
  }

  Future<void> assignTable(DiningTable table, GuestGroup group) async {
    await repository.assignTable(table, group);
    await refresh();
  }

  Future<void> sendOrder({
    required DiningTable table,
    required Map<MenuProduct, int> quantities,
  }) async {
    if (table.groupId == null || quantities.isEmpty) return;
    final lines = quantities.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => OrderLine(
            productId: entry.key.id,
            name: entry.key.name,
            destination: entry.key.destination,
            price: entry.key.price,
            quantity: entry.value,
          ),
        )
        .toList();
    await repository.saveOrder(
      RestaurantOrder(
        id: repository.nextId(),
        tableId: table.id,
        tableLabel: 'M${table.number}',
        groupId: table.groupId!,
        lines: lines,
        status: 'pending',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await refresh();
  }

  Future<void> updateOrderStatus(RestaurantOrder order, String status) async {
    await repository.updateOrder(order.copyWith(status: status));
    await refresh();
  }

  Future<void> settleTable(DiningTable table, String paymentMethod) async {
    await repository.settleTable(
      table,
      orders.where((order) => order.tableId == table.id),
      paymentMethod,
    );
    await refresh();
  }

  Future<void> quickBarSale(Map<MenuProduct, int> quantities) async {
    final lines = quantities.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => OrderLine(
            productId: entry.key.id,
            name: entry.key.name,
            destination: 'barra',
            price: entry.key.price,
            quantity: entry.value,
          ),
        )
        .toList();
    if (lines.isEmpty) return;
    await repository.saveOrder(
      RestaurantOrder(
        id: repository.nextId(),
        tableId: 'barra',
        tableLabel: 'Venta rápida',
        groupId: 'quick-sale',
        lines: lines,
        status: 'delivered',
        createdAt: DateTime.now().toUtc(),
        paid: true,
        paymentMethod: 'Efectivo',
      ),
    );
    await refresh();
  }

  Future<void> saveProduct(MenuProduct product) async {
    await repository.saveProduct(product);
    await refresh();
  }

  Future<void> savePackage(ServicePackage package) async {
    await repository.savePackage(package);
    await refresh();
  }

  Future<void> deletePackage(String id) async {
    await repository.deletePackage(id);
    await refresh();
  }

  Future<void> resetDefaultPackages() async {
    await repository.resetDefaultPackages();
    await refresh();
  }

  int get peopleToday {
    final now = DateTime.now();
    return groups
        .where((group) {
          final local = group.createdAt.toLocal();
          return local.year == now.year &&
              local.month == now.month &&
              local.day == now.day;
        })
        .fold(0, (sum, group) => sum + group.adults + group.minors);
  }

  int get incomeToday {
    final now = DateTime.now();
    final entryIncome = groups
        .where((group) {
          final local = group.createdAt.toLocal();
          return local.year == now.year &&
              local.month == now.month &&
              local.day == now.day;
        })
        .fold(0, (sum, group) => sum + group.totalPaid);
    final salesIncome = orders
        .where((order) {
          final local = order.createdAt.toLocal();
          return order.paid &&
              local.year == now.year &&
              local.month == now.month &&
              local.day == now.day;
        })
        .fold(0, (sum, order) => sum + order.total);
    return entryIncome + salesIncome;
  }
}
