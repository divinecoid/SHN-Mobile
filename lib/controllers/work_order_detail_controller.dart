import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/work_order_planning_model.dart';
import '../models/pelaksana_model.dart';

class WorkOrderDetailController extends ChangeNotifier {
  List<WorkOrderPlanningItem> _workOrderItems = [];
  WorkOrderPlanning? _workOrderPlanning;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Data pelaksana
  List<Pelaksana> _availablePelaksana = [];
  bool _isLoadingPelaksana = false;
  String? _pelaksanaErrorMessage;

  // Getter untuk mendapatkan data work order items
  List<Map<String, dynamic>> get getWorkOrderItems {
    return _workOrderItems.map((item) => _convertItemToMap(item)).toList();
  }

  // Getter untuk mendapatkan data work order planning
  WorkOrderPlanning? get workOrderPlanning => _workOrderPlanning;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Getter untuk data pelaksana
  List<Pelaksana> get availablePelaksana => _availablePelaksana;
  bool get isLoadingPelaksana => _isLoadingPelaksana;
  String? get pelaksanaErrorMessage => _pelaksanaErrorMessage;

  // Method untuk mengkonversi WorkOrderPlanningItem ke Map untuk UI
  Map<String, dynamic> _convertItemToMap(WorkOrderPlanningItem item) {
    // Hitung ukuran dari panjang, lebar, tebal
    final ukuran = '${item.panjang} x ${item.lebar} x ${item.tebal}';
    
    // Hitung luas dari panjang x lebar
    final luas = double.tryParse(item.panjang) != null && double.tryParse(item.lebar) != null
        ? (double.parse(item.panjang) * double.parse(item.lebar))
        : null;

    return {
      'id': item.id, // ID work order planning item
      'jenisBarang': item.jenisBarang?.namaJenis ?? _getJenisBarangName(item.jenisBarangId),
      'bentukBarang': item.bentukBarang?.namaBentuk ?? _getBentukBarangName(item.bentukBarangId),
      'grade': item.gradeBarang?.nama ?? _getGradeBarangName(item.gradeBarangId),
      'ukuran': ukuran,
      'panjang': item.panjang,
      'lebar': item.lebar,
      'tebal': item.tebal,
      'qtyPlanning': item.qty,
      'qtyActual': null, // Akan diisi dari data actual jika ada
      'beratPlanning': double.tryParse(item.berat) ?? 0.0,
      'beratActual': null, // Akan diisi dari data actual jika ada
      'luas': luas,
      'platShaftDasar': null ?? 'N/A',
      'catatan': item.catatan ?? 'N/A',
      'satuan': item.satuan,
      'diskon': item.diskon,
      'isAssigned': item.isAssigned,
      // Data tambahan dari relasi
      'jenisBarangKode': item.jenisBarang?.kode ?? '',
      'bentukBarangKode': item.bentukBarang?.kode ?? '',
      'bentukBarangDimensi': item.bentukBarang?.dimensi ?? '',
      'gradeBarangKode': item.gradeBarang?.kode ?? '',
      // Data pelaksana untuk WorkOrderDetailItemController
      'hasManyPelaksana': item.pelaksana.map((pelaksana) => {
        'id': pelaksana.id,
        'wo_plan_item_id': pelaksana.woPlanItemId,
        'pelaksana_id': pelaksana.pelaksanaId,
        'qty': pelaksana.qty,
        'weight': pelaksana.weight,
        'tanggal': pelaksana.tanggal,
        'jam_mulai': pelaksana.jamMulai,
        'jam_selesai': pelaksana.jamSelesai,
        'catatan': pelaksana.catatan,
        'pelaksana': pelaksana.pelaksana != null ? {
          'id': pelaksana.pelaksana!.id,
          'kode': pelaksana.pelaksana!.kode,
          'nama_pelaksana': pelaksana.pelaksana!.namaPelaksana,
          'level': pelaksana.pelaksana!.level,
        } : null,
      }).toList(),
    };
  }

  // Method untuk mendapatkan nama jenis barang berdasarkan ID
  String _getJenisBarangName(int jenisBarangId) {
    // Mapping sementara, nanti bisa diambil dari API atau database
    switch (jenisBarangId) {
      case 1:
        return 'Aluminium';
      case 2:
        return 'Bronze';
      case 3:
        return 'Stainless Steel';
      default:
        return 'Unknown';
    }
  }

  // Method untuk mendapatkan nama bentuk barang berdasarkan ID
  String _getBentukBarangName(int bentukBarangId) {
    // Mapping sementara, nanti bisa diambil dari API atau database
    switch (bentukBarangId) {
      case 1:
        return 'PLAT';
      case 2:
        return 'PIPA';
      case 3:
        return 'PROFIL';
      default:
        return 'Unknown';
    }
  }

  // Method untuk mendapatkan nama grade barang berdasarkan ID
  String _getGradeBarangName(int gradeBarangId) {
    // Mapping sementara, nanti bisa diambil dari API atau database
    switch (gradeBarangId) {
      case 1:
        return '1100';
      case 2:
        return '2024';
      case 3:
        return '5052';
      default:
        return 'Unknown';
    }
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

  // Method untuk mengambil data detail work order planning berdasarkan ID
  Future<void> fetchWorkOrderPlanningDetail(int id) async {
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
          _workOrderPlanning = workOrderResponse.data;
          _workOrderItems = workOrderResponse.data.workOrderPlanningItems;
          _errorMessage = null;
        } else {
          throw Exception(workOrderResponse.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Work Order tidak ditemukan.');
      } else {
        throw Exception('Gagal mengambil data detail: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching work order detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk mengset data work order items
  void setWorkOrderItems(List<WorkOrderPlanningItem> items) {
    _workOrderItems = items;
    notifyListeners();
  }

  // Method untuk clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method untuk mendapatkan warna status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Planning':
        return Colors.orange[400]!;
      case 'Actual':
        return Colors.blue[400]!;
      default:
        return Colors.white;
    }
  }

  // Method untuk mendapatkan icon berdasarkan jenis barang
  IconData getItemIcon(String jenisBarang) {
    switch (jenisBarang.toLowerCase()) {
      case 'bronze':
        return Icons.circle;
      case 'aluminium':
        return Icons.square;
      default:
        return Icons.inventory;
    }
  }

  // Method untuk mendapatkan suffix luas berdasarkan jenis barang
  String getLuasSuffix(String jenisBarang) {
    return jenisBarang == 'Aluminium' ? ' (mm²)' : '';
  }

  // Method untuk mendapatkan text button save berdasarkan mode
  String getSaveButtonText(bool isEditMode) {
    return isEditMode ? 'UPDATE' : 'SIMPAN';
  }

  // Method untuk mendapatkan message success berdasarkan mode
  String getSuccessMessage(String noWO, bool isEditMode) {
    return 'Work Order $noWO berhasil ${isEditMode ? 'diupdate' : 'disimpan'}!';
  }

  // Method untuk mendapatkan header title berdasarkan mode
  String getHeaderTitle(bool isEditMode) {
    return isEditMode ? 'Edit Actual Work Order' : 'Set Actual Work Order';
  }

  // Method untuk mendapatkan header icon berdasarkan mode
  IconData getHeaderIcon(bool isEditMode) {
    return isEditMode ? Icons.edit : Icons.work;
  }

  // Method untuk mendapatkan informasi lengkap jenis barang
  String getJenisBarangInfo(WorkOrderPlanningItem item) {
    if (item.jenisBarang != null) {
      return '${item.jenisBarang!.kode} - ${item.jenisBarang!.namaJenis}';
    }
    return _getJenisBarangName(item.jenisBarangId);
  }

  // Method untuk mendapatkan informasi lengkap bentuk barang
  String getBentukBarangInfo(WorkOrderPlanningItem item) {
    if (item.bentukBarang != null) {
      return '${item.bentukBarang!.kode} - ${item.bentukBarang!.namaBentuk} (${item.bentukBarang!.dimensi})';
    }
    return _getBentukBarangName(item.bentukBarangId);
  }

  // Method untuk mendapatkan informasi lengkap grade barang
  String getGradeBarangInfo(WorkOrderPlanningItem item) {
    if (item.gradeBarang != null) {
      return '${item.gradeBarang!.kode} - ${item.gradeBarang!.nama}';
    }
    return _getGradeBarangName(item.gradeBarangId);
  }

  // Method untuk mendapatkan deskripsi lengkap item
  String getItemDescription(WorkOrderPlanningItem item) {
    final jenis = getJenisBarangInfo(item);
    final bentuk = getBentukBarangInfo(item);
    final grade = getGradeBarangInfo(item);
    return '$jenis, $bentuk, Grade: $grade';
  }

  // Method untuk memformat angka dengan pemisah ribuan
  String formatNumberWithCommas(dynamic value) {
    if (value == null) return '-';
    
    double? numericValue;
    if (value is double) {
      numericValue = value;
    } else if (value is int) {
      numericValue = value.toDouble();
    } else if (value is String) {
      numericValue = double.tryParse(value);
    }
    
    if (numericValue == null) return '-';
    
    // Format dengan pemisah ribuan menggunakan regex
    final numberString = numericValue.toStringAsFixed(0);
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return numberString.replaceAllMapped(regex, (match) => '${match[1]}.');
  }

  // Method untuk mendapatkan informasi pelaksana
  String getPelaksanaInfo(WorkOrderPlanningItem item) {
    if (item.pelaksana.isEmpty) {
      return 'Belum ada pelaksana';
    }
    
    final pelaksanaNames = item.pelaksana
        .where((p) => p.pelaksana != null)
        .map((p) => p.pelaksana!.namaPelaksana)
        .toList();
    
    if (pelaksanaNames.isEmpty) {
      return 'Pelaksana belum ditentukan';
    }
    
    return pelaksanaNames.join(', ');
  }

  // Method untuk mendapatkan jumlah pelaksana
  int getPelaksanaCount(WorkOrderPlanningItem item) {
    return item.pelaksana.length;
  }

  // Method untuk mendapatkan total qty pelaksana
  int getTotalQtyPelaksana(WorkOrderPlanningItem item) {
    return item.pelaksana.fold(0, (sum, pelaksana) => sum + pelaksana.qty);
  }

  // Method untuk fetch data pelaksana dari API
  Future<void> fetchAvailablePelaksana() async {
    _isLoadingPelaksana = true;
    _pelaksanaErrorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final pelaksanaEndpoint = dotenv.env['API_PELAKSANA'] ?? '/api/pelaksana';
      final url = Uri.parse('$baseUrl$pelaksanaEndpoint');
      
      // Debug: Print URL being used
      debugPrint('Pelaksana API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Debug: Print response details
      debugPrint('Pelaksana Response Status Code: ${response.statusCode}');
      debugPrint('Pelaksana Response Body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pelaksanaResponse = PelaksanaResult.fromMap(jsonData);
        
        if (pelaksanaResponse.success) {
          _availablePelaksana = pelaksanaResponse.data;
          _pelaksanaErrorMessage = null;
        } else {
          throw Exception(pelaksanaResponse.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Data pelaksana tidak ditemukan.');
      } else {
        throw Exception('Gagal mengambil data pelaksana: ${response.statusCode}');
      }
    } catch (e) {
      _pelaksanaErrorMessage = e.toString();
      debugPrint('Error fetching pelaksana: $e');
    } finally {
      _isLoadingPelaksana = false;
      notifyListeners();
    }
  }

  // Method untuk clear error pelaksana
  void clearPelaksanaError() {
    _pelaksanaErrorMessage = null;
    notifyListeners();
  }

  // Method untuk mendapatkan nama pelaksana berdasarkan ID
  String getPelaksanaNameById(int pelaksanaId) {
    for (var pelaksana in _availablePelaksana) {
      if (pelaksana.id == pelaksanaId) {
        return pelaksana.namaPelaksana;
      }
    }
    return 'Pelaksana $pelaksanaId';
  }

  // Method untuk mendapatkan list nama pelaksana untuk dropdown
  List<String> getPelaksanaNames() {
    return _availablePelaksana.map((pelaksana) => pelaksana.namaPelaksana).toList();
  }

  // Method untuk mengambil data detail work order item berdasarkan ID
  Future<Map<String, dynamic>?> fetchWorkOrderItemDetail(int itemId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final showItemEndpoint = dotenv.env['API_SHOW_ITEM'] ?? '/api/work-order-planning/item';
      
      // Build URL with query parameter
      final urlString = '$baseUrl$showItemEndpoint/$itemId?create_actual=true';
      debugPrint('Show Item URL String: $urlString');
      
      final url = Uri.parse(urlString);
      
      // Debug: Print URL being used
      debugPrint('Show Item API URL: $url');
      debugPrint('URL toString: ${url.toString()}');
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
      debugPrint('Show Item Response Status Code: ${response.statusCode}');
      debugPrint('Show Item Response Body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return jsonData['data'];
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data item detail');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Item work order tidak ditemukan.');
      } else {
        throw Exception('Gagal mengambil data item detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching work order item detail: $e');
      rethrow;
    }
  }

}
