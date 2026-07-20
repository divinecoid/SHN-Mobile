import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/invoice_pod_model.dart';
import '../models/work_order_planning_model.dart';
import '../utils/auth_helper.dart';

class InvoicePodController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<InvoicePodModel> _invoicePods = [];
  Pagination? _pagination;

  // Filters
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<InvoicePodModel> get invoicePods => _invoicePods;
  Pagination? get pagination => _pagination;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  double get totalNilai => _invoicePods.fold(0.0, (sum, item) => sum + (double.tryParse(item.grandTotal) ?? 0.0));
  int get totalCount => _invoicePods.length;

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    notifyListeners();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchInvoicePods({int page = 1, BuildContext? context}) async {
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

      if (_startDate != null) {
        queryParams['tanggal_invoice_start'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      }
      if (_endDate != null) {
        queryParams['tanggal_invoice_end'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      final uri = Uri.parse('$baseUrl/api/invoice-pod/report').replace(queryParameters: queryParams);
      
      debugPrint('Fetching invoice pods from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Invoice Pod Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // standard Laravel pagination response
        final data = responseData['data'] ?? responseData;
        List<dynamic> itemsList = [];
        
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) {
            itemsList = data['data'] as List<dynamic>;
          }
          _pagination = Pagination.fromMap(data);
        } else if (data is List<dynamic>) {
          itemsList = data;
          _pagination = null;
        }

        if (page == 1) {
          _invoicePods = itemsList.map((x) => InvoicePodModel.fromMap(x as Map<String, dynamic>)).toList();
        } else {
          _invoicePods.addAll(itemsList.map((x) => InvoicePodModel.fromMap(x as Map<String, dynamic>)).toList());
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
      debugPrint('Error fetching Invoice Pods: $e');
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
