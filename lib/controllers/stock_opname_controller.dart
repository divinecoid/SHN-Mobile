import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/gudang_model.dart';
import '../models/item_barang_model.dart';
import '../utils/auth_helper.dart';

class StockOpnameController extends ChangeNotifier {
  bool _isLoadingLocation = false;
  bool _isLoadingWarehouses = false;
  bool _isFreezingStock = false;
  bool _isUnfreezingStock = false;
  bool _isStartingOpname = false;
  bool _isCancellingOpname = false;
  bool _isCompletingOpname = false;
  bool _stockFrozen = false;
  bool _opnameStarted = false;
  String _selectedWarehouse = '';
  String _detectedLocation = '';
  List<Gudang> _warehouses = [];
  List<Map<String, dynamic>> _stockItems = [];
  List<ItemBarang> _itemBarangList = [];
  bool _isLoadingItems = false;
  String _errorMessage = '';
  String _itemBarangError = '';
  BuildContext? _context;
  int? _currentStockOpnameId;
  Map<int, double> _stockFisikMap = {}; // itemId -> stockFisik
  bool _isDisposed = false;

  // Getters
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingWarehouses => _isLoadingWarehouses;
  bool get isFreezingStock => _isFreezingStock;
  bool get isUnfreezingStock => _isUnfreezingStock;
  bool get isStartingOpname => _isStartingOpname;
  bool get isCancellingOpname => _isCancellingOpname;
  bool get isCompletingOpname => _isCompletingOpname;
  bool get stockFrozen => _stockFrozen;
  bool get opnameStarted => _opnameStarted;
  String get selectedWarehouse => _selectedWarehouse;
  String get detectedLocation => _detectedLocation;
  List<Gudang> get warehouses => _warehouses;
  List<Map<String, dynamic>> get stockItems => _stockItems;
  List<ItemBarang> get itemBarangList => _itemBarangList;
  bool get isLoadingItems => _isLoadingItems;
  String get errorMessage => _errorMessage;
  String get itemBarangError => _itemBarangError;
  int? get currentStockOpnameId => _currentStockOpnameId;
  Map<int, double> get stockFisikMap => _stockFisikMap;

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
    await _loadOpnameSession();
  }

  /// Load stock opname session from SharedPreferences
  Future<void> _loadOpnameSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final opnameId = prefs.getInt('opname_id');
      final opnameActive = prefs.getBool('opname_active') ?? false;
      final opnameWarehouse = prefs.getString('opname_warehouse') ?? '';
      
      if (opnameId != null && opnameActive && opnameWarehouse.isNotEmpty) {
        _currentStockOpnameId = opnameId;
        _selectedWarehouse = opnameWarehouse;
        _opnameStarted = true;
        
        // Check if stock was frozen
        final stockFrozen = prefs.getBool('opname_stock_frozen') ?? false;
        _stockFrozen = stockFrozen;
        
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading opname session: $e');
    }
  }

  Future<void> _detectLocation() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = '';
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (_isDisposed) return;
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (_isDisposed) return;
        
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
      
      if (_isDisposed) return;

      // For demo purposes, we'll use mock warehouse detection
      // In a real app, you would call an API to find the nearest warehouse
      _detectedLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      
      // Auto-select the nearest warehouse based on location
      await _selectNearestWarehouse(position.latitude, position.longitude);

    } catch (e) {
      if (_isDisposed) return;
      _errorMessage = 'Gagal mendeteksi lokasi: $e';
      _detectedLocation = 'Lokasi tidak dapat dideteksi';
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
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

  /// Get user ID from SharedPreferences or decode from token
  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Try to get user_id if stored
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        return userId;
      }
      
      // If not stored, try to decode from token
      final token = prefs.getString('token');
      if (token != null) {
        // Decode JWT token to get user ID
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            // Add padding if needed
            String normalizedPayload = payload;
            switch (payload.length % 4) {
              case 1:
                normalizedPayload += '===';
                break;
              case 2:
                normalizedPayload += '==';
                break;
              case 3:
                normalizedPayload += '=';
                break;
            }
            
            final decoded = utf8.decode(base64Url.decode(normalizedPayload));
            final Map<String, dynamic> payloadMap = json.decode(decoded);
            
            // Try different possible keys for user ID
            if (payloadMap.containsKey('user_id')) {
              return payloadMap['user_id'] as int?;
            } else if (payloadMap.containsKey('id')) {
              return payloadMap['id'] as int?;
            } else if (payloadMap.containsKey('sub')) {
              final sub = payloadMap['sub'];
              if (sub is int) return sub;
              if (sub is String) return int.tryParse(sub);
            }
          }
        } catch (e) {
          debugPrint('Error decoding token: $e');
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<void> _loadWarehouses() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoadingWarehouses = true;
      _errorMessage = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (_isDisposed) return;
      
      if (token == null) {
        // Redirect to login if no token
        await _handleSessionExpired();
        if (!_isDisposed) {
          setState(() {
            _isLoadingWarehouses = false;
          });
        }
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
      if (_isDisposed) return;
      _errorMessage = 'Gagal memuat data gudang: $e';
      debugPrint('Error loading warehouses: $e');
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isLoadingWarehouses = false;
        });
      }
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
      if (!_isDisposed) {
        notifyListeners();
      }
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
            _itemBarangError = '';
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
    if (_isDisposed) return;
    
    setState(() {
      _isLoadingItems = true;
      _itemBarangError = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (_isDisposed) return;
      
      if (token == null) {
        // Redirect to login if no token
        await _handleSessionExpired();
        if (!_isDisposed) {
          setState(() {
            _isLoadingItems = false;
          });
        }
        return;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_STOCK_OPNAME_ITEM_BARANG_LIST'] ?? '/api/stock-opname/item-barang-list';
      
      // Build query parameters
      final queryParams = <String, String>{
        'gudang_id': gudangId.toString(),
      };
      
      // Add stock_opname_id if available
      if (_currentStockOpnameId != null) {
        queryParams['stock_opname_id'] = _currentStockOpnameId.toString();
      }
      
      final uri = Uri.parse('$baseUrl$apiPath').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('Item Barang API Response: ${jsonData.toString()}');
        
        try {
          final ItemBarangResult itemBarangResult = ItemBarangResult.fromMap(jsonData);
          
          if (itemBarangResult.success) {
            if (!_isDisposed) {
              setState(() {
                _itemBarangList = itemBarangResult.data;
                _itemBarangError = '';
                _isLoadingItems = false;
              });
            }
            debugPrint('Item Barang loaded: ${_itemBarangList.length} items');
            debugPrint('Notifying listeners after loading items');
          } else {
            if (!_isDisposed) {
              setState(() {
                _itemBarangError = itemBarangResult.message;
                _itemBarangList = [];
                _isLoadingItems = false;
              });
            }
            debugPrint('Item Barang API error: ${itemBarangResult.message}');
          }
        } catch (parseError) {
          if (!_isDisposed) {
            setState(() {
              _itemBarangError = 'Gagal memproses data item barang: $parseError';
              _itemBarangList = [];
              _isLoadingItems = false;
            });
          }
          debugPrint('Item Barang parse error: $parseError');
          debugPrint('JSON Data: ${jsonData.toString()}');
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return;
      } else {
        if (!_isDisposed) {
          setState(() {
            _itemBarangError = 'Gagal mengambil data item barang: ${response.statusCode}';
            _itemBarangList = [];
            _isLoadingItems = false;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _itemBarangError = 'Gagal memuat data item barang: $e';
          _itemBarangList = [];
          _isLoadingItems = false;
        });
      }
      debugPrint('Error loading item barang: $e');
    }
  }

  /// Create stock opname with freeze/unfreeze option
  Future<Map<String, dynamic>?> _createStockOpname({
    required int gudangId,
    required bool shouldFreeze,
    String? catatan,
  }) async {
    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        await _handleSessionExpired();
        return null;
      }

      // Get user ID
      final userId = await _getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID tidak ditemukan. Silakan login kembali.';
        });
        return null;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_STOCK_OPNAME'] ?? '/api/stock-opname';
      
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'pic_user_id': userId,
        'gudang_id': gudangId,
      };
      
      if (catatan != null && catatan.isNotEmpty) {
        requestBody['catatan'] = catatan;
      }
      
      requestBody['should_freeze'] = shouldFreeze;
      
      final response = await http.post(
        Uri.parse('$baseUrl$apiPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'] as Map<String, dynamic>;
          _currentStockOpnameId = data['id'] as int?;
          
          debugPrint('Stock opname created successfully. ID: $_currentStockOpnameId');
          return jsonData;
        } else {
          setState(() {
            _errorMessage = jsonData['message'] ?? 'Gagal membuat stock opname';
          });
          return null;
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return null;
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Validation failed';
        });
        return null;
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Gagal membuat stock opname: ${response.statusCode}';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat stock opname: $e';
      });
      debugPrint('Error creating stock opname: $e');
      return null;
    }
  }

  Future<void> freezeStockAndStartOpname() async {
    if (_selectedWarehouse.isEmpty) {
      _errorMessage = 'Pilih lokasi gudang terlebih dahulu';
      if (!_isDisposed) {
        notifyListeners();
      }
      return;
    }

    setState(() {
      _isFreezingStock = true;
      _errorMessage = '';
    });

    try {
      // Get selected warehouse ID
      final selectedGudang = _warehouses.firstWhere(
        (g) => g.namaGudang == _selectedWarehouse,
      );

      // Create stock opname with freeze
      final result = await _createStockOpname(
        gudangId: selectedGudang.id,
        shouldFreeze: true,
        catatan: 'Stock opname dengan freeze - ${DateTime.now().toString()}',
      );

      if (result != null) {
        // Reload item barang to refresh frozen status
        await loadItemBarang(selectedGudang.id);
        
        // Save opname session data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('opname_warehouse', _selectedWarehouse);
        await prefs.setString('opname_start_time', DateTime.now().toIso8601String());
        await prefs.setBool('opname_active', true);
        await prefs.setBool('opname_stock_frozen', true);
        if (_currentStockOpnameId != null) {
          await prefs.setInt('opname_id', _currentStockOpnameId!);
        }

        setState(() {
          _stockFrozen = true;
          _opnameStarted = true;
          _isFreezingStock = false;
        });
        
        debugPrint('Stock opname created and frozen successfully. ID: $_currentStockOpnameId');
      } else {
        setState(() {
          _isFreezingStock = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membekukan stok dan memulai opname: $e';
        _isFreezingStock = false;
      });
      debugPrint('Error freezing stock and starting opname: $e');
    }
  }

  Future<void> unfreezeStock() async {
    if (_selectedWarehouse.isEmpty) {
      _errorMessage = 'Pilih lokasi gudang terlebih dahulu';
      if (!_isDisposed) {
        notifyListeners();
      }
      return;
    }

    setState(() {
      _isUnfreezingStock = true;
      _errorMessage = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        await _handleSessionExpired();
        setState(() {
          _isUnfreezingStock = false;
        });
        return;
      }

      // Get selected warehouse ID
      final selectedGudang = _warehouses.firstWhere(
        (g) => g.namaGudang == _selectedWarehouse,
      );

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_UNFREEZE_STOCK'] ?? '/api/item-barang/unfreeze';
      
      final response = await http.post(
        Uri.parse('$baseUrl$apiPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'gudang_id': selectedGudang.id,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          setState(() {
            _stockFrozen = false;
            _isUnfreezingStock = false;
          });
          // Reload item barang to refresh frozen status
          await loadItemBarang(selectedGudang.id);
          
          debugPrint('Stock unfrozen successfully. Updated count: ${jsonData['data']?['updated_count'] ?? 0}');
        } else {
          setState(() {
            _errorMessage = jsonData['message'] ?? 'Gagal membuka stok';
            _isUnfreezingStock = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return;
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Unauthorized. Admin access required.';
          _isUnfreezingStock = false;
        });
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Validation failed';
          _isUnfreezingStock = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal membuka stok: ${response.statusCode}';
          _isUnfreezingStock = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuka stok: $e';
        _isUnfreezingStock = false;
      });
      debugPrint('Error unfreezing stock: $e');
    }
  }

  Future<void> startOpnameWithoutFreeze() async {
    if (_selectedWarehouse.isEmpty) {
      _errorMessage = 'Pilih lokasi gudang terlebih dahulu';
      if (!_isDisposed) {
        notifyListeners();
      }
      return;
    }

    setState(() {
      _isStartingOpname = true;
      _errorMessage = '';
    });

    try {
      // Get selected warehouse ID
      final selectedGudang = _warehouses.firstWhere(
        (g) => g.namaGudang == _selectedWarehouse,
      );

      // Create stock opname without freeze
      final result = await _createStockOpname(
        gudangId: selectedGudang.id,
        shouldFreeze: false,
        catatan: 'Stock opname tanpa freeze - ${DateTime.now().toString()}',
      );

      if (result != null) {
        // Reload item barang
        await loadItemBarang(selectedGudang.id);
        
        // Save opname session data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('opname_warehouse', _selectedWarehouse);
        await prefs.setString('opname_start_time', DateTime.now().toIso8601String());
        await prefs.setBool('opname_active', true);
        await prefs.setBool('opname_without_freeze', true);
        await prefs.setBool('opname_stock_frozen', false);
        if (_currentStockOpnameId != null) {
          await prefs.setInt('opname_id', _currentStockOpnameId!);
        }

        setState(() {
          _opnameStarted = true;
          _isStartingOpname = false;
        });
        
        debugPrint('Stock opname created without freeze. ID: $_currentStockOpnameId');
      } else {
        setState(() {
          _isStartingOpname = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memulai opname: $e';
        _isStartingOpname = false;
      });
      debugPrint('Error starting opname without freeze: $e');
    }
  }

  void markStockAsAccurate(int itemId) {
    final itemIndex = _stockItems.indexWhere((item) => item['id'] == itemId.toString());
    if (itemIndex != -1) {
      _stockItems[itemIndex]['realStock'] = _stockItems[itemIndex]['bookStock'];
      _stockItems[itemIndex]['status'] = 'accurate';
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  void updateRealStock(int itemId, int realStock) {
    final itemIndex = _stockItems.indexWhere((item) => item['id'] == itemId.toString());
    if (itemIndex != -1) {
      _stockItems[itemIndex]['realStock'] = realStock;
      _stockItems[itemIndex]['status'] = 'different';
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  int getCompletedItemsCount() {
    return _stockItems.where((item) => item['realStock'] != null).length;
  }

  int getTotalItemsCount() {
    return _stockItems.length;
  }

  Future<void> resetOpname() async {
    // If there's an active stock opname ID, cancel it first
    if (_currentStockOpnameId != null) {
      await _cancelStockOpname(_currentStockOpnameId!);
    }
    
    // Reset local state
    _stockFrozen = false;
    _opnameStarted = false;
    _selectedWarehouse = '';
    _detectedLocation = '';
    _errorMessage = '';
    _stockItems.clear();
    _itemBarangList.clear();
    _currentStockOpnameId = null;
    _stockFisikMap.clear();
    
    // Clear opname session data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('opname_warehouse');
    await prefs.remove('opname_start_time');
    await prefs.remove('opname_active');
    await prefs.remove('opname_without_freeze');
    await prefs.remove('opname_stock_frozen');
    await prefs.remove('opname_id');
    
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Cancel stock opname via API
  Future<void> _cancelStockOpname(int stockOpnameId) async {
    setState(() {
      _isCancellingOpname = true;
      _errorMessage = '';
    });

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        await _handleSessionExpired();
        setState(() {
          _isCancellingOpname = false;
        });
        return;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_STOCK_OPNAME'] ?? '/api/stock-opname';
      final String cancelPath = '$apiPath/$stockOpnameId/cancel';
      
      final response = await http.patch(
        Uri.parse('$baseUrl$cancelPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          debugPrint('Stock opname cancelled successfully. ID: $stockOpnameId');
          setState(() {
            _isCancellingOpname = false;
          });
        } else {
          setState(() {
            _errorMessage = jsonData['message'] ?? 'Gagal membatalkan stock opname';
            _isCancellingOpname = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Redirect to login when session expired
        await _handleSessionExpired();
        return;
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Data tidak ditemukan';
          _isCancellingOpname = false;
        });
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Stock opname tidak dapat dibatalkan';
          _isCancellingOpname = false;
        });
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _errorMessage = jsonData['message'] ?? 'Gagal membatalkan stock opname: ${response.statusCode}';
          _isCancellingOpname = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membatalkan stock opname: $e';
        _isCancellingOpname = false;
      });
      debugPrint('Error cancelling stock opname: $e');
    }
  }

  /// Complete stock opname
  Future<Map<String, dynamic>> completeStockOpname() async {
    try {
      // Check if stock opname ID exists
      if (_currentStockOpnameId == null) {
        return {
          'success': false,
          'message': 'Stock opname belum dimulai',
        };
      }

      setState(() {
        _isCompletingOpname = true;
        _errorMessage = '';
      });

      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        await _handleSessionExpired();
        setState(() {
          _isCompletingOpname = false;
        });
        return {
          'success': false,
          'message': 'Session expired',
        };
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPathTemplate = dotenv.env['API_STOCK_OPNAME_COMPLETE'] ?? '/api/stock-opname/{id}/complete';
      final String apiPath = apiPathTemplate.replaceAll('{id}', _currentStockOpnameId.toString());

      final uri = Uri.parse('$baseUrl$apiPath');

      debugPrint('Completing stock opname: ${uri.toString()}');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Complete stock opname response status: ${response.statusCode}');
      debugPrint('Complete stock opname response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          // Clear session
          await _clearOpnameSession();
          
          setState(() {
            _isCompletingOpname = false;
            _opnameStarted = false;
            _stockFrozen = false;
            _currentStockOpnameId = null;
            _selectedWarehouse = '';
            _itemBarangList = [];
          });

          return {
            'success': true,
            'message': jsonData['message'] ?? 'Stock opname berhasil diselesaikan',
            'data': jsonData['data'],
          };
        } else {
          setState(() {
            _isCompletingOpname = false;
            _errorMessage = jsonData['message'] ?? 'Gagal menyelesaikan stock opname';
          });
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Gagal menyelesaikan stock opname',
          };
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        setState(() {
          _isCompletingOpname = false;
        });
        return {
          'success': false,
          'message': 'Session expired',
        };
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _isCompletingOpname = false;
          _errorMessage = jsonData['message'] ?? 'Gagal menyelesaikan stock opname';
        });
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Gagal menyelesaikan stock opname',
        };
      }
    } catch (e) {
      debugPrint('Error completing stock opname: $e');
      setState(() {
        _isCompletingOpname = false;
        _errorMessage = 'Error: $e';
      });
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Clear stock opname session
  Future<void> _clearOpnameSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('opname_id');
      await prefs.remove('opname_active');
      await prefs.remove('opname_warehouse');
      await prefs.remove('opname_stock_frozen');
      debugPrint('Stock opname session cleared');
    } catch (e) {
      debugPrint('Error clearing opname session: $e');
    }
  }

  /// Add detail stock opname
  Future<Map<String, dynamic>> addDetailStockOpname({
    required ItemBarang item,
    required int stokFisik,
    String? catatan,
  }) async {
    try {
      // Check if stock opname ID exists
      if (_currentStockOpnameId == null) {
        return {
          'success': false,
          'message': 'Stock opname belum dimulai',
        };
      }

      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        await _handleSessionExpired();
        return {
          'success': false,
          'message': 'Session expired',
        };
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPathTemplate = dotenv.env['API_STOCK_OPNAME_ADD_DETAIL'] ?? '/api/stock-opname/{id}/detail';
      final String apiPath = apiPathTemplate.replaceAll('{id}', _currentStockOpnameId.toString());

      // Build request body
      final Map<String, dynamic> requestBody = {
        'kode_barang': item.kodeBarang,
        'stok_fisik': stokFisik,
      };

      // Add catatan if provided
      if (catatan != null && catatan.isNotEmpty) {
        requestBody['catatan'] = catatan;
      }

      // Check if item is frozen (frozenAt != null)
      final bool isFrozen = item.frozenAt != null && item.frozenAt!.isNotEmpty;

      // If item is frozen, stok_sistem is required
      if (isFrozen) {
        requestBody['stok_sistem'] = item.quantity.toInt();
      }
      // If item is not frozen, don't send stok_sistem (will be null automatically)

      final uri = Uri.parse('$baseUrl$apiPath');

      debugPrint('Adding detail stock opname: ${uri.toString()}');
      debugPrint('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Add detail response status: ${response.statusCode}');
      debugPrint('Add detail response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          // Reload item barang list to update checked status
          final gudangId = item.gudangId;
          if (gudangId > 0) {
            await loadItemBarang(gudangId);
          }

          return {
            'success': true,
            'message': jsonData['message'] ?? 'Detail stock opname berhasil ditambahkan',
            'data': jsonData['data'],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Gagal menambahkan detail stock opname',
          };
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        return {
          'success': false,
          'message': 'Session expired',
        };
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Kode barang tidak ditemukan',
        };
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        // Handle validation errors including:
        // - Item barang sudah ada di detail stock opname ini
        // - Barang tidak berada di gudang stock opname
        // - Barang tidak memiliki gudang yang ditetapkan
        // - Stok sistem wajib diisi karena item barang dalam status beku
        // - Other validation errors
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Validasi gagal. Pastikan barang berada di gudang yang sama dengan stock opname.',
        };
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Gagal menambahkan detail stock opname',
        };
      }
    } catch (e) {
      debugPrint('Error adding detail stock opname: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Process scanned barcode and find matching item
  ItemBarang? processScannedBarang(String scannedCode) {
    try {
      // Find item by kode barang (exact match)
      try {
        return _itemBarangList.firstWhere(
          (item) => item.kodeBarang == scannedCode,
        );
      } catch (e) {
        // Try partial match
        return _itemBarangList.firstWhere(
          (item) => item.kodeBarang.toLowerCase().contains(scannedCode.toLowerCase()) ||
                    scannedCode.toLowerCase().contains(item.kodeBarang.toLowerCase()),
        );
      }
    } catch (e) {
      debugPrint('Item tidak ditemukan untuk kode: $scannedCode');
      return null;
    }
  }

  /// Save stock fisik for an item
  void saveStockFisik(int itemId, double stockFisik) {
    setState(() {
      _stockFisikMap[itemId] = stockFisik;
    });
    debugPrint('Stock fisik disimpan untuk item ID $itemId: $stockFisik');
  }

  /// Get stock fisik for an item, return null if not set
  double? getStockFisik(int itemId) {
    return _stockFisikMap[itemId];
  }

  /// Get stock fisik for an item, return system stock if not set
  double getStockFisikOrDefault(int itemId, double defaultStock) {
    return _stockFisikMap[itemId] ?? defaultStock;
  }

  /// Check if item has stock fisik input
  bool hasStockFisik(int itemId) {
    return _stockFisikMap.containsKey(itemId);
  }

  /// Clear stock fisik for an item
  void clearStockFisik(int itemId) {
    setState(() {
      _stockFisikMap.remove(itemId);
    });
  }

  /// Clear all stock fisik
  void clearAllStockFisik() {
    setState(() {
      _stockFisikMap.clear();
    });
  }

  void setState(VoidCallback fn) {
    if (_isDisposed) return;
    fn();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
} 