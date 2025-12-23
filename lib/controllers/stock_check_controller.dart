import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/stock_check_model.dart';
import '../models/ref_gudang_model.dart';
import '../models/ref_jenis_barang_model.dart';
import '../models/ref_bentuk_barang_model.dart';
import '../models/ref_grade_barang_model.dart';
import '../utils/auth_helper.dart';

class StockCheckController extends ChangeNotifier {
  List<StockCheckItem> _stockItems = [];
  List<RefGudang> _gudangList = [];
  List<RefJenisBarang> _jenisBarangList = [];
  List<RefBentukBarang> _bentukBarangList = [];
  List<RefGradeBarang> _gradeBarangList = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  
  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 20; // Items per page
  int _total = 0;
  
  // Filter values
  int? _selectedGudangId;
  int? _selectedJenisBarangId;
  int? _selectedBentukBarangId;
  int? _selectedGradeBarangId;
  double? _panjang;
  double? _lebar;
  double? _tebal;

  // Getters
  List<StockCheckItem> get stockItems => _stockItems;
  List<RefGudang> get gudangList => _gudangList;
  List<RefJenisBarang> get jenisBarangList => _jenisBarangList;
  List<RefBentukBarang> get bentukBarangList => _bentukBarangList;
  List<RefGradeBarang> get gradeBarangList => _gradeBarangList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasMoreData => _currentPage < _lastPage;
  
  int? get selectedGudangId => _selectedGudangId;
  int? get selectedJenisBarangId => _selectedJenisBarangId;
  int? get selectedBentukBarangId => _selectedBentukBarangId;
  int? get selectedGradeBarangId => _selectedGradeBarangId;
  double? get panjang => _panjang;
  double? get lebar => _lebar;
  double? get tebal => _tebal;

  // Setters for filters
  void setSelectedGudangId(int? value) {
    _selectedGudangId = value;
    notifyListeners();
  }

  void setSelectedJenisBarangId(int? value) {
    _selectedJenisBarangId = value;
    notifyListeners();
  }

  void setSelectedBentukBarangId(int? value) {
    _selectedBentukBarangId = value;
    notifyListeners();
  }

  void setSelectedGradeBarangId(int? value) {
    _selectedGradeBarangId = value;
    notifyListeners();
  }

  void setPanjang(double? value) {
    _panjang = value;
    notifyListeners();
  }

  void setLebar(double? value) {
    _lebar = value;
    notifyListeners();
  }

  void setTebal(double? value) {
    _tebal = value;
    notifyListeners();
  }

  void clearFilters() {
    _selectedGudangId = null;
    _selectedJenisBarangId = null;
    _selectedBentukBarangId = null;
    _selectedGradeBarangId = null;
    _panjang = null;
    _lebar = null;
    _tebal = null;
    _stockItems = [];
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    notifyListeners();
  }

  Future<void> loadReferenceData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.wait([
        _loadGudangList(),
        _loadJenisBarangList(),
        _loadBentukBarangList(),
        _loadGradeBarangList(),
      ]);
    } catch (e) {
      _errorMessage = 'Error loading reference data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGudangList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/gudang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _gudangList = (data['data'] as List)
              .map((item) => RefGudang.fromJson(item))
              .toList();
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        throw Exception('Unauthorized');
      }
    } catch (e) {
      debugPrint('Error loading gudang list: $e');
    }
  }

  Future<void> _loadJenisBarangList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/jenis-barang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _jenisBarangList = (data['data'] as List)
              .map((item) => RefJenisBarang.fromJson(item))
              .toList();
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        throw Exception('Unauthorized');
      }
    } catch (e) {
      debugPrint('Error loading jenis barang list: $e');
    }
  }

  Future<void> _loadBentukBarangList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/bentuk-barang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _bentukBarangList = (data['data'] as List)
              .map((item) => RefBentukBarang.fromJson(item))
              .toList();
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        throw Exception('Unauthorized');
      }
    } catch (e) {
      debugPrint('Error loading bentuk barang list: $e');
    }
  }

  Future<void> _loadGradeBarangList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/grade-barang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _gradeBarangList = (data['data'] as List)
              .map((item) => RefGradeBarang.fromJson(item))
              .toList();
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        throw Exception('Unauthorized');
      }
    } catch (e) {
      debugPrint('Error loading grade barang list: $e');
    }
  }

  Future<void> checkStock(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _stockItems = [];
    }
    
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      // Build query parameters
      final Map<String, String> queryParams = {};
      
      // Pagination parameters
      queryParams['page'] = _currentPage.toString();
      queryParams['per_page'] = _perPage.toString();
      
      // Filter parameters
      if (_selectedGudangId != null) {
        queryParams['gudang_id'] = _selectedGudangId.toString();
      }
      if (_selectedJenisBarangId != null) {
        queryParams['jenis_barang_id'] = _selectedJenisBarangId.toString();
      }
      if (_selectedBentukBarangId != null) {
        queryParams['bentuk_barang_id'] = _selectedBentukBarangId.toString();
      }
      if (_selectedGradeBarangId != null) {
        queryParams['grade_barang_id'] = _selectedGradeBarangId.toString();
      }
      if (_panjang != null) {
        queryParams['panjang'] = _panjang.toString();
      }
      if (_lebar != null) {
        queryParams['lebar'] = _lebar.toString();
      }
      if (_tebal != null) {
        queryParams['tebal'] = _tebal.toString();
      }

      final uri = Uri.parse('$baseUrl/api/stock/check').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Handle Laravel pagination response
          final paginationData = data['data'];
          
          // Parse stock items
          final List<StockCheckItem> newItems = (paginationData['data'] as List)
              .map((item) => StockCheckItem.fromJson(item))
              .toList();
          
          // Update pagination info
          _currentPage = paginationData['current_page'] ?? 1;
          _lastPage = paginationData['last_page'] ?? 1;
          _total = paginationData['total'] ?? 0;
          
          if (loadMore) {
            _stockItems.addAll(newItems);
          } else {
            _stockItems = newItems;
          }
        } else {
          _errorMessage = data['message'] ?? 'Error loading stock data';
        }
      } else if (response.statusCode == 401) {
        await AuthHelper.handleUnauthorized(context, null);
        return;
      } else if (response.statusCode == 404) {
        if (!loadMore) {
          _stockItems = [];
        }
        _errorMessage = 'Data tidak ditemukan';
      } else {
        _errorMessage = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadMoreStock(BuildContext context) async {
    if (hasMoreData && !_isLoadingMore) {
      _currentPage++;
      await checkStock(context, loadMore: true);
    }
  }

  Future<String?> fetchCanvasImage(int idItemBarang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/item-barang/$idItemBarang/canvas-image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['canvas_image'] as String?;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        return null; // Canvas image tidak ditemukan
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching canvas image: $e');
      return null;
    }
  }
}
