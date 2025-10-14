import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/penerimaan_barang_model.dart';
import '../utils/auth_helper.dart';

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

  // Getters
  List<PenerimaanBarang> get penerimaanBarangList => _penerimaanBarangList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String get searchQuery => _searchQuery;
  bool get hasMoreData => _hasMoreData;

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
              
              _currentPage = pagination['current_page'] ?? 1;
              _totalPages = pagination['last_page'] ?? 1;
              _totalItems = pagination['total'] ?? 0;
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
