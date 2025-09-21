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
  final String notes;
  final DateTime timestamp;
  final Map<String, double>? location;

  ReceiptData({
    required this.warehouse,
    required this.rackQr,
    required this.itemQr,
    required this.quantity,
    required this.notes,
    required this.timestamp,
    this.location,
  });

  factory ReceiptData.fromMap(Map<String, dynamic> map) {
    return ReceiptData(
      warehouse: map['warehouse'] ?? '',
      rackQr: map['rack_qr'] ?? '',
      itemQr: map['item_qr'] ?? '',
      quantity: map['quantity'] ?? 0,
      notes: map['notes'] ?? '',
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
      'notes': notes,
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
