import 'dart:convert';

class DocumentRecord {
  const DocumentRecord({
    required this.collection,
    required this.id,
    required this.data,
    required this.updatedAt,
    required this.deviceId,
    this.deleted = false,
  });

  final String collection;
  final String id;
  final Map<String, dynamic> data;
  final DateTime updatedAt;
  final String deviceId;
  final bool deleted;

  Map<String, dynamic> toMap() => {
    'collection_name': collection,
    'document_id': id,
    'data_json': jsonEncode(data),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'device_id': deviceId,
    'deleted': deleted ? 1 : 0,
  };

  Map<String, dynamic> toWire() => {
    'collection': collection,
    'id': id,
    'data': data,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
    'deleted': deleted,
  };

  factory DocumentRecord.fromMap(Map<String, Object?> map) => DocumentRecord(
    collection: map['collection_name']! as String,
    id: map['document_id']! as String,
    data: Map<String, dynamic>.from(
      jsonDecode(map['data_json']! as String) as Map,
    ),
    updatedAt: DateTime.parse(map['updated_at']! as String),
    deviceId: map['device_id']! as String,
    deleted: (map['deleted']! as int) == 1,
  );

  factory DocumentRecord.fromWire(Map<String, dynamic> map) => DocumentRecord(
    collection: map['collection'] as String,
    id: map['id'] as String,
    data: Map<String, dynamic>.from(map['data'] as Map? ?? const {}),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
    deviceId: map['deviceId'] as String,
    deleted: map['deleted'] as bool? ?? false,
  );
}
