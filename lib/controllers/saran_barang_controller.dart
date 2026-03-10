import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/saran_barang_model.dart';
import '../models/ref_jenis_barang_model.dart';
import '../models/ref_bentuk_barang_model.dart';
import '../models/ref_grade_barang_model.dart';
import '../models/tipe_barang_model.dart';
import '../utils/auth_helper.dart';

class SaranBarangController extends ChangeNotifier {
  List<SaranBarangResponse> _saranList = [];
  List<RefJenisBarang> _jenisBarangList = [];
  List<RefBentukBarang> _bentukBarangList = [];
  List<RefGradeBarang> _gradeBarangList = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _total = 0;
  double _totalSisaQuantity = 0.0;

  // Request State
  SaranBarangRequest _request = SaranBarangRequest();
  SaranBarangRequest get request => _request;

  // Selected TipeBarang logic
  TipeBarang? _selectedTipeBarang;
  TipeBarang? get selectedTipeBarang => _selectedTipeBarang;

  // Getters
  List<SaranBarangResponse> get saranList => _saranList;
  List<RefJenisBarang> get jenisBarangList => _jenisBarangList;
  List<RefBentukBarang> get bentukBarangList => _bentukBarangList;
  List<RefGradeBarang> get gradeBarangList => _gradeBarangList;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  double get totalSisaQuantity => _totalSisaQuantity;
  bool get hasMoreData => _currentPage < _lastPage;

  Future<void> loadReferenceData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.wait([
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
      }
    } catch (e) {
      debugPrint('Error loading grade barang list: $e');
    }
  }

  void updateRequest({
    int? jenisBarangId,
    int? bentukBarangId,
    int? gradeBarangId,
    String? jenisPotongan,
    double? tebal,
    double? panjang,
    double? lebar,
    double? diameterLuar,
    double? diameterDalam,
    double? diameter,
    double? sisi1,
    double? sisi2,
  }) {
    _request = SaranBarangRequest(
      jenisBarangId: jenisBarangId ?? _request.jenisBarangId,
      bentukBarangId: bentukBarangId ?? _request.bentukBarangId,
      gradeBarangId: gradeBarangId ?? _request.gradeBarangId,
      jenisPotongan: jenisPotongan ?? _request.jenisPotongan,
      tebal: tebal ?? _request.tebal,
      panjang: panjang ?? _request.panjang,
      lebar: lebar ?? _request.lebar,
      diameterLuar: diameterLuar ?? _request.diameterLuar,
      diameterDalam: diameterDalam ?? _request.diameterDalam,
      diameter: diameter ?? _request.diameter,
      sisi1: sisi1 ?? _request.sisi1,
      sisi2: sisi2 ?? _request.sisi2,
      page: _request.page,
    );

    if (bentukBarangId != null) {
      _updateSelectedTipeBarang(bentukBarangId);
    }
    notifyListeners();
  }

  void _updateSelectedTipeBarang(int bentukId) {
    try {
      final bentuk = _bentukBarangList.firstWhere(
        (b) => b.id == bentukId,
      );
      _selectedTipeBarang = bentuk.tipeBarang;
      
      // Reset values if they are no longer supported by this tipeBarang
      if (_selectedTipeBarang != null) {
        _request = SaranBarangRequest(
          jenisBarangId: _request.jenisBarangId,
          bentukBarangId: _request.bentukBarangId,
          gradeBarangId: _request.gradeBarangId,
          jenisPotongan: _request.jenisPotongan,
          tebal: _selectedTipeBarang!.tebal ? _request.tebal : null,
          panjang: _selectedTipeBarang!.panjang ? _request.panjang : null,
          lebar: _selectedTipeBarang!.lebar ? _request.lebar : null,
          diameter: _selectedTipeBarang!.diameter ? _request.diameter : null,
          diameterLuar: _selectedTipeBarang!.diameterLuar ? _request.diameterLuar : null,
          diameterDalam: _selectedTipeBarang!.diameterDalam ? _request.diameterDalam : null,
          sisi1: _selectedTipeBarang!.sisi1 ? _request.sisi1 : null,
          sisi2: _selectedTipeBarang!.sisi2 ? _request.sisi2 : null,
          page: _request.page,
        );
      }
    } catch (e) {
      _selectedTipeBarang = null;
    }
  }

  void clearRequest() {
    _request = SaranBarangRequest(
      jenisBarangId: _request.jenisBarangId,
      bentukBarangId: _request.bentukBarangId,
      gradeBarangId: _request.gradeBarangId,
      jenisPotongan: _request.jenisPotongan,
    );
    _saranList = [];
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> fetchSaranBarang(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _saranList = [];
    }

    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      request.page = _currentPage;
      request.perPage = _perPage;

      final url = Uri.parse('$baseUrl/api/work-order-planning/get-saran-plat-dasar');

      final payload = request.toJson();
      // Debug payload
      debugPrint('Saran Barang Request Payload: ${json.encode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];

          if (responseData is List) {
            final List<SaranBarangResponse> newItems = responseData
                .map((item) => SaranBarangResponse.fromJson(item as Map<String, dynamic>))
                .toList();

            if (loadMore) {
              _saranList.addAll(newItems);
            } else {
              _saranList = newItems;
            }

            if (data['pagination'] != null) {
              _currentPage = data['pagination']['current_page'] ?? 1;
              _lastPage = data['pagination']['last_page'] ?? 1;
              _total = data['pagination']['total'] ?? newItems.length;
            } else {
              _currentPage = 1;
              _lastPage = 1;
              _total = newItems.length;
            }

            if (data['summary'] != null) {
              _totalSisaQuantity = SaranBarangResponse.parseDouble(data['summary']['total_sisa_quantity']);
            } else {
              _totalSisaQuantity = 0.0;
            }
          }
        } else {
           // Success false but code 200
           _errorMessage = data['message'] ?? 'Data tidak ditemukan';
           if (!loadMore) _saranList = [];
        }
      } else if (response.statusCode == 401) {
        await AuthHelper.handleUnauthorized(context, null);
        return;
      } else if (response.statusCode == 404) {
        if (!loadMore) {
          _saranList = [];
        }
        _errorMessage = 'Data tidak ditemukan';
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Input tidak valid';
      } else {
        _errorMessage = 'Error server: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Fetch Saran Barang Error: $e');
      _errorMessage = 'Terjadi kesalahan sistem';
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadMoreSaran(BuildContext context) async {
    if (hasMoreData && !_isLoadingMore) {
      _currentPage++;
      await fetchSaranBarang(context, loadMore: true);
    }
  }
}
