import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/penerimaan_barang_model.dart';
import '../models/gudang_model.dart';
import '../utils/auth_helper.dart';

// Helper function to safely parse values that might be String or num
int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class PenerimaanBarangListController extends ChangeNotifier {
  List<PenerimaanBarang> _penerimaanBarangList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';
  bool _hasMoreData = true;
  BuildContext? _context;

  // Filter variables
  List<Gudang> _gudangList = [];
  int? _selectedGudangId;
  String? _dateFrom;
  String? _dateTo;
  String _nomorPo = '';
  String _nomorMutasi = '';
  String _catatan = '';

  // Getters
  List<PenerimaanBarang> get penerimaanBarangList => _penerimaanBarangList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String get searchQuery => _searchQuery;
  bool get hasMoreData => _hasMoreData;
  List<Gudang> get gudangList => _gudangList;
  int? get selectedGudangId => _selectedGudangId;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  String get nomorPo => _nomorPo;
  String get nomorMutasi => _nomorMutasi;
  String get catatan => _catatan;

  /// Set context for session handling
  void setContext(BuildContext context) {
    _context = context;
  }

  // Filter setters
  void setSelectedGudangId(int? value) {
    _selectedGudangId = value;
    notifyListeners();
  }

  void setDateFrom(String? value) {
    _dateFrom = value;
    notifyListeners();
  }

  void setDateTo(String? value) {
    _dateTo = value;
    notifyListeners();
  }

  void setNomorPo(String value) {
    _nomorPo = value;
    notifyListeners();
  }

  void setNomorMutasi(String value) {
    _nomorMutasi = value;
    notifyListeners();
  }

  void setCatatan(String value) {
    _catatan = value;
    notifyListeners();
  }

  void clearFilters() {
    _selectedGudangId = null;
    _dateFrom = null;
    _dateTo = null;
    _nomorPo = '';
    _nomorMutasi = '';
    _catatan = '';
    notifyListeners();
  }

  /// Handle session expired
  Future<void> _handleSessionExpired() async {
    if (_context != null) {
      await AuthHelper.handleSessionExpired(_context!);
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

  /// Load penerimaan barang list from API
  Future<void> loadPenerimaanBarangList({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _penerimaanBarangList.clear();
      _hasMoreData = true;
    }

    if (!_hasMoreData && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        _error = 'Token autentikasi tidak ditemukan. Silakan login kembali.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': _currentPage.toString(),
        'per_page': '10',
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      // Add filter parameters
      if (_dateFrom != null && _dateFrom!.isNotEmpty) {
        queryParams['date_from'] = _dateFrom!;
      }
      if (_dateTo != null && _dateTo!.isNotEmpty) {
        queryParams['date_to'] = _dateTo!;
      }
      if (_selectedGudangId != null) {
        queryParams['gudang'] = _selectedGudangId.toString();
      }
      if (_nomorPo.isNotEmpty) {
        queryParams['nomor_po'] = _nomorPo;
      }
      if (_nomorMutasi.isNotEmpty) {
        queryParams['nomor_mutasi'] = _nomorMutasi;
      }
      if (_catatan.isNotEmpty) {
        queryParams['catatan'] = _catatan;
      }

      final uri = Uri.parse('$baseUrl$apiPath').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final dynamic responseBody = json.decode(response.body);
          
          // Debug: Print response structure (uncomment for debugging)
          // debugPrint('Response type: ${responseBody.runtimeType}');
          // debugPrint('Response body: $responseBody');
          
          // Check if response is a List (direct array) or Map (with pagination)
          if (responseBody is List) {
            // Direct array response
            final List<PenerimaanBarang> items = (responseBody as List)
                .map((item) => PenerimaanBarang.fromMap(item))
                .toList();
            
            if (refresh) {
              _penerimaanBarangList = items;
            } else {
              _penerimaanBarangList.addAll(items);
            }
            
            _currentPage = 1;
            _totalPages = 1;
            _totalItems = items.length;
            _hasMoreData = false;
          } else if (responseBody is Map<String, dynamic>) {
            // Handle different API response formats
            if (responseBody['success'] == true) {
              // Format: {success: true, message: "...", data: [...], pagination: {...}}
              final List<dynamic> dataList = responseBody['data'] ?? [];
              final Map<String, dynamic> pagination = responseBody['pagination'] ?? {};
              
              final List<PenerimaanBarang> items = dataList
                  .where((item) => item is Map<String, dynamic>)
                  .map((item) => PenerimaanBarang.fromMap(item as Map<String, dynamic>))
                  .toList();
              
              if (refresh) {
                _penerimaanBarangList = items;
              } else {
                _penerimaanBarangList.addAll(items);
              }
              
              _currentPage = _parseToInt(pagination['current_page']);
              _totalPages = _parseToInt(pagination['last_page']);
              _totalItems = _parseToInt(pagination['total']);
              _hasMoreData = _currentPage < _totalPages;
            } else {
              // Try original format: {success: true, data: {current_page: 1, data: [...]}}
              final PenerimaanBarangListResponse responseData = PenerimaanBarangListResponse.fromMap(responseBody);
              
              if (responseData.success) {
                if (refresh) {
                  _penerimaanBarangList = responseData.data.data;
                } else {
                  _penerimaanBarangList.addAll(responseData.data.data);
                }
                
                _currentPage = responseData.data.currentPage;
                _totalPages = responseData.data.lastPage;
                _totalItems = responseData.data.total;
                _hasMoreData = responseData.data.nextPageUrl != null;
              } else {
                _error = responseData.message;
              }
            }
          } else {
            _error = 'Format response tidak valid';
          }
        } catch (e) {
          _error = 'Error parsing response: $e';
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        return;
      } else {
        _error = 'Gagal mengambil data penerimaan barang: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data (pagination)
  Future<void> loadMore() async {
    if (!_isLoading && _hasMoreData) {
      _currentPage++;
      await loadPenerimaanBarangList();
    }
  }

  /// Search penerimaan barang
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadPenerimaanBarangList(refresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    await loadPenerimaanBarangList(refresh: true);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadPenerimaanBarangList(refresh: true);
  }

  /// Get penerimaan barang by ID
  Future<PenerimaanBarang?> getPenerimaanBarangById(int id) async {
    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan');
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      final response = await http.get(
        Uri.parse('$baseUrl$apiPath/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          final dynamic responseBody = json.decode(response.body);
          
          if (responseBody is Map<String, dynamic>) {
            final PenerimaanBarangResponse responseData = PenerimaanBarangResponse.fromMap(responseBody);
            
            if (responseData.success) {
              return responseData.data;
            } else {
              throw Exception(responseData.message);
            }
          } else {
            throw Exception('Format response tidak valid');
          }
        } catch (e) {
          throw Exception('Error parsing response: $e');
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        return null;
      } else {
        throw Exception('Gagal mengambil data penerimaan barang: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting penerimaan barang by ID: $e');
      return null;
    }
  }

  /// Submit new penerimaan barang
  Future<PenerimaanBarang?> submitPenerimaanBarang(PenerimaanBarangInput input) async {
    try {
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan');
      }

      // Get API URL from environment
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      final response = await http.post(
        Uri.parse('$baseUrl$apiPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(input.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final dynamic responseBody = json.decode(response.body);
          
          if (responseBody is Map<String, dynamic>) {
            final PenerimaanBarangResponse responseData = PenerimaanBarangResponse.fromMap(responseBody);
            
            if (responseData.success) {
              // Refresh the list after successful submission
              await refresh();
              return responseData.data;
            } else {
              throw Exception(responseData.message);
            }
          } else {
            throw Exception('Format response tidak valid');
          }
        } catch (e) {
          throw Exception('Error parsing response: $e');
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        return null;
      } else {
        throw Exception('Gagal menyimpan data penerimaan barang: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting penerimaan barang: $e');
      rethrow;
    }
  }

  /// Load gudang list for filter
  Future<void> loadGudangList() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return;
      }

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
          _gudangList = gudangResult.data;
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
      }
    } catch (e) {
      debugPrint('Error loading gudang list: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
