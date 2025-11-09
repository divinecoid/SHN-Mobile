import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_opname_model.dart';
import '../utils/auth_helper.dart';

class StockOpnameListController extends ChangeNotifier {
  List<StockOpname> _stockOpnameList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';
  bool _hasMoreData = true;
  BuildContext? _context;

  // Getters
  List<StockOpname> get stockOpnameList => _stockOpnameList;
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

  /// Load stock opname list from API
  Future<void> loadStockOpnameList({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _stockOpnameList.clear();
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
      final String apiPath = dotenv.env['API_STOCK_OPNAME'] ?? '/api/stock-opname';
      
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': _currentPage.toString(),
        'per_page': '100',
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
          final Map<String, dynamic> responseBody = json.decode(response.body);
          
          if (responseBody['success'] == true) {
            final StockOpnameResult result = StockOpnameResult.fromMap(responseBody);
            
            if (refresh) {
              _stockOpnameList = result.data;
            } else {
              _stockOpnameList.addAll(result.data);
            }
            
            if (result.pagination != null) {
              _currentPage = result.pagination!.currentPage;
              _totalPages = result.pagination!.lastPage;
              _totalItems = result.pagination!.total;
              _hasMoreData = _currentPage < _totalPages;
            } else {
              _hasMoreData = false;
            }
            
            _error = null;
          } else {
            _error = responseBody['message'] as String? ?? 'Gagal memuat data';
          }
        } catch (e) {
          _error = 'Gagal memproses data: $e';
          debugPrint('Error parsing response: $e');
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
        return;
      } else {
        _error = 'Gagal mengambil data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      debugPrint('Error loading stock opname list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data (pagination)
  Future<void> loadMore() async {
    if (!_hasMoreData || _isLoading) return;
    
    _currentPage++;
    await loadStockOpnameList(refresh: false);
  }

  /// Refresh list
  Future<void> refresh() async {
    await loadStockOpnameList(refresh: true);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Search stock opname
  Future<void> search() async {
    await loadStockOpnameList(refresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

