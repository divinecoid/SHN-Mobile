import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/terima_barang_model.dart';

class TerimaBarangController extends ChangeNotifier {
  // Location variables
  Position? _currentPosition;
  String _selectedWarehouse = 'Gudang Utama - Jakarta';
  bool _isLoadingLocation = false;

  // QR Scan variables
  String _scannedRackQR = '';
  String _scannedItemQR = '';

  // Form variables
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Warehouse data using model
  final List<Warehouse> _warehouses = [
    Warehouse(
      name: 'Gudang Utama - Jakarta',
      address: 'Jl. Sudirman No. 123, Jakarta Pusat',
      coordinates: {'lat': -6.2088, 'lng': 106.8456},
    ),
    Warehouse(
      name: 'Gudang Cabang - Bandung',
      address: 'Jl. Asia Afrika No. 45, Bandung',
      coordinates: {'lat': -6.9175, 'lng': 107.6191},
    ),
    Warehouse(
      name: 'Gudang Cabang - Surabaya',
      address: 'Jl. Tunjungan No. 67, Surabaya',
      coordinates: {'lat': -7.2575, 'lng': 112.7521},
    ),
  ];

  // Getters
  Position? get currentPosition => _currentPosition;
  String get selectedWarehouse => _selectedWarehouse;
  bool get isLoadingLocation => _isLoadingLocation;
  String get scannedRackQR => _scannedRackQR;
  String get scannedItemQR => _scannedItemQR;
  List<Warehouse> get warehouses => _warehouses;

  // Check if form is complete
  bool get isFormComplete => 
      _scannedRackQR.isNotEmpty && 
      _scannedItemQR.isNotEmpty && 
      quantityController.text.isNotEmpty;

  /// Initialize the controller and get current location
  Future<void> initialize() async {
    await getCurrentLocation();
  }

  /// Get current device location
  Future<void> getCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak tersedia');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = position;
      _selectedWarehouse = _getNearestWarehouse(position);
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Calculate nearest warehouse based on current position
  String _getNearestWarehouse(Position position) {
    double minDistance = double.infinity;
    String nearestWarehouse = _warehouses[0].name;

    for (var warehouse in _warehouses) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        warehouse.coordinates['lat']!,
        warehouse.coordinates['lng']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestWarehouse = warehouse.name;
      }
    }

    return nearestWarehouse;
  }

  /// Update selected warehouse
  void updateSelectedWarehouse(String warehouseName) {
    _selectedWarehouse = warehouseName;
    notifyListeners();
  }

  /// Update scanned rack QR code
  void updateScannedRackQR(String qrCode) {
    _scannedRackQR = qrCode;
    notifyListeners();
  }

  /// Update scanned item QR code
  void updateScannedItemQR(String qrCode) {
    _scannedItemQR = qrCode;
    notifyListeners();
  }

  /// Validate form data
  String? validateForm() {
    if (_scannedRackQR.isEmpty) {
      return 'QR Code rak harus di-scan';
    }
    if (_scannedItemQR.isEmpty) {
      return 'QR Code label barang harus di-scan';
    }
    if (quantityController.text.isEmpty) {
      return 'Jumlah barang harus diisi';
    }
    
    // Validate quantity is a positive number
    try {
      int quantity = int.parse(quantityController.text);
      if (quantity <= 0) {
        return 'Jumlah barang harus lebih dari 0';
      }
    } catch (e) {
      return 'Jumlah barang harus berupa angka';
    }

    return null;
  }

  /// Submit receipt data
  Future<ReceiptResult> submitReceipt() async {
    // Validate form first
    String? validationError = validateForm();
    if (validationError != null) {
      throw Exception(validationError);
    }

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Create receipt data using model
      ReceiptData receiptData = ReceiptData(
        warehouse: _selectedWarehouse,
        rackQr: _scannedRackQR,
        itemQr: _scannedItemQR,
        quantity: int.parse(quantityController.text),
        notes: notesController.text,
        timestamp: DateTime.now(),
        location: _currentPosition != null ? {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        } : null,
      );

      // Here you would typically send data to your backend API
      // For now, we'll just return the data as if it was successful
      
      return ReceiptResult(
        success: true,
        message: 'Data penerimaan barang berhasil disimpan',
        data: receiptData,
      );
    } catch (e) {
      throw Exception('Gagal menyimpan data: $e');
    }
  }

  /// Reset form data
  void resetForm() {
    _scannedRackQR = '';
    _scannedItemQR = '';
    quantityController.clear();
    notesController.clear();
    notifyListeners();
  }

  /// Get warehouse by name
  Warehouse? getWarehouseByName(String name) {
    try {
      return _warehouses.firstWhere((warehouse) => warehouse.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get distance to warehouse
  double? getDistanceToWarehouse(String warehouseName) {
    if (_currentPosition == null) return null;

    Warehouse? warehouse = getWarehouseByName(warehouseName);
    if (warehouse == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      warehouse.coordinates['lat']!,
      warehouse.coordinates['lng']!,
    );
  }

  /// Format distance for display
  String formatDistance(double? distance) {
    if (distance == null) return 'Tidak diketahui';
    
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
