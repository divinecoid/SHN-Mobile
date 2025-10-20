import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/gudang_model.dart';
import '../models/penerimaan_barang_model.dart';
import '../controllers/penerimaan_barang_list_controller.dart';

class InputPenerimaanBarangController extends ChangeNotifier {
  // Form controllers
  final TextEditingController catatanController = TextEditingController();
  
  // Form state
  String _selectedOrigin = 'purchaseorder';
  int? _selectedGudangId;
  String _selectedGudangName = '';
  File? _selectedImage;
  List<PenerimaanBarangDetailInput> _details = [];
  String _scannedNumber = '';
  
  // Scanned document state (from API lookup by nomor PO/Mutasi)
  ScannedDokumenResult? _scannedDokumen;
  List<ScannedItem> _scannedItems = [];
  
  // Scanned barcodes for marking items
  Set<String> _scannedBarcodes = {};
  
  // Gudang state
  List<Gudang> _gudangList = [];
  bool _isLoadingGudang = false;
  String? _gudangError;
  
  // Loading state
  bool _isSubmitting = false;

  // Getters
  String get selectedOrigin => _selectedOrigin;
  int? get selectedGudangId => _selectedGudangId;
  String get selectedGudangName => _selectedGudangName;
  File? get selectedImage => _selectedImage;
  List<PenerimaanBarangDetailInput> get details => _details;
  String get scannedNumber => _scannedNumber;
  List<Gudang> get gudangList => _gudangList;
  bool get isLoadingGudang => _isLoadingGudang;
  String? get gudangError => _gudangError;
  bool get isSubmitting => _isSubmitting;
  ScannedDokumenResult? get scannedDokumen => _scannedDokumen;
  List<ScannedItem> get scannedItems => _scannedItems;
  Set<String> get scannedBarcodes => _scannedBarcodes;

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
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

  // Gudang methods
  Future<void> loadGudangList() async {
    _isLoadingGudang = true;
    _gudangError = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final gudangEndpoint = '/api/gudang';
      final url = Uri.parse('$baseUrl$gudangEndpoint');
      
      // Debug: Print URL being used
      debugPrint('Gudang API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Debug: Print response details
      debugPrint('Gudang Response Status Code: ${response.statusCode}');
      debugPrint('Gudang Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final gudangResult = GudangResult.fromMap(jsonData);
        
        if (gudangResult.success) {
          _gudangList = gudangResult.data;
          _gudangError = null;
        } else {
          throw Exception(gudangResult.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        throw Exception('Gagal mengambil data gudang: ${response.statusCode}');
      }
    } catch (e) {
      _gudangError = 'Gagal memuat data gudang: $e';
      debugPrint('Error loading gudang list: $e');
    } finally {
      _isLoadingGudang = false;
      notifyListeners();
    }
  }

  void selectGudang(Gudang gudang) {
    _selectedGudangId = gudang.id;
    _selectedGudangName = gudang.namaGudang;
    notifyListeners();
  }

  // Origin methods
  void setSelectedOrigin(String origin) {
    _selectedOrigin = origin;
    _scannedNumber = ''; // Reset scanned number when origin changes
    _scannedDokumen = null;
    _scannedItems = [];
    notifyListeners();
  }

  // Scan number methods
  void setScannedNumber(String number) {
    _scannedNumber = number;
    notifyListeners();
  }

  // Fetch scanned document by number
  Future<void> fetchDokumenByNumber() async {
    final nomor = _scannedNumber.trim();
    if (nomor.isEmpty) {
      return;
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      late final Uri url;
      if (_selectedOrigin == 'purchaseorder') {
        url = Uri.parse('$baseUrl/api/purchase-order/scan-nomor-po/$nomor');
      } else {
        url = Uri.parse('$baseUrl/api/stock-mutation/scan-nomor-mutasi/$nomor');
      }

      debugPrint('Scan nomor URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Scan nomor status: ${response.statusCode}');
      debugPrint('Scan nomor body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final success = jsonData['success'] == true;
        if (!success) {
          throw Exception(jsonData['message'] ?? 'Gagal memproses nomor');
        }

        final data = (jsonData['data'] as Map<String, dynamic>?);
        if (data == null) {
          throw Exception('Data tidak ditemukan');
        }

        _scannedDokumen = ScannedDokumenResult.fromMap(data);
        _scannedItems = (_scannedDokumen?.items) ?? [];
        notifyListeners();
      } else if (response.statusCode == 404) {
        throw Exception('Nomor tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching dokumen by number: $e');
      rethrow;
    }
  }

  // Image methods
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Gagal mengambil gambar: $e');
    }
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Details methods
  void addDetail(int idItemBarang, int idRak, int qty) {
    _details.add(PenerimaanBarangDetailInput(
      idItemBarang: idItemBarang,
      idRak: idRak,
      qty: qty,
    ));
    notifyListeners();
  }

  void removeDetail(int index) {
    _details.removeAt(index);
    notifyListeners();
  }

  // Barcode scanning methods
  void addScannedBarcode(String barcode) {
    _scannedBarcodes.add(barcode);
    notifyListeners();
  }

  void removeScannedBarcode(String barcode) {
    _scannedBarcodes.remove(barcode);
    notifyListeners();
  }

  bool isItemScanned(String? kodeBarang) {
    if (kodeBarang == null || kodeBarang.isEmpty) return false;
    return _scannedBarcodes.contains(kodeBarang);
  }

  void clearScannedBarcodes() {
    _scannedBarcodes.clear();
    notifyListeners();
  }

  // Validation methods
  String? validateForm() {
    if (_scannedNumber.isEmpty) {
      return 'Scan ${_selectedOrigin == 'purchaseorder' ? 'Nomor PO' : 'Nomor Mutasi'} terlebih dahulu';
    }

    if (_selectedGudangId == null) {
      return 'Pilih gudang terlebih dahulu';
    }

    if (_selectedImage == null) {
      return 'Upload bukti foto terlebih dahulu';
    }

    return null;
  }

  // Check if all items are scanned
  bool areAllItemsScanned() {
    if (_scannedItems.isEmpty) return true; // No items to scan
    return _scannedBarcodes.length == _scannedItems.length;
  }

  // Get count of scanned vs total items
  String getScanProgress() {
    if (_scannedItems.isEmpty) return '0/0';
    return '${_scannedBarcodes.length}/${_scannedItems.length}';
  }

  // Submit method
  Future<bool> submitForm() async {
    final validationError = validateForm();
    if (validationError != null) {
      throw Exception(validationError);
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      // Convert image to base64
      String? base64Image;
      if (_selectedImage != null) {
        try {
          debugPrint('Converting image to base64...');
          debugPrint('Image path: ${_selectedImage!.path}');
          final bytes = await _selectedImage!.readAsBytes();
          debugPrint('Image size: ${bytes.length} bytes');
          base64Image = base64Encode(bytes);
          debugPrint('Base64 length: ${base64Image.length} characters');
        } catch (e) {
          debugPrint('Error converting image to base64: $e');
          throw Exception('Gagal mengkonversi gambar: $e');
        }
      } else {
        debugPrint('No image selected');
      }

      // Build detail barang from scanned items
      debugPrint('Building detail barang from ${_scannedItems.length} scanned items');
      debugPrint('Scanned barcodes: $_scannedBarcodes');
      
      final detailBarang = _scannedItems.map((item) {
        final isScanned = _scannedBarcodes.contains(item.kodeBarang);
        final detail = DetailBarangSubmit(
          id: item.id ?? 0,
          kode: item.kodeBarang ?? '',
          namaItem: 'Item ${item.id ?? 0}', // You might want to get this from API
          ukuran: '${item.panjang ?? '0'} x ${item.lebar ?? '0'} x ${item.tebal ?? '0'}',
          qty: item.qty ?? item.quantity ?? 1,
          statusScan: isScanned ? 'Terscan' : 'Belum Terscan',
        );
        debugPrint('Detail item: ${detail.toMap()}');
        return detail;
      }).toList();
      
      debugPrint('Total detail barang: ${detailBarang.length}');

      final request = PenerimaanBarangSubmitRequest(
        asalPenerimaan: _selectedOrigin,
        nomorPo: _selectedOrigin == 'purchaseorder' ? _scannedNumber : null,
        nomorMutasi: _selectedOrigin == 'stockmutation' ? _scannedNumber : null,
        gudangId: _selectedGudangId!,
        catatan: catatanController.text.trim(),
        buktiFoto: base64Image,
        detailBarang: detailBarang,
      );

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final url = Uri.parse('$baseUrl/api/penerimaan-barang');

      debugPrint('Submit URL: $url');
      debugPrint('Request body: ${json.encode(request.toMap())}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toMap()),
      );

      debugPrint('Submit response status: ${response.statusCode}');
      debugPrint('Submit response headers: ${response.headers}');
      debugPrint('Submit response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          debugPrint('Parsed response data: $jsonData');
          
          final success = jsonData['success'] == true;
          if (!success) {
            final errorMessage = jsonData['message'] ?? 'Gagal menyimpan data';
            debugPrint('API returned success=false: $errorMessage');
            throw Exception(errorMessage);
          }
          return true;
        } catch (e) {
          debugPrint('Error parsing response JSON: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Gagal memproses respons dari server: $e');
        }
      } else if (response.statusCode == 401) {
        debugPrint('Authentication error - status 401');
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 422) {
        debugPrint('Validation error - status 422');
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          final errors = jsonData['errors'] ?? jsonData['message'] ?? 'Data tidak valid';
          debugPrint('Validation errors: $errors');
          throw Exception('Data tidak valid: $errors');
        } catch (e) {
          debugPrint('Error parsing validation response: $e');
          throw Exception('Data tidak valid: ${response.body}');
        }
      } else if (response.statusCode == 500) {
        debugPrint('Server error - status 500');
        debugPrint('Server error response: ${response.body}');
        throw Exception('Terjadi kesalahan pada server. Silakan coba lagi.');
      } else {
        debugPrint('Unexpected status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Gagal menyimpan data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in submitForm: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('Exception details: ${e.toString()}');
      }
      throw Exception('Gagal menyimpan data: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Reset form method
  void resetForm() {
    _selectedOrigin = 'purchaseorder';
    _selectedGudangId = null;
    _selectedGudangName = '';
    _selectedImage = null;
    _details.clear();
    _scannedNumber = '';
    _scannedDokumen = null;
    _scannedItems = [];
    _scannedBarcodes.clear();
    catatanController.clear();
    _gudangError = null;
    notifyListeners();
  }
}

// Models for scanned document
class ScannedDokumenResult {
  final String nomorDokumen;
  final String tipeDokumen;
  final String? status;
  final String? tanggalDokumen;
  final String? tanggalPenerimaan;
  final String? userPenerima;
  final String? gudangAsal;
  final String? gudangTujuan;
  final String? supplier;
  final String? catatan;
  final List<ScannedItem> items;

  ScannedDokumenResult({
    required this.nomorDokumen,
    required this.tipeDokumen,
    this.status,
    this.tanggalDokumen,
    this.tanggalPenerimaan,
    this.userPenerima,
    this.gudangAsal,
    this.gudangTujuan,
    this.supplier,
    this.catatan,
    required this.items,
  });

  factory ScannedDokumenResult.fromMap(Map<String, dynamic> map) {
    final items = (map['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((m) => ScannedItem.fromMap(m))
        .toList();
    return ScannedDokumenResult(
      nomorDokumen: map['nomor_dokumen']?.toString() ?? '',
      tipeDokumen: map['tipe_dokumen']?.toString() ?? '',
      status: map['status']?.toString(),
      tanggalDokumen: map['tanggal_dokumen']?.toString(),
      tanggalPenerimaan: map['tanggal_penerimaan']?.toString(),
      userPenerima: map['user_penerima']?.toString(),
      gudangAsal: map['gudang_asal']?.toString(),
      gudangTujuan: map['gudang_tujuan']?.toString(),
      supplier: map['supplier']?.toString(),
      catatan: map['catatan']?.toString(),
      items: items,
    );
  }
}

class ScannedItem {
  final int? id;
  final int? itemBarangId;
  final String? kodeBarang;
  final String? unit;
  final String? status;
  final int? quantity;
  final String? panjang;
  final String? lebar;
  final String? tebal;
  final int? qty;
  final int? jenisBarangId;
  final int? bentukBarangId;
  final int? gradeBarangId;
  final String? satuan;
  final String? catatan;

  ScannedItem({
    this.id,
    this.itemBarangId,
    this.kodeBarang,
    this.unit,
    this.status,
    this.quantity,
    this.panjang,
    this.lebar,
    this.tebal,
    this.qty,
    this.jenisBarangId,
    this.bentukBarangId,
    this.gradeBarangId,
    this.satuan,
    this.catatan,
  });

  factory ScannedItem.fromMap(Map<String, dynamic> map) {
    return ScannedItem(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      itemBarangId: map['item_barang_id'] is int ? map['item_barang_id'] as int : int.tryParse('${map['item_barang_id']}'),
      kodeBarang: map['kode_barang']?.toString(),
      unit: map['unit']?.toString(),
      status: map['status']?.toString(),
      quantity: map['quantity'] is int ? map['quantity'] as int : int.tryParse('${map['quantity']}'),
      panjang: map['panjang']?.toString(),
      lebar: map['lebar']?.toString(),
      tebal: map['tebal']?.toString(),
      qty: map['qty'] is int ? map['qty'] as int : int.tryParse('${map['qty']}'),
      jenisBarangId: map['jenis_barang_id'] is int ? map['jenis_barang_id'] as int : int.tryParse('${map['jenis_barang_id']}'),
      bentukBarangId: map['bentuk_barang_id'] is int ? map['bentuk_barang_id'] as int : int.tryParse('${map['bentuk_barang_id']}'),
      gradeBarangId: map['grade_barang_id'] is int ? map['grade_barang_id'] as int : int.tryParse('${map['grade_barang_id']}'),
      satuan: map['satuan']?.toString(),
      catatan: map['catatan']?.toString(),
    );
  }
}
