enum Unit {
  single,
  bulk,
}

extension UnitExtension on Unit {
  String get displayName {
    switch (this) {
      case Unit.single:
        return 'Single';
      case Unit.bulk:
        return 'Bulk';
    }
  }
}

class Warehouse {
  final String name;
  final String address;
  final Map<String, double> coordinates;

  Warehouse({
    required this.name,
    required this.address,
    required this.coordinates,
  });

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      coordinates: Map<String, double>.from(map['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'coordinates': coordinates,
    };
  }
}

class ReceiptData {
  final String warehouse;
  final String rackQr;
  final String itemQr;
  final int quantity;
  final Unit unit;
  final String notes;
  final String? imagePath;
  final DateTime timestamp;
  final Map<String, double>? location;

  ReceiptData({
    required this.warehouse,
    required this.rackQr,
    required this.itemQr,
    required this.quantity,
    required this.unit,
    required this.notes,
    this.imagePath,
    required this.timestamp,
    this.location,
  });

  factory ReceiptData.fromMap(Map<String, dynamic> map) {
    return ReceiptData(
      warehouse: map['warehouse'] ?? '',
      rackQr: map['rack_qr'] ?? '',
      itemQr: map['item_qr'] ?? '',
      quantity: map['quantity'] ?? 0,
      unit: Unit.values.firstWhere(
        (e) => e.name == map['unit'],
        orElse: () => Unit.single,
      ),
      notes: map['notes'] ?? '',
      imagePath: map['image_path'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      location: map['location'] != null 
          ? Map<String, double>.from(map['location'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'warehouse': warehouse,
      'rack_qr': rackQr,
      'item_qr': itemQr,
      'quantity': quantity,
      'unit': unit.name,
      'notes': notes,
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}

class ReceiptResult {
  final bool success;
  final String message;
  final ReceiptData data;

  ReceiptResult({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReceiptResult.fromMap(Map<String, dynamic> map) {
    return ReceiptResult(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: ReceiptData.fromMap(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.toMap(),
    };
  }
}
