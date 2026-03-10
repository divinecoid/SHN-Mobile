import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/penerimaan_barang_model.dart';
import '../utils/auth_helper.dart';
import '../services/printer_service.dart';

class ProsesNonPoController extends ChangeNotifier {
  BuildContext? _context;
  
  // Data for Pending tab
  List<PenerimaanBarangDetail> _pendingList = [];
  bool _isLoadingPending = false;
  String? _errorPending;

  // Data for Processed (Selesai) tab
  List<PenerimaanBarangDetail> _processedList = [];
  bool _isLoadingProcessed = false;
  String? _errorProcessed;

  // Submit process state
  bool _isSubmitLoading = false;
  String? _errorSubmit;

  // Pagination for Pending
  int _currentPendingPage = 1;
  int _lastPendingPage = 1;
  bool _hasMorePending = false;
  bool _isLoadingMorePending = false;

  // Pagination for Processed
  int _currentProcessedPage = 1;
  int _lastProcessedPage = 1;
  bool _hasMoreProcessed = false;
  bool _isLoadingMoreProcessed = false;

  // Selected for printing
  final Set<int> _selectedProcessedIds = {};

  // Search
  String _searchQuery = '';

  // Getters
  List<PenerimaanBarangDetail> get pendingList => _pendingList;
  bool get isLoadingPending => _isLoadingPending;
  String? get errorPending => _errorPending;
  bool get hasMorePending => _hasMorePending;

  List<PenerimaanBarangDetail> get processedList => _processedList;
  bool get isLoadingProcessed => _isLoadingProcessed;
  String? get errorProcessed => _errorProcessed;
  bool get hasMoreProcessed => _hasMoreProcessed;

  bool get isSubmitLoading => _isSubmitLoading;
  String? get errorSubmit => _errorSubmit;
  String get searchQuery => _searchQuery;

  Set<int> get selectedProcessedIds => _selectedProcessedIds;
  List<PenerimaanBarangDetail> get selectedProcessedItems {
    return _processedList.where((item) => _selectedProcessedIds.contains(item.id)).toList();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  void _handleUnauthorized() {
    if (_context != null) {
      AuthHelper.handleUnauthorized(_context!, null);
    }
  }

  Future<void> loadPendingList({bool refresh = false}) async {
    if (refresh) {
      _currentPendingPage = 1;
      _pendingList = [];
      _isLoadingPending = true;
      _errorPending = null;
      notifyListeners();
    } else {
      if (!_hasMorePending || _isLoadingMorePending) return;
      _isLoadingMorePending = true;
      _currentPendingPage++;
      notifyListeners();
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Sesi telah berakhir, silakan login kembali.');
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      final queryParams = <String, String>{
        'page': _currentPendingPage.toString(),
        'per_page': '15',
      };
      
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final uri = Uri.parse('$baseUrl$apiPath/pending-nonpo').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'] as List;
          final List<PenerimaanBarangDetail> newItems = data
              .map((item) => PenerimaanBarangDetail.fromMap(item))
              .toList();

          if (refresh) {
            _pendingList = newItems;
          } else {
            _pendingList.addAll(newItems);
          }

          _lastPendingPage = responseData['pagination']?['last_page'] ?? 1;
          _hasMorePending = _currentPendingPage < _lastPendingPage;
          _errorPending = null;
        } else {
          _errorPending = responseData['message'] ?? 'Gagal memuat data pending.';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        _errorPending = 'Sesi telah berakhir, silakan login kembali.';
      } else {
        _errorPending = 'Gagal memuat data pending (Status ${response.statusCode})';
      }
    } catch (e) {
      _errorPending = 'Terjadi kesalahan sistem: $e';
    } finally {
      if (refresh) {
        _isLoadingPending = false;
      } else {
        _isLoadingMorePending = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadProcessedList({bool refresh = false}) async {
    if (refresh) {
      _currentProcessedPage = 1;
      _processedList = [];
      _isLoadingProcessed = true;
      _errorProcessed = null;
      notifyListeners();
    } else {
      if (!_hasMoreProcessed || _isLoadingMoreProcessed) return;
      _isLoadingMoreProcessed = true;
      _currentProcessedPage++;
      notifyListeners();
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Sesi telah berakhir, silakan login kembali.');
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      final queryParams = <String, String>{
        'page': _currentProcessedPage.toString(),
        'per_page': '15',
      };
      
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final uri = Uri.parse('$baseUrl$apiPath/processed-nonpo').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'] as List;
          final List<PenerimaanBarangDetail> newItems = data
              .map((item) => PenerimaanBarangDetail.fromMap(item))
              .toList();

          if (refresh) {
            _processedList = newItems;
          } else {
            _processedList.addAll(newItems);
          }

          _lastProcessedPage = responseData['pagination']?['last_page'] ?? 1;
          _hasMoreProcessed = _currentProcessedPage < _lastProcessedPage;
          _errorProcessed = null;
        } else {
          _errorProcessed = responseData['message'] ?? 'Gagal memuat data diproses.';
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        _errorProcessed = 'Sesi telah berakhir, silakan login kembali.';
      } else {
        _errorProcessed = 'Gagal memuat data diproses (Status ${response.statusCode})';
      }
    } catch (e) {
      _errorProcessed = 'Terjadi kesalahan sistem: $e';
    } finally {
      if (refresh) {
        _isLoadingProcessed = false;
      } else {
        _isLoadingMoreProcessed = false;
      }
      notifyListeners();
    }
  }

  Future<bool> submitProcessNonPo(int detailId, double hargaModal, double berat) async {
    _isSubmitLoading = true;
    _errorSubmit = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _errorSubmit = 'Sesi telah berakhir, silakan login kembali.';
        notifyListeners();
        return false;
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final String apiPath = dotenv.env['API_PENERIMAAN_BARANG'] ?? '/api/penerimaan-barang';
      
      final uri = Uri.parse('$baseUrl$apiPath/process-nonpo/$detailId');
      
      final body = json.encode({
        'harga_modal': hargaModal,
        'berat': berat,
      });

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return true;
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        _errorSubmit = 'Sesi telah berakhir, silakan login kembali.';
        notifyListeners();
        return false;
      } else {
        _errorSubmit = responseData['message'] ?? 'Gagal memproses item (Status ${response.statusCode})';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorSubmit = "Terjadi kesalahan sistem: $e";
      notifyListeners();
      return false;
    } finally {
      _isSubmitLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // Selection Logic
  // -------------------------

  void toggleSelection(int id) {
    if (_selectedProcessedIds.contains(id)) {
      _selectedProcessedIds.remove(id);
    } else {
      _selectedProcessedIds.add(id);
    }
    notifyListeners();
  }

  void toggleAllSelection(bool isSelected) {
    if (isSelected) {
      _selectedProcessedIds.addAll(_processedList.map((e) => e.id));
    } else {
      for (var item in _processedList) {
        _selectedProcessedIds.remove(item.id);
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedProcessedIds.clear();
    notifyListeners();
  }

  bool get isAllSelected {
    if (_processedList.isEmpty) return false;
    return _processedList.every((item) => _selectedProcessedIds.contains(item.id));
  }

  // -------------------------
  // Printing Logic
  // -------------------------

  Future<void> printSingleQR(PenerimaanBarangDetail detail, int copies) async {
    try {
      final printer = PrinterService();
      await printer.printItemQR(detail, copies: copies);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printBatchQR(int copies) async {
    if (_selectedProcessedIds.isEmpty) return;
    try {
      final itemsToPrint = selectedProcessedItems;
      final printer = PrinterService();
      await printer.printBatchQR(itemsToPrint, copies: copies);
      clearSelection();
    } catch (e) {
      rethrow;
    }
  }

  void refreshAll() {
    loadPendingList(refresh: true);
    loadProcessedList(refresh: true);
  }
}
