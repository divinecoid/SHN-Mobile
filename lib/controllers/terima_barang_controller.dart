import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/terima_barang_model.dart';
import '../models/gudang_model.dart';

class TerimaBarangController extends ChangeNotifier {
  // Location variables
  Position? _currentPosition;
  String _selectedWarehouse = '';
  bool _isLoadingLocation = false;

  // QR Scan variables
  String _scannedRackQR = '';
  String _scannedItemQR = '';

  // Form variables
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  Unit _selectedUnit = Unit.single;
  
  // Image variables
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Warehouse data using Gudang model
  List<Gudang> _warehouses = [];
  bool _isLoadingWarehouses = false;
  String? _warehouseError;

  // Getters
  Position? get currentPosition => _currentPosition;
  String get selectedWarehouse => _selectedWarehouse;
  bool get isLoadingLocation => _isLoadingLocation;
  String get scannedRackQR => _scannedRackQR;
  String get scannedItemQR => _scannedItemQR;
  Unit get selectedUnit => _selectedUnit;
  File? get selectedImage => _selectedImage;
  List<Gudang> get warehouses => _warehouses;
  bool get isLoadingWarehouses => _isLoadingWarehouses;
  String? get warehouseError => _warehouseError;

  // Check if form is complete
  bool get isFormComplete => 
      _scannedRackQR.isNotEmpty && 
      _scannedItemQR.isNotEmpty && 
      quantityController.text.isNotEmpty;

  /// Initialize the controller and load warehouses
  Future<void> initialize() async {
    await loadWarehouses();
    // Set default quantity for single unit
    quantityController.text = '1';
  }

  /// Get authentication token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Load warehouses from API
  Future<void> loadWarehouses() async {
    _isLoadingWarehouses = true;
    _warehouseError = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        _warehouseError = 'Token autentikasi tidak ditemukan. Silakan login kembali.';
        _isLoadingWarehouses = false;
        notifyListeners();
        return;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_GUDANG'] ?? '/api/gudang';
      
      final response = await http.get(
        Uri.parse('$baseUrl$apiPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final GudangResult gudangResult = GudangResult.fromMap(jsonData);
        
        if (gudangResult.success) {
          _warehouses = gudangResult.data;
          // Don't auto-select warehouse, let user choose manually
        } else {
          _warehouseError = gudangResult.message;
        }
      } else if (response.statusCode == 401) {
        _warehouseError = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else {
        _warehouseError = 'Gagal mengambil data gudang: ${response.statusCode}';
      }
    } catch (e) {
      _warehouseError = 'Error: $e';
    } finally {
      _isLoadingWarehouses = false;
      notifyListeners();
    }
  }

  /// Get current device location (manual call)
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
    if (_warehouses.isEmpty) return '';
    
    // Since we don't have coordinates in Gudang model, 
    // we'll just return the first warehouse as default
    return _warehouses.first.namaGudang;
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

  /// Update selected unit
  void updateSelectedUnit(Unit unit) {
    _selectedUnit = unit;
    
    // If single is selected, set quantity to 1 and clear the text field
    if (unit == Unit.single) {
      quantityController.text = '1';
    } else if (unit == Unit.bulk) {
      // If bulk is selected, clear the field for user input
      quantityController.clear();
    }
    
    notifyListeners();
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  /// Remove selected image
  void removeImage() {
    _selectedImage = null;
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
    
    // For single unit, quantity is always 1
    if (_selectedUnit == Unit.single) {
      return null;
    }
    
    // For bulk unit, validate quantity input
    if (_selectedUnit == Unit.bulk) {
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

      // Determine quantity based on unit type
      int quantity;
      if (_selectedUnit == Unit.single) {
        quantity = 1; // Always 1 for single unit
      } else {
        quantity = int.parse(quantityController.text); // User input for bulk
      }

      // Create receipt data using model
      ReceiptData receiptData = ReceiptData(
        warehouse: _selectedWarehouse,
        rackQr: _scannedRackQR,
        itemQr: _scannedItemQR,
        quantity: quantity,
        unit: _selectedUnit,
        notes: notesController.text,
        imagePath: _selectedImage?.path,
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
    _selectedUnit = Unit.single;
    quantityController.text = '1'; // Set default quantity for single unit
    notesController.clear();
    _selectedImage = null;
    notifyListeners();
  }

  /// Get warehouse by name
  Gudang? getWarehouseByName(String name) {
    try {
      return _warehouses.firstWhere((warehouse) => warehouse.namaGudang == name);
    } catch (e) {
      return null;
    }
  }

  /// Get warehouse by ID
  Gudang? getWarehouseById(int id) {
    try {
      return _warehouses.firstWhere((warehouse) => warehouse.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get warehouse by kode
  Gudang? getWarehouseByKode(String kode) {
    try {
      return _warehouses.firstWhere((warehouse) => warehouse.kode == kode);
    } catch (e) {
      return null;
    }
  }

  /// Refresh warehouses data
  Future<void> refreshWarehouses() async {
    await loadWarehouses();
  }

  @override
  void dispose() {
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
