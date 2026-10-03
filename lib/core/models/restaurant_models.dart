enum UserRole { admin, reception, waiter, kitchen }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.admin => 'Administrador',
    UserRole.reception => 'Recepción',
    UserRole.waiter => 'Mesero',
    UserRole.kitchen => 'Cocina / Barra',
  };
}

class ServicePackage {
  const ServicePackage({
    required this.id,
    required this.name,
    required this.color,
    required this.priceAdult,
    required this.priceMinor,
    required this.includes,
    required this.lunchVouchers,
  });

  final String id;
  final String name;
  final String color;
  final int priceAdult;
  final int priceMinor;
  final String includes;
  final int lunchVouchers;

  factory ServicePackage.fromJson(String id, Map<String, dynamic> json) =>
      ServicePackage(
        id: id,
        name: json['name'] as String,
        color: json['color'] as String,
        priceAdult: json['priceAdult'] as int,
        priceMinor: json['priceMinor'] as int,
        includes: json['includes'] as String,
        lunchVouchers: json['lunchVouchers'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
    'priceAdult': priceAdult,
    'priceMinor': priceMinor,
    'includes': includes,
    'lunchVouchers': lunchVouchers,
  };
}

class MenuProduct {
  const MenuProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.destination,
    required this.price,
    required this.cost,
    required this.stock,
    this.active = true,
  });

  final String id;
  final String name;
  final String category;
  final String destination;
  final int price;
  final int cost;
  final int stock;
  final bool active;

  factory MenuProduct.fromJson(String id, Map<String, dynamic> json) =>
      MenuProduct(
        id: id,
        name: json['name'] as String,
        category: json['category'] as String,
        destination: json['destination'] as String,
        price: json['price'] as int,
        cost: json['cost'] as int? ?? 0,
        stock: json['stock'] as int? ?? 0,
        active: json['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'destination': destination,
    'price': price,
    'cost': cost,
    'stock': stock,
    'active': active,
  };

  MenuProduct copyWith({
    String? name,
    String? category,
    String? destination,
    int? price,
    int? cost,
    int? stock,
    bool? active,
  }) => MenuProduct(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    destination: destination ?? this.destination,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    stock: stock ?? this.stock,
    active: active ?? this.active,
  );
}

class DiningTable {
  const DiningTable({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.number,
    required this.status,
    this.groupId,
    this.groupName,
  });

  final String id;
  final String zoneId;
  final String zoneName;
  final int number;
  final String status;
  final String? groupId;
  final String? groupName;

  factory DiningTable.fromJson(String id, Map<String, dynamic> json) =>
      DiningTable(
        id: id,
        zoneId: json['zoneId'] as String,
        zoneName: json['zoneName'] as String,
        number: json['number'] as int,
        status: json['status'] as String? ?? 'free',
        groupId: json['groupId'] as String?,
        groupName: json['groupName'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'zoneId': zoneId,
    'zoneName': zoneName,
    'number': number,
    'status': status,
    'groupId': groupId,
    'groupName': groupName,
  };

  DiningTable copyWith({
    String? status,
    String? groupId,
    String? groupName,
    bool clearGroup = false,
  }) => DiningTable(
    id: id,
    zoneId: zoneId,
    zoneName: zoneName,
    number: number,
    status: status ?? this.status,
    groupId: clearGroup ? null : (groupId ?? this.groupId),
    groupName: clearGroup ? null : (groupName ?? this.groupName),
  );
}

class GuestGroup {
  const GuestGroup({
    required this.id,
    required this.leader,
    required this.whatsapp,
    required this.adults,
    required this.minors,
    required this.pets,
    required this.packageId,
    required this.packageName,
    required this.packageColor,
    required this.totalPaid,
    required this.paymentMethod,
    required this.createdAt,
    required this.vehicles,
    this.tableId,
    this.active = true,
  });

  final String id;
  final String leader;
  final String whatsapp;
  final int adults;
  final int minors;
  final int pets;
  final String packageId;
  final String packageName;
  final String packageColor;
  final int totalPaid;
  final String paymentMethod;
  final DateTime createdAt;
  final List<String> vehicles;
  final String? tableId;
  final bool active;

  factory GuestGroup.fromJson(String id, Map<String, dynamic> json) =>
      GuestGroup(
        id: id,
        leader: json['leader'] as String,
        whatsapp: json['whatsapp'] as String,
        adults: json['adults'] as int,
        minors: json['minors'] as int,
        pets: json['pets'] as int? ?? 0,
        packageId: json['packageId'] as String,
        packageName: json['packageName'] as String,
        packageColor: json['packageColor'] as String,
        totalPaid: json['totalPaid'] as int,
        paymentMethod: json['paymentMethod'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        vehicles: List<String>.from(json['vehicles'] as List? ?? const []),
        tableId: json['tableId'] as String?,
        active: json['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'leader': leader,
    'whatsapp': whatsapp,
    'adults': adults,
    'minors': minors,
    'pets': pets,
    'packageId': packageId,
    'packageName': packageName,
    'packageColor': packageColor,
    'totalPaid': totalPaid,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'vehicles': vehicles,
    'tableId': tableId,
    'active': active,
  };

  GuestGroup copyWith({String? tableId, bool? active}) => GuestGroup(
    id: id,
    leader: leader,
    whatsapp: whatsapp,
    adults: adults,
    minors: minors,
    pets: pets,
    packageId: packageId,
    packageName: packageName,
    packageColor: packageColor,
    totalPaid: totalPaid,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    vehicles: vehicles,
    tableId: tableId ?? this.tableId,
    active: active ?? this.active,
  );
}

class Reservation {
  const Reservation({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.partySize,
    required this.scheduledAt,
    required this.status,
    this.tableId,
  });

  final String id;
  final String name;
  final String whatsapp;
  final int partySize;
  final DateTime scheduledAt;
  final String status;
  final String? tableId;

  factory Reservation.fromJson(String id, Map<String, dynamic> json) =>
      Reservation(
        id: id,
        name: json['name'] as String,
        whatsapp: json['whatsapp'] as String,
        partySize: json['partySize'] as int,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        status: json['status'] as String? ?? 'pending',
        tableId: json['tableId'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'whatsapp': whatsapp,
    'partySize': partySize,
    'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    'status': status,
    'tableId': tableId,
  };
}

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.destination,
    required this.price,
    required this.quantity,
    this.notes = '',
  });

  final String productId;
  final String name;
  final String destination;
  final int price;
  final int quantity;
  final String notes;

  int get total => price * quantity;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    productId: json['productId'] as String,
    name: json['name'] as String,
    destination: json['destination'] as String,
    price: json['price'] as int,
    quantity: json['quantity'] as int,
    notes: json['notes'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'destination': destination,
    'price': price,
    'quantity': quantity,
    'notes': notes,
  };
}

class RestaurantOrder {
  const RestaurantOrder({
    required this.id,
    required this.tableId,
    required this.tableLabel,
    required this.groupId,
    required this.lines,
    required this.status,
    required this.createdAt,
    this.paid = false,
    this.paymentMethod,
  });

  final String id;
  final String tableId;
  final String tableLabel;
  final String groupId;
  final List<OrderLine> lines;
  final String status;
  final DateTime createdAt;
  final bool paid;
  final String? paymentMethod;

  int get total => lines.fold(0, (sum, line) => sum + line.total);

  factory RestaurantOrder.fromJson(String id, Map<String, dynamic> json) =>
      RestaurantOrder(
        id: id,
        tableId: json['tableId'] as String,
        tableLabel: json['tableLabel'] as String,
        groupId: json['groupId'] as String,
        lines: (json['lines'] as List)
            .map((item) => OrderLine.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        paid: json['paid'] as bool? ?? false,
        paymentMethod: json['paymentMethod'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'tableId': tableId,
    'tableLabel': tableLabel,
    'groupId': groupId,
    'lines': lines.map((line) => line.toJson()).toList(),
    'status': status,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'paid': paid,
    'paymentMethod': paymentMethod,
    'total': total,
  };

  RestaurantOrder copyWith({
    String? status,
    bool? paid,
    String? paymentMethod,
  }) => RestaurantOrder(
    id: id,
    tableId: tableId,
    tableLabel: tableLabel,
    groupId: groupId,
    lines: lines,
    status: status ?? this.status,
    createdAt: createdAt,
    paid: paid ?? this.paid,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );
}
