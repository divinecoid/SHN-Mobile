import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockOpnameController extends ChangeNotifier {
  bool _isLoadingLocation = false;
  bool _isLoadingWarehouses = false;
  bool _isFreezingStock = false;
  bool _stockFrozen = false;
  String _selectedWarehouse = '';
  String _detectedLocation = '';
  List<Map<String, dynamic>> _warehouses = [];
  List<Map<String, dynamic>> _stockItems = [];
  String _errorMessage = '';

  // Getters
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingWarehouses => _isLoadingWarehouses;
  bool get isFreezingStock => _isFreezingStock;
  bool get stockFrozen => _stockFrozen;
  String get selectedWarehouse => _selectedWarehouse;
  String get detectedLocation => _detectedLocation;
  List<Map<String, dynamic>> get warehouses => _warehouses;
  List<Map<String, dynamic>> get stockItems => _stockItems;
  String get errorMessage => _errorMessage;

  StockOpnameController() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _detectLocation();
    await _loadWarehouses();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = '';
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // For demo purposes, we'll use mock warehouse detection
      // In a real app, you would call an API to find the nearest warehouse
      _detectedLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      
      // Auto-select the nearest warehouse based on location
      await _selectNearestWarehouse(position.latitude, position.longitude);

    } catch (e) {
      _errorMessage = 'Gagal mendeteksi lokasi: $e';
      _detectedLocation = 'Lokasi tidak dapat dideteksi';
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _isLoadingWarehouses = true;
    });

    try {
      // Mock warehouse data - in real app, this would come from API
      await Future.delayed(const Duration(seconds: 1));
      _warehouses = [
        {
          'id': '1',
          'name': 'Gudang Utama Jakarta',
          'address': 'Jl. Sudirman No. 123, Jakarta Pusat',
          'latitude': -6.2088,
          'longitude': 106.8456,
        },
        {
          'id': '2',
          'name': 'Gudang Bandung',
          'address': 'Jl. Asia Afrika No. 100, Bandung',
          'latitude': -6.9175,
          'longitude': 107.6191,
        },
        {
          'id': '3',
          'name': 'Gudang Surabaya',
          'address': 'Jl. Tunjungan No. 50, Surabaya',
          'latitude': -7.2575,
          'longitude': 112.7521,
        },
        {
          'id': '4',
          'name': 'Gudang Medan',
          'address': 'Jl. Sudirman No. 200, Medan',
          'latitude': 3.5952,
          'longitude': 98.6722,
        },
      ];
    } catch (e) {
      _errorMessage = 'Gagal memuat data gudang: $e';
    } finally {
      setState(() {
        _isLoadingWarehouses = false;
      });
    }
  }

  Future<void> _loadStockItems() async {
    setState(() {
      _isLoadingWarehouses = true;
    });

    try {
      // Mock stock data - in real app, this would come from API
      await Future.delayed(const Duration(seconds: 1));
      _stockItems = [
        {
          'id': '1',
          'name': 'Laptop Dell Inspiron 15',
          'code': 'LAP001',
          'bookStock': 25,
          'realStock': null,
          'unit': 'unit',
          'category': 'Elektronik',
          'location': 'Rak A-01',
        },
        {
          'id': '2',
          'name': 'Mouse Wireless Logitech',
          'code': 'MOU002',
          'bookStock': 150,
          'realStock': null,
          'unit': 'unit',
          'category': 'Aksesoris',
          'location': 'Rak B-03',
        },
        {
          'id': '3',
          'name': 'Keyboard Mechanical RGB',
          'code': 'KEY003',
          'bookStock': 45,
          'realStock': null,
          'unit': 'unit',
          'category': 'Aksesoris',
          'location': 'Rak B-05',
        },
        {
          'id': '4',
          'name': 'Monitor 24" Samsung',
          'code': 'MON004',
          'bookStock': 30,
          'realStock': null,
          'unit': 'unit',
          'category': 'Elektronik',
          'location': 'Rak A-02',
        },
        {
          'id': '5',
          'name': 'Kabel HDMI 2m',
          'code': 'CAB005',
          'bookStock': 200,
          'realStock': null,
          'unit': 'unit',
          'category': 'Aksesoris',
          'location': 'Rak C-01',
        },
        {
          'id': '6',
          'name': 'Printer HP LaserJet',
          'code': 'PRI006',
          'bookStock': 12,
          'realStock': null,
          'unit': 'unit',
          'category': 'Elektronik',
          'location': 'Rak A-03',
        },
      ];
    } catch (e) {
      _errorMessage = 'Gagal memuat data stok: $e';
    } finally {
      setState(() {
        _isLoadingWarehouses = false;
      });
    }
  }

  Future<void> _selectNearestWarehouse(double lat, double lng) async {
    if (_warehouses.isEmpty) return;

    // Find the nearest warehouse based on distance
    Map<String, dynamic> nearestWarehouse = _warehouses.first;
    double minDistance = double.infinity;

    for (var warehouse in _warehouses) {
      double distance = Geolocator.distanceBetween(
        lat,
        lng,
        warehouse['latitude'],
        warehouse['longitude'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestWarehouse = warehouse;
      }
    }

    // Auto-select if within reasonable distance (e.g., 10km)
    if (minDistance <= 10000) {
      _selectedWarehouse = nearestWarehouse['name'];
      notifyListeners();
    }
  }

  void updateSelectedWarehouse(String warehouseName) {
    _selectedWarehouse = warehouseName;
    notifyListeners();
  }

  Future<void> freezeStockAndStartOpname() async {
    if (_selectedWarehouse.isEmpty) {
      _errorMessage = 'Pilih lokasi gudang terlebih dahulu';
      notifyListeners();
      return;
    }

    setState(() {
      _isFreezingStock = true;
      _errorMessage = '';
    });

    try {
      // Simulate API call to freeze stock
      await Future.delayed(const Duration(seconds: 2));
      
      // Load stock items for the selected warehouse
      await _loadStockItems();
      
      // Save opname session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('opname_warehouse', _selectedWarehouse);
      await prefs.setString('opname_start_time', DateTime.now().toIso8601String());
      await prefs.setBool('opname_active', true);

      setState(() {
        _stockFrozen = true;
      });

    } catch (e) {
      _errorMessage = 'Gagal membekukan stok: $e';
    } finally {
      setState(() {
        _isFreezingStock = false;
      });
    }
  }

  void markStockAsAccurate(int itemId) {
    final itemIndex = _stockItems.indexWhere((item) => item['id'] == itemId.toString());
    if (itemIndex != -1) {
      _stockItems[itemIndex]['realStock'] = _stockItems[itemIndex]['bookStock'];
      _stockItems[itemIndex]['status'] = 'accurate';
      notifyListeners();
    }
  }

  void updateRealStock(int itemId, int realStock) {
    final itemIndex = _stockItems.indexWhere((item) => item['id'] == itemId.toString());
    if (itemIndex != -1) {
      _stockItems[itemIndex]['realStock'] = realStock;
      _stockItems[itemIndex]['status'] = 'different';
      notifyListeners();
    }
  }

  int getCompletedItemsCount() {
    return _stockItems.where((item) => item['realStock'] != null).length;
  }

  int getTotalItemsCount() {
    return _stockItems.length;
  }

  void resetOpname() {
    _stockFrozen = false;
    _selectedWarehouse = '';
    _detectedLocation = '';
    _errorMessage = '';
    _stockItems.clear();
    notifyListeners();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 