import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/work_order_planning_model.dart';
import '../models/gudang_model.dart' as gudang_model;
import '../utils/auth_helper.dart';

class WorkOrderController extends ChangeNotifier {
  // State management
  bool _isLoading = false;
  String? _errorMessage;
  List<WorkOrderPlanning> _workOrders = [];
  Pagination? _pagination;

  // Filter variables
  List<gudang_model.Gudang> _gudangList = [];
  String? _tanggalWoFrom;
  String? _tanggalWoTo;
  String _nomorWo = '';
  String _nomorSo = '';
  String _namaCustomer = '';
  int? _selectedGudangId;
  String? _selectedStatus;
  int? _jumlahItem;
  int? _jumlahItemMin;
  int? _jumlahItemMax;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WorkOrderPlanning> get workOrders => _workOrders;
  Pagination? get pagination => _pagination;
  List<gudang_model.Gudang> get gudangList => _gudangList;
  String? get tanggalWoFrom => _tanggalWoFrom;
  String? get tanggalWoTo => _tanggalWoTo;
  String get nomorWo => _nomorWo;
  String get nomorSo => _nomorSo;
  String get namaCustomer => _namaCustomer;
  int? get selectedGudangId => _selectedGudangId;
  String? get selectedStatus => _selectedStatus;
  int? get jumlahItem => _jumlahItem;
  int? get jumlahItemMin => _jumlahItemMin;
  int? get jumlahItemMax => _jumlahItemMax;
  
  // Legacy getter untuk kompatibilitas dengan UI yang lama
  List<Map<String, String>> get getWorkOrders {
    return _workOrders.map((wo) => {
      'noWO': wo.nomorWo,
      'noSO': wo.salesOrder?.nomorSo ?? '',
      'customerName': wo.pelanggan?.namaPelanggan ?? '',
      'warehouse': wo.gudang?.namaGudang ?? '',
      'status': wo.status,
    }).toList();
  }

  // Method untuk mengambil token dari SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  // Method untuk fetch work order planning dari API
  Future<void> fetchWorkOrderPlanning({
    int page = 1,
    int perPage = 100,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final workOrderEndpoint = dotenv.env['API_LIST_WO'] ?? '/api/work-order-planning';
      final url = Uri.parse('$baseUrl$workOrderEndpoint');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Add filter parameters
      if (_tanggalWoFrom != null && _tanggalWoFrom!.isNotEmpty) {
        queryParams['tanggal_wo_from'] = _tanggalWoFrom!;
      }
      if (_tanggalWoTo != null && _tanggalWoTo!.isNotEmpty) {
        queryParams['tanggal_wo_to'] = _tanggalWoTo!;
      }
      if (_nomorWo.isNotEmpty) {
        queryParams['nomor_wo'] = _nomorWo;
      }
      if (_nomorSo.isNotEmpty) {
        queryParams['nomor_so'] = _nomorSo;
      }
      if (_namaCustomer.isNotEmpty) {
        queryParams['nama_customer'] = _namaCustomer;
      }
      if (_selectedGudangId != null) {
        queryParams['gudang'] = _selectedGudangId.toString();
      }
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        queryParams['status'] = _selectedStatus!;
      }
      if (_jumlahItem != null) {
        queryParams['jumlah_item'] = _jumlahItem.toString();
      } else {
        if (_jumlahItemMin != null) {
          queryParams['jumlah_item_min'] = _jumlahItemMin.toString();
        }
        if (_jumlahItemMax != null) {
          queryParams['jumlah_item_max'] = _jumlahItemMax.toString();
        }
      }

      final finalUrl = url.replace(queryParameters: queryParams);
      
      // Debug: Print URL being used
      debugPrint('Work Order URL: $finalUrl');

      final response = await http.get(
        finalUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Debug: Print response details
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final workOrderResponse = WorkOrderPlanningListResponse.fromMap(jsonData);
        
        if (workOrderResponse.success) {
          _workOrders = workOrderResponse.data;
          _pagination = workOrderResponse.pagination;
          _errorMessage = null;
        } else {
          throw Exception(workOrderResponse.message);
        }
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching work orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk refresh data
  Future<void> refreshData({BuildContext? context}) async {
    await fetchWorkOrderPlanning(context: context);
  }

  // Method untuk load more data (pagination)
  Future<void> loadMoreData() async {
    if (_pagination != null && 
        _pagination!.currentPage < _pagination!.lastPage && 
        !_isLoading) {
      await fetchWorkOrderPlanning(page: _pagination!.currentPage + 1);
    }
  }

  // Method untuk mendapatkan warna status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[400]!;
      case 'planning':
        return Colors.orange[400]!;
      case 'actual':
      case 'on progress':
        return Colors.blue[400]!;
      case 'selesai':
        return Colors.green[400]!;
      case 'cancelled':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  // Method untuk mendapatkan text button berdasarkan status
  String getButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'planning':
        return 'Set Actual';
      case 'actual':
      case 'in_progress':
        return 'Edit Actual';
      case 'completed':
        return 'Lihat Detail';
      default:
        return 'Lihat Detail';
    }
  }

  // Method untuk mendapatkan mode edit berdasarkan status
  bool getEditMode(String status) {
    return status.toLowerCase() == 'actual' || status.toLowerCase() == 'in_progress';
  }

  // Filter setters
  void setTanggalWoFrom(String? value) {
    _tanggalWoFrom = value;
    notifyListeners();
  }

  void setTanggalWoTo(String? value) {
    _tanggalWoTo = value;
    notifyListeners();
  }

  void setNomorWo(String value) {
    _nomorWo = value;
    notifyListeners();
  }

  void setNomorSo(String value) {
    _nomorSo = value;
    notifyListeners();
  }

  void setNamaCustomer(String value) {
    _namaCustomer = value;
    notifyListeners();
  }

  void setSelectedGudangId(int? value) {
    _selectedGudangId = value;
    notifyListeners();
  }

  void setSelectedStatus(String? value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void setJumlahItem(int? value) {
    _jumlahItem = value;
    notifyListeners();
  }

  void setJumlahItemMin(int? value) {
    _jumlahItemMin = value;
    notifyListeners();
  }

  void setJumlahItemMax(int? value) {
    _jumlahItemMax = value;
    notifyListeners();
  }

  void clearFilters() {
    _tanggalWoFrom = null;
    _tanggalWoTo = null;
    _nomorWo = '';
    _nomorSo = '';
    _namaCustomer = '';
    _selectedGudangId = null;
    _selectedStatus = null;
    _jumlahItem = null;
    _jumlahItemMin = null;
    _jumlahItemMax = null;
    notifyListeners();
  }

  // Method untuk clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method untuk clear data
  void clearData() {
    _workOrders.clear();
    _pagination = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Method untuk mengambil detail work order planning berdasarkan ID
  Future<WorkOrderPlanning?> fetchWorkOrderPlanningDetail(int id, {BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final workOrderDetailEndpoint = dotenv.env['API_DETAIL_WO'] ?? '/api/work-order-planning';
      
      // Build URL with query parameter directly in string
      final urlString = '$baseUrl$workOrderDetailEndpoint/$id?create_actual=true';
      debugPrint('URL String before parse: $urlString');
      
      final url = Uri.parse(urlString);
      
      // Debug: Print URL being used
      debugPrint('Work Order Detail URL: $url');
      debugPrint('URL toString: ${url.toString()}');
      debugPrint('Query Parameters: create_actual=true');
      debugPrint('Has query: ${url.hasQuery}');
      debugPrint('Query string: ${url.query}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Debug: Print response details
      debugPrint('Detail Response Status Code: ${response.statusCode}');
      debugPrint('Detail Response Body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final workOrderResponse = WorkOrderPlanningResult.fromMap(jsonData);
        
        if (workOrderResponse.success) {
          _errorMessage = null;
          return workOrderResponse.data;
        } else {
          throw Exception(workOrderResponse.message);
        }
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Work Order tidak ditemukan.');
      } else {
        throw Exception('Gagal mengambil data detail: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching work order detail: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
        final gudang_model.GudangResult gudangResult = gudang_model.GudangResult.fromMap(jsonData);
        
        if (gudangResult.success) {
          _gudangList = gudangResult.data;
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized when loading gudang list');
      }
    } catch (e) {
      debugPrint('Error loading gudang list: $e');
    }
  }
}
