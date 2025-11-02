import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/gudang_model.dart';
import '../models/item_barang_model.dart';
import '../utils/auth_helper.dart';

class StockOpnameController extends ChangeNotifier {
  bool _isLoadingLocation = false;
  bool _isLoadingWarehouses = false;
  bool _isFreezingStock = false;
  bool _isStartingOpname = false;
  bool _stockFrozen = false;
  bool _opnameStarted = false;
  String _selectedWarehouse = '';
  String _detectedLocation = '';
  List<Gudang> _warehouses = [];
  List<Map<String, dynamic>> _stockItems = [];
  List<ItemBarang> _itemBarangList = [];
  bool _isLoadingItems = false;
  String _errorMessage = '';
  BuildContext? _context;

  // Getters
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingWarehouses => _isLoadingWarehouses;
  bool get isFreezingStock => _isFreezingStock;
  bool get isStartingOpname => _isStartingOpname;
  bool get stockFrozen => _stockFrozen;
  bool get opnameStarted => _opnameStarted;
  String get selectedWarehouse => _selectedWarehouse;
  String get detectedLocation => _detectedLocation;
  List<Gudang> get warehouses => _warehouses;
  List<Map<String, dynamic>> get stockItems => _stockItems;
  List<ItemBarang> get itemBarangList => _itemBarangList;
  bool get isLoadingItems => _isLoadingItems;
  String get errorMessage => _errorMessage;

  StockOpnameController() {
    _initialize();
  }

  /// Set context for session handling
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Handle session expired
  Future<void> _handleSessionExpired() async {
    if (_context != null) {
      await AuthHelper.handleSessionExpired(_context!);
    }
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

  Future<void> _loadWarehouses() async {
    setState(() {
      _isLoadingWarehouses = true;
      _errorMessage = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        // Redirect to login if no token
        await _handleSessionExpired();
        setState(() {
          _isLoadingWarehouses = false;
        });
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
          _errorMessage = '';
        } else {
          _errorMessage = gudangResult.message;
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return;
      } else {
        _errorMessage = 'Gagal mengambil data gudang: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data gudang: $e';
      debugPrint('Error loading warehouses: $e');
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
    // Only consider warehouses with valid coordinates
    Gudang? nearestWarehouse;
    double minDistance = double.infinity;

    for (var warehouse in _warehouses) {
      // Check if warehouse has coordinates
      if (warehouse.latitude != null && warehouse.longitude != null) {
        double distance = Geolocator.distanceBetween(
          lat,
          lng,
          warehouse.latitude!,
          warehouse.longitude!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestWarehouse = warehouse;
        }
      }
    }

    // Auto-select if within reasonable distance (e.g., 10km) and coordinates are available
    if (nearestWarehouse != null && minDistance <= 10000) {
      _selectedWarehouse = nearestWarehouse.namaGudang;
      notifyListeners();
    }
  }

  void updateSelectedWarehouse(String warehouseName) {
    debugPrint('Warehouse selected: $warehouseName');
    debugPrint('Available warehouses count: ${_warehouses.length}');
    
    // Load items automatically when warehouse is selected
    if (_warehouses.isNotEmpty) {
      try {
        final selectedGudang = _warehouses.firstWhere(
          (g) => g.namaGudang == warehouseName,
        );
        debugPrint('Found warehouse ID: ${selectedGudang.id}');
        if (selectedGudang.id > 0) {
          // Update selected warehouse and clear previous items
          setState(() {
            _selectedWarehouse = warehouseName;
            _itemBarangList.clear();
            _errorMessage = '';
          });
          // Load items asynchronously
          loadItemBarang(selectedGudang.id);
        } else {
          debugPrint('Invalid warehouse ID: ${selectedGudang.id}');
          setState(() {
            _selectedWarehouse = warehouseName;
          });
        }
      } catch (e) {
        debugPrint('Error finding warehouse: $e');
        debugPrint('Available warehouses: ${_warehouses.map((w) => w.namaGudang).toList()}');
        setState(() {
          _selectedWarehouse = warehouseName;
        });
      }
    } else {
      debugPrint('No warehouses available');
      setState(() {
        _selectedWarehouse = warehouseName;
      });
    }
  }

  Future<void> loadItemBarang(int gudangId) async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        // Redirect to login if no token
        await _handleSessionExpired();
        setState(() {
          _isLoadingItems = false;
        });
        return;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_ITEM_BARANG'] ?? '/api/item-barang';
      
      final response = await http.get(
        Uri.parse('$baseUrl$apiPath?gudang_id=$gudangId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('Item Barang API Response: ${jsonData.toString()}');
        
        try {
          final ItemBarangResult itemBarangResult = ItemBarangResult.fromMap(jsonData);
          
          if (itemBarangResult.success) {
            setState(() {
              _itemBarangList = itemBarangResult.data;
              _errorMessage = '';
              _isLoadingItems = false;
            });
            debugPrint('Item Barang loaded: ${_itemBarangList.length} items');
            debugPrint('Notifying listeners after loading items');
          } else {
            setState(() {
              _errorMessage = itemBarangResult.message;
              _itemBarangList = [];
              _isLoadingItems = false;
            });
            debugPrint('Item Barang API error: ${itemBarangResult.message}');
          }
        } catch (parseError) {
          setState(() {
            _errorMessage = 'Gagal memproses data item barang: $parseError';
            _itemBarangList = [];
            _isLoadingItems = false;
          });
          debugPrint('Item Barang parse error: $parseError');
          debugPrint('JSON Data: ${jsonData.toString()}');
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return;
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data item barang: ${response.statusCode}';
          _itemBarangList = [];
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data item barang: $e';
        _itemBarangList = [];
        _isLoadingItems = false;
      });
      debugPrint('Error loading item barang: $e');
    }
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
        _opnameStarted = true;
      });

    } catch (e) {
      _errorMessage = 'Gagal membekukan stok: $e';
    } finally {
      setState(() {
        _isFreezingStock = false;
      });
    }
  }

  Future<void> startOpnameWithoutFreeze() async {
    if (_selectedWarehouse.isEmpty) {
      _errorMessage = 'Pilih lokasi gudang terlebih dahulu';
      notifyListeners();
      return;
    }

    setState(() {
      _isStartingOpname = true;
      _errorMessage = '';
    });

    try {
      // Load stock items for the selected warehouse without freezing
      await _loadStockItems();
      
      // Save opname session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('opname_warehouse', _selectedWarehouse);
      await prefs.setString('opname_start_time', DateTime.now().toIso8601String());
      await prefs.setBool('opname_active', true);
      await prefs.setBool('opname_without_freeze', true);

      setState(() {
        _opnameStarted = true;
      });

    } catch (e) {
      _errorMessage = 'Gagal memulai opname: $e';
    } finally {
      setState(() {
        _isStartingOpname = false;
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
    _opnameStarted = false;
    _selectedWarehouse = '';
    _detectedLocation = '';
    _errorMessage = '';
    _stockItems.clear();
    _itemBarangList.clear();
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