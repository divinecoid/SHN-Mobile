import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/work_order_planning_model.dart';
import '../models/pelaksana_model.dart';
import '../utils/auth_helper.dart';

class WorkOrderDetailController extends ChangeNotifier {
  List<WorkOrderPlanningItem> _workOrderItems = [];
  WorkOrderPlanning? _workOrderPlanning;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Foto bukti (base64 data URI)
  String? _fotoBuktiBase64;
  
  // Data pelaksana
  List<Pelaksana> _availablePelaksana = [];
  bool _isLoadingPelaksana = false;
  String? _pelaksanaErrorMessage;
  
  // Actual work order ID
  int? _actualWorkOrderId;

  // Getter untuk mendapatkan data work order items
  List<Map<String, dynamic>> get getWorkOrderItems {
    return _workOrderItems.map((item) => _convertItemToMap(item)).toList();
  }
  
  // Getter untuk actual work order ID
  int? get actualWorkOrderId => _actualWorkOrderId;
  
  // Getter untuk foto bukti (base64 data URI)
  String? get fotoBuktiBase64 => _fotoBuktiBase64;
  
  // Method untuk set actual work order ID
  void setActualWorkOrderId(int? id) {
    _actualWorkOrderId = id;
    notifyListeners();
  }
  
  // Method untuk menghapus foto bukti
  void clearFotoBukti() {
    _fotoBuktiBase64 = null;
    notifyListeners();
  }
  
  // Helper: buat data URI base64 dari bytes
  String _toDataUri(Uint8List bytes, {String mimeType = 'image/jpeg'}) {
    final base64Str = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64Str';
  }
  
  // Method: ambil foto dari kamera atau galeri, lalu simpan sebagai base64 data URI
  // Gunakan: await pickAndSetFotoBukti(ImageSource.camera) atau ImageSource.gallery
  Future<void> pickAndSetFotoBukti(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) {
        return;
      }
      final bytes = await picked.readAsBytes();
      // Deteksi sederhana MIME berdasarkan ekstensi
      final path = picked.name.toLowerCase();
      String mime = 'image/jpeg';
      if (path.endsWith('.png')) mime = 'image/png';
      else if (path.endsWith('.webp')) mime = 'image/webp';
      _fotoBuktiBase64 = _toDataUri(bytes, mimeType: mime);
      notifyListeners();
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
  
  // Method untuk test parsing JSON response
  void testJsonParsing(Map<String, dynamic> jsonResponse) {
    try {
      final workOrderResponse = WorkOrderPlanningResult.fromMap(jsonResponse);
      if (workOrderResponse.success) {
        final workOrder = workOrderResponse.data;
        debugPrint('Parsed Work Order ID: ${workOrder.id}');
        debugPrint('Parsed Work Order Status: ${workOrder.status}');
        
        if (workOrder.workOrderActual != null) {
          debugPrint('Parsed Actual Work Order ID: ${workOrder.workOrderActual!.id}');
          debugPrint('Parsed Actual Work Order Status: ${workOrder.workOrderActual!.status}');
          debugPrint('Parsed Actual Work Order Catatan: ${workOrder.workOrderActual!.catatan}');
        } else {
          debugPrint('No actual work order found in parsed data');
        }
        
        debugPrint('Parsed Items Count: ${workOrder.workOrderPlanningItems.length}');
        for (var item in workOrder.workOrderPlanningItems) {
          debugPrint('Item ${item.id}: ${item.woItemUniqueId} - Qty: ${item.qty}');
          debugPrint('  Pelaksana Count: ${item.pelaksana.length}');
        }
      }
    } catch (e) {
      debugPrint('Error parsing JSON response: $e');
    }
  }

  // Method untuk mendapatkan data work order items dengan data sementara
  Future<List<Map<String, dynamic>>> getWorkOrderItemsWithTempData(int workOrderId) async {
    List<Map<String, dynamic>> items = [];
    
    for (var item in _workOrderItems) {
      Map<String, dynamic> itemMap = _convertItemToMap(item);
      
      // Cek apakah ada data sementara untuk item ini
      final tempData = await loadTemporaryWorkOrderItem(workOrderId, item.id);
      debugPrint('Loading temp data for item ${item.id}: $tempData');
      
      if (tempData != null) {
        // Update dengan data sementara
        itemMap['qtyActual'] = tempData['qtyActual'];
        itemMap['beratActual'] = tempData['beratActual'];
        debugPrint('Updated item ${item.id} with temp data - qtyActual: ${tempData['qtyActual']}, beratActual: ${tempData['beratActual']}');
      } else {
        debugPrint('No temp data found for item ${item.id}');
      }
      
      items.add(itemMap);
    }
    
    debugPrint('Returning ${items.length} items with temp data');
    return items;
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
  Future<void> fetchWorkOrderPlanningDetail(int id, {BuildContext? context}) async {
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
          
          // Debug: Log jumlah items yang berhasil di-parse
          debugPrint('Work Order Items Count: ${_workOrderItems.length}');
          if (_workOrderItems.isEmpty) {
            debugPrint('WARNING: No work order items found in response');
            debugPrint('Response data keys: ${jsonData['data']?.keys}');
            debugPrint('Response data workOrderPlanningItems: ${jsonData['data']?['workOrderPlanningItems']}');
            debugPrint('Response data work_order_planning_items: ${jsonData['data']?['work_order_planning_items']}');
          }
          
          // Set actual work order ID jika ada
          if (_workOrderPlanning?.workOrderActual != null) {
            _actualWorkOrderId = _workOrderPlanning!.workOrderActual!.id;
            debugPrint('Actual Work Order ID set to: $_actualWorkOrderId');
          } else {
            debugPrint('No actual work order found in response');
          }
          
          _errorMessage = null;
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

  // Method untuk refresh data dengan data sementara
  Future<void> refreshDataWithTempData(int workOrderId) async {
    debugPrint('Refreshing data with temp data for work order $workOrderId');
    // Trigger rebuild dengan data sementara
    notifyListeners();
  }

  // Method untuk memuat ulang data work order items dengan data sementara
  Future<void> reloadWorkOrderItemsWithTempData(int workOrderId) async {
    debugPrint('Reloading work order items with temp data for work order $workOrderId');
    
    // Ambil semua data sementara
    final allTempData = await getAllTemporaryWorkOrderData(workOrderId);
    debugPrint('Found ${allTempData.length} temporary data items');
    
    // Log semua data sementara yang ditemukan
    for (var entry in allTempData.entries) {
      final itemId = entry.key;
      final tempData = entry.value;
      debugPrint('Temp data for item $itemId: $tempData');
    }
    
    // Trigger rebuild
    notifyListeners();
  }

  // Method untuk memuat data sementara dan mengupdate UI
  Future<void> loadAndUpdateTempData(int workOrderId) async {
    debugPrint('Loading and updating temp data for work order $workOrderId');
    
    // Ambil semua data sementara
    final allTempData = await getAllTemporaryWorkOrderData(workOrderId);
    debugPrint('Found ${allTempData.length} temporary data items');
    
    // Log semua data sementara yang ditemukan
    for (var entry in allTempData.entries) {
      final itemId = entry.key;
      final tempData = entry.value;
      debugPrint('Temp data for item $itemId: $tempData');
    }
    
    // Trigger rebuild
    notifyListeners();
  }

  // Method untuk mendapatkan data work order items dengan data sementara yang sudah di-cache
  List<Map<String, dynamic>> getWorkOrderItemsWithCachedTempData(int workOrderId) {
    List<Map<String, dynamic>> items = [];
    
    for (var item in _workOrderItems) {
      Map<String, dynamic> itemMap = _convertItemToMap(item);
      
      // Cek apakah ada data sementara yang sudah di-cache
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${item.id}';
      debugPrint('Checking cached temp data for key: $tempDataKey');
      
      items.add(itemMap);
    }
    
    return items;
  }

  // Method untuk mendapatkan data work order items dengan data sementara secara sinkron
  List<Map<String, dynamic>> getWorkOrderItemsWithTempDataSync(int workOrderId) {
    List<Map<String, dynamic>> items = [];
    
    for (var item in _workOrderItems) {
      Map<String, dynamic> itemMap = _convertItemToMap(item);
      
      // Cek data sementara secara sinkron (akan di-load di background)
      _loadTempDataForItem(workOrderId, item.id, itemMap);
      
      items.add(itemMap);
    }
    
    return items;
  }

  // Method untuk memuat data sementara untuk item tertentu
  void _loadTempDataForItem(int workOrderId, int itemId, Map<String, dynamic> itemMap) {
    loadTemporaryWorkOrderItem(workOrderId, itemId).then((tempData) {
      if (tempData != null) {
        itemMap['qtyActual'] = tempData['qtyActual'];
        itemMap['beratActual'] = tempData['beratActual'];
        debugPrint('Updated item $itemId with temp data - qtyActual: ${tempData['qtyActual']}, beratActual: ${tempData['beratActual']}');
        notifyListeners();
      }
    });
  }

  // Method untuk mendapatkan data work order items dengan data sementara secara langsung
  Future<List<Map<String, dynamic>>> getWorkOrderItemsWithTempDataDirect(int workOrderId) async {
    List<Map<String, dynamic>> items = [];
    
    for (var item in _workOrderItems) {
      Map<String, dynamic> itemMap = _convertItemToMap(item);
      
      // Cek apakah ada data sementara untuk item ini
      final tempData = await loadTemporaryWorkOrderItem(workOrderId, item.id);
      debugPrint('Loading temp data for item ${item.id}: $tempData');
      
      if (tempData != null) {
        // Update dengan data sementara
        itemMap['qtyActual'] = tempData['qtyActual'];
        itemMap['beratActual'] = tempData['beratActual'];
        debugPrint('Updated item ${item.id} with temp data - qtyActual: ${tempData['qtyActual']}, beratActual: ${tempData['beratActual']}');
      } else {
        debugPrint('No temp data found for item ${item.id}');
      }
      
      items.add(itemMap);
    }
    
    debugPrint('Returning ${items.length} items with temp data');
    return items;
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

  // Helper status selesai
  bool isCompletedStatus(String status) {
    final s = status.toLowerCase();
    return s == 'selesai' || s == 'completed' || s == 'done';
  }

  bool get isCurrentWorkOrderCompleted {
    final status = _workOrderPlanning?.status ?? '';
    return isCompletedStatus(status);
  }

  // Method untuk mendapatkan suffix luas berdasarkan jenis barang
  String getLuasSuffix(String jenisBarang) {
    return jenisBarang == 'Aluminium' ? ' (mm²)' : '';
  }

  // Method untuk mendapatkan text button save berdasarkan mode
  String getSaveButtonText(bool isEditMode) {
    return isEditMode ? 'UPDATE ACTUAL' : 'SIMPAN ACTUAL';
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
  Future<void> fetchAvailablePelaksana({BuildContext? context}) async {
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
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
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
  Future<Map<String, dynamic>?> fetchWorkOrderItemDetail(int itemId, {BuildContext? context}) async {
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
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
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

  // Method untuk menyimpan data sementara work order item
  Future<void> saveTemporaryWorkOrderItem(int workOrderId, int itemId, Map<String, dynamic> itemData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${itemId}';
      
      final tempData = {
        'itemData': itemData,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(tempDataKey, json.encode(tempData));
      debugPrint('Data sementara work order item disimpan untuk work order $workOrderId, item $itemId');
    } catch (e) {
      debugPrint('Error saving temporary work order item: $e');
    }
  }

  // Method untuk memuat data sementara work order item
  Future<Map<String, dynamic>?> loadTemporaryWorkOrderItem(int workOrderId, int itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${itemId}';
      
      final tempDataString = prefs.getString(tempDataKey);
      if (tempDataString != null) {
        final tempData = json.decode(tempDataString) as Map<String, dynamic>;
        
        // Cek apakah data memiliki struktur itemData (dari WorkOrderDetailController)
        if (tempData.containsKey('itemData')) {
          return tempData['itemData'] as Map<String, dynamic>?;
        } 
        // Jika tidak, berarti data langsung dari WorkOrderDetailItemController
        else {
          return tempData;
        }
      }
    } catch (e) {
      debugPrint('Error loading temporary work order item: $e');
    }
    return null;
  }

  // Method untuk mendapatkan semua data sementara work order
  Future<Map<String, dynamic>> getAllTemporaryWorkOrderData(int workOrderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      debugPrint('All SharedPreferences keys: $keys');
      debugPrint('Looking for keys starting with: temp_work_order_${workOrderId}_item_');
      
      // Filter keys yang sesuai dengan work order ID
      final workOrderKeys = keys.where((key) => key.startsWith('temp_work_order_${workOrderId}_item_')).toList();
      debugPrint('Found work order keys: $workOrderKeys');
      
      Map<String, dynamic> allTempData = {};
      
      for (String key in workOrderKeys) {
        final tempDataString = prefs.getString(key);
        debugPrint('Reading key $key: $tempDataString');
        if (tempDataString != null) {
          final tempData = json.decode(tempDataString) as Map<String, dynamic>;
          debugPrint('Decoded temp data for $key: $tempData');
          // Extract item ID from key
          final itemId = key.split('_').last;
          allTempData[itemId] = tempData;
        }
      }
      
      debugPrint('Final allTempData: $allTempData');
      
      // Tambahkan workOrderId ke dalam response
      final response = {
        'actualWorkOrderId': _actualWorkOrderId,
        'planningWorkOrderId': workOrderId,
        'items': allTempData,
      };
      
      return response;
    } catch (e) {
      debugPrint('Error getting all temporary work order data: $e');
      return {
        'actualWorkOrderId': _actualWorkOrderId,
        'planningWorkOrderId': workOrderId,
        'items': {},
      };
    }
  }

  // Method untuk menghapus semua data sementara work order
  Future<void> clearAllTemporaryWorkOrderData(int workOrderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Filter keys yang sesuai dengan work order ID
      final workOrderKeys = keys.where((key) => key.startsWith('temp_work_order_${workOrderId}_item_')).toList();
      
      for (String key in workOrderKeys) {
        await prefs.remove(key);
      }
      
      debugPrint('Semua data sementara work order $workOrderId dihapus');
    } catch (e) {
      debugPrint('Error clearing all temporary work order data: $e');
    }
  }

  // Method untuk memvalidasi apakah semua item sudah diproses
  Future<bool> validateAllItemsProcessed(int workOrderId) async {
    try {
      // Ambil semua data sementara
      final allTempData = await getAllTemporaryWorkOrderData(workOrderId);
      final tempDataItems = allTempData['items'] as Map<String, dynamic>;
      
      // Hitung jumlah data sementara yang ada
      final tempDataCount = tempDataItems.length;
      
      // Hitung jumlah total detail item
      final totalDetailItems = _workOrderItems.length;
      
      debugPrint('Validasi item: Temp data count = $tempDataCount, Total detail items = $totalDetailItems');
      
      // Return true jika jumlah data sementara sama dengan jumlah detail item
      return tempDataCount == totalDetailItems;
    } catch (e) {
      debugPrint('Error validating items processed: $e');
      return false;
    }
  }

  // Method untuk mendapatkan jumlah item yang belum diproses
  Future<int> getUnprocessedItemsCount(int workOrderId) async {
    try {
      // Ambil semua data sementara
      final allTempData = await getAllTemporaryWorkOrderData(workOrderId);
      final tempDataItems = allTempData['items'] as Map<String, dynamic>;
      
      // Hitung jumlah data sementara yang ada
      final tempDataCount = tempDataItems.length;
      
      // Hitung jumlah total detail item
      final totalDetailItems = _workOrderItems.length;
      
      // Return selisih (jumlah item yang belum diproses)
      return totalDetailItems - tempDataCount;
    } catch (e) {
      debugPrint('Error getting unprocessed items count: $e');
      return _workOrderItems.length; // Return total items jika error
    }
  }

  // Method untuk menyimpan data actual ke API
  Future<bool> saveActualWorkOrderData(int workOrderId, Map<String, dynamic> allTempData, {BuildContext? context}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final workOrderActualEndpoint = dotenv.env['API_LIST_WO_ACT'] ?? '/api/work-order-actual';
      final url = Uri.parse('$baseUrl$workOrderActualEndpoint');
      
      // Debug: Print URL being used
      debugPrint('Work Order Actual API URL: $url');
      debugPrint('Data yang akan dikirim: $allTempData');

      // Sisipkan foto_bukti ke payload jika tersedia dan normalisasi struktur items
      final payload = {
        ...allTempData,
        if (_fotoBuktiBase64 != null) 'foto_bukti': _fotoBuktiBase64,
      };
      
      // Normalisasi struktur items: flatten { itemData, timestamp } => {...itemData, timestamp}
      if (payload['items'] is Map) {
        final Map<String, dynamic> originalItems = Map<String, dynamic>.from(payload['items'] as Map);
        final Map<String, dynamic> normalizedItems = {};
        originalItems.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            if (value.containsKey('itemData')) {
              final Map<String, dynamic> itemData = Map<String, dynamic>.from(value['itemData'] ?? {});
              if (!itemData.containsKey('timestamp') && value['timestamp'] != null) {
                itemData['timestamp'] = value['timestamp'];
              }
              normalizedItems[key] = itemData;
            } else {
              normalizedItems[key] = value;
            }
          } else {
            normalizedItems[key] = value;
          }
        });
        payload['items'] = normalizedItems;
      }
      
      debugPrint('Final payload to send: ${json.encode(payload).substring(0, payload.toString().length > 200 ? 200 : json.encode(payload).length)}...');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );
      
      // Debug: Print response details
      debugPrint('Work Order Actual Response Status Code: ${response.statusCode}');
      debugPrint('Work Order Actual Response Body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          debugPrint('Work order actual berhasil disimpan');
          // Bersihkan foto setelah sukses
          _fotoBuktiBase64 = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message']?.toString() ?? 'Gagal menyimpan data actual work order';
          return false;
        }
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
        _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        return false;
      } else if (response.statusCode == 422) {
        final jsonData = json.decode(response.body);
        _errorMessage = jsonData['message']?.toString() ?? 'Data tidak valid';
        return false;
      } else {
        try {
          final jsonData = json.decode(response.body);
          _errorMessage = jsonData['message']?.toString() ?? 'Gagal menyimpan data actual work order: ${response.statusCode}';
        } catch (_) {
          _errorMessage = 'Gagal menyimpan data actual work order: ${response.statusCode}';
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error saving actual work order data: $e');
      _errorMessage = e.toString();
      return false;
    }
  }

}
