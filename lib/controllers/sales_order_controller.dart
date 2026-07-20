import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/work_order_planning_model.dart';
import '../models/gudang_model.dart' as gm;
import '../utils/auth_helper.dart';

class SalesOrderController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<SalesOrder> _salesOrders = [];
  Pagination? _pagination;

  // Filters
  String _searchQuery = '';
  String? _selectedStatus; // 'pending', 'partial_wo', 'full_wo'

  // Detail page states
  SalesOrder? _selectedSalesOrder;
  List<dynamic> _selectedSalesOrderItems = [];
  bool _isLoadingDetail = false;
  String? _errorDetail;

  // Getters for List Page
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SalesOrder> get salesOrders => _salesOrders;
  Pagination? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;

  // Getters for Detail Page
  SalesOrder? get selectedSalesOrder => _selectedSalesOrder;
  List<dynamic> get selectedSalesOrderItems => _selectedSalesOrderItems;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorDetail => _errorDetail;

  // Setters & Filter Handlers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _selectedSalesOrder = null;
    _selectedSalesOrderItems = [];
    _errorDetail = null;
    notifyListeners();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchSalesOrderDetail(int id) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    _selectedSalesOrder = null;
    _selectedSalesOrderItems = [];
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _errorDetail = 'Sesi telah berakhir. Silakan login kembali.';
        _isLoadingDetail = false;
        notifyListeners();
        return;
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final uri = Uri.parse('$baseUrl/api/sales-order/$id');
      
      debugPrint('Fetching sales order detail from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Sales Order Detail Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Handle response wrapping (standard API might return it inside a 'data' key or directly)
        final data = responseData['data'] ?? responseData;
        
        _selectedSalesOrder = SalesOrder.fromMap(data as Map<String, dynamic>);
        
        // Mapped items
        final itemsData = data['sales_order_items'] ?? data['salesOrderItems'] ?? data['items'] ?? [];
        _selectedSalesOrderItems = itemsData as List<dynamic>;
      } else {
        _errorDetail = 'Gagal mengambil detail Sales Order. Status code: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching Sales Order Detail: $e');
      _errorDetail = 'Terjadi kesalahan: $e';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesOrders({int page = 1, BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
        _isLoading = false;
        notifyListeners();
        if (context != null) {
          AuthHelper.logout(context);
        }
        return;
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': '15',
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_selectedStatus != null && _selectedStatus != 'all') {
        queryParams['process_status'] = _selectedStatus!;
      }

      final uri = Uri.parse('$baseUrl/api/sales-order').replace(queryParameters: queryParams);
      
      debugPrint('Fetching sales orders from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Sales Order Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          
          List<dynamic> itemsList = [];
          if (data is Map<String, dynamic> && data['data'] != null) {
            itemsList = data['data'] as List<dynamic>;
            _pagination = Pagination.fromMap(data);
          } else if (data is List<dynamic>) {
            itemsList = data;
            _pagination = null;
          }

          if (page == 1) {
            _salesOrders = itemsList.map((x) => SalesOrder.fromMap(x as Map<String, dynamic>)).toList();
          } else {
            _salesOrders.addAll(itemsList.map((x) => SalesOrder.fromMap(x as Map<String, dynamic>)).toList());
          }
        } else {
          _errorMessage = responseData['message'] ?? 'Gagal mengambil data Sales Order';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
        if (context != null) {
          AuthHelper.logout(context);
        }
      } else {
        _errorMessage = 'Gagal mengambil data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching Sales Orders: $e');
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
