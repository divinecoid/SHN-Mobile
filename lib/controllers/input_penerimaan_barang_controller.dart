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
import '../models/item_barang_group_model.dart';
import '../models/ref_jenis_barang_model.dart';
import '../models/ref_bentuk_barang_model.dart';
import '../models/ref_grade_barang_model.dart';
import '../controllers/penerimaan_barang_list_controller.dart';

class InputPenerimaanBarangController extends ChangeNotifier {
  // Form controllers
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController rakController = TextEditingController();
  
  // Form state
  String _selectedOrigin = 'purchaseorder';
  int? _selectedGudangId;
  String _selectedGudangName = '';
  String _selectedGudangKode = '';
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
  
  // RAK state
  int? _selectedRakId;
  String _selectedRakKode = '';
  String _selectedRakNama = '';
  
  // Loading state
  bool _isSubmitting = false;

  // --- NON-PO STATE ---
  List<DetailBarangNonPo> _nonPoDetails = [];
  List<ItemBarangGroup> _itemBarangGroups = [];
  List<RefJenisBarang> _jenisBarangList = [];
  List<RefBentukBarang> _bentukBarangList = [];
  List<RefGradeBarang> _gradeBarangList = [];
  
  bool _isLoadingRefData = false;
  bool _isSearchingGroups = false;

  // Getters
  String get selectedOrigin => _selectedOrigin;
  int? get selectedGudangId => _selectedGudangId;
  String get selectedGudangName => _selectedGudangName;
  String get selectedGudangKode => _selectedGudangKode;
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
  int? get selectedRakId => _selectedRakId;
  String get selectedRakKode => _selectedRakKode;
  String get selectedRakNama => _selectedRakNama;

  // Non-PO Getters
  List<DetailBarangNonPo> get nonPoDetails => _nonPoDetails;
  List<ItemBarangGroup> get itemBarangGroups => _itemBarangGroups;
  List<RefJenisBarang> get jenisBarangList => _jenisBarangList;
  List<RefBentukBarang> get bentukBarangList => _bentukBarangList;
  List<RefGradeBarang> get gradeBarangList => _gradeBarangList;
  bool get isLoadingRefData => _isLoadingRefData;
  bool get isSearchingGroups => _isSearchingGroups;

  @override
  void dispose() {
    catatanController.dispose();
    rakController.dispose();
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

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final url = Uri.parse('$baseUrl/api/gudang');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
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
    } finally {
      _isLoadingGudang = false;
      notifyListeners();
    }
  }

  void selectGudang(Gudang gudang) {
    _selectedGudangId = gudang.id;
    _selectedGudangName = gudang.namaGudang;
    _selectedGudangKode = gudang.kode;
    notifyListeners();
  }

  // Origin methods
  void setSelectedOrigin(String origin) {
    _selectedOrigin = origin;
    _scannedNumber = ''; 
    _scannedDokumen = null;
    _scannedItems = [];
    if (origin == 'nonpo' && _jenisBarangList.isEmpty) {
      fetchReferenceData();
    }
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

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

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
      rethrow;
    }
  }

  // --- SEARCH GROUP METHODS ---
  Future<void> searchGroups(String query, {int? jenisBarangId, int? bentukBarangId, int? gradeBarangId}) async {
    // If query is empty but we have filters, we still want to search
    if (query.length < 2 && jenisBarangId == null && bentukBarangId == null && gradeBarangId == null) return;
    
    _isSearchingGroups = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      
      String urlString = '$baseUrl/api/item-barang/group?search=$query';
      if (jenisBarangId != null) urlString += '&jenis_barang_id=$jenisBarangId';
      if (bentukBarangId != null) urlString += '&bentuk_barang_id=$bentukBarangId';
      if (gradeBarangId != null) urlString += '&grade_barang_id=$gradeBarangId';
      
      final url = Uri.parse(urlString);

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'] ?? [];
        _itemBarangGroups = data.map((e) => ItemBarangGroup.fromJson(e)).toList();
      }
    } catch (e) {
       debugPrint('Error searching groups: $e');
    } finally {
      _isSearchingGroups = false;
      notifyListeners();
    }
  }

  // --- FETCH REFERENCE DATA ---
  Future<void> fetchReferenceData() async {
    _isLoadingRefData = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // Fetch parallelly
      final futures = [
        http.get(Uri.parse('$baseUrl/api/jenis-barang'), headers: headers),
        http.get(Uri.parse('$baseUrl/api/bentuk-barang'), headers: headers),
        http.get(Uri.parse('$baseUrl/api/grade-barang'), headers: headers),
      ];

      final responses = await Future.wait(futures);

      if (responses[0].statusCode == 200) {
        final body = json.decode(responses[0].body);
        final List data = body['data'] ?? [];
        _jenisBarangList = data.map((e) => RefJenisBarang.fromJson(e)).toList();
      }

      if (responses[1].statusCode == 200) {
        final body = json.decode(responses[1].body);
        final List data = body['data'] ?? [];
        _bentukBarangList = data.map((e) => RefBentukBarang.fromJson(e)).toList();
      }

      if (responses[2].statusCode == 200) {
        final body = json.decode(responses[2].body);
        final List data = body['data'] ?? [];
        _gradeBarangList = data.map((e) => RefGradeBarang.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching ref data: $e');
    } finally {
      _isLoadingRefData = false;
      notifyListeners();
    }
  }

  // --- NON-PO DETAIL METHODS ---
  void addNonPoDetail(DetailBarangNonPo detail) {
    _nonPoDetails.add(detail);
    notifyListeners();
  }

  void removeNonPoDetail(int index) {
    _nonPoDetails.removeAt(index);
    notifyListeners();
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

  // Details methods (Batch for PO/Mutation)
  void addDetail(int idItemBarang, int idRak, int qty, {String? itemBarangName, String? rakKode}) {
    _details.add(PenerimaanBarangDetailInput(
      idItemBarang: idItemBarang,
      idRak: idRak,
      qty: qty,
      itemBarangName: itemBarangName,
      rakKode: rakKode,
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

  // RAK methods
  void setRak(int rakId, String rakKode, String rakNama) {
    _selectedRakId = rakId;
    _selectedRakKode = rakKode;
    _selectedRakNama = rakNama;
    rakController.text = rakKode; 
    notifyListeners();
  }

  void clearRak() {
    _selectedRakId = null;
    _selectedRakKode = '';
    _selectedRakNama = '';
    rakController.clear();
    notifyListeners();
  }

  // Fetch RAK by code
  Future<void> fetchRakByCode(String codeOrId) async {
    final code = codeOrId.trim();
    if (code.isEmpty) return;

    try {
      final token = await _getAuthToken();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final url = Uri.parse('$baseUrl/api/rak/search-by-kode');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'kode': code}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final rakData = jsonData['data'];
          setRak(rakData['id'], rakData['kode'] ?? '', rakData['nama_rak'] ?? '');
        } else {
          throw Exception(jsonData['message'] ?? 'Rak tidak ditemukan');
        }
      } else {
         throw Exception('Gagal memuat data rak: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Validation
  String? validateForm() {
    if (_selectedGudangId == null) return 'Pilih gudang terlebih dahulu';
    if (_selectedImage == null) return 'Upload bukti foto terlebih dahulu';

    if (_selectedOrigin != 'nonpo') {
      if (_scannedNumber.isEmpty) return 'Scan Nomor PO/Mutasi terlebih dahulu';
      if (_selectedRakId == null) return 'Scan RAK terlebih dahulu';
    } else {
      if (_nonPoDetails.isEmpty) return 'Tambah minimal satu detail barang';
    }
    return null;
  }

  bool areAllItemsScanned() {
    if (_selectedOrigin == 'nonpo') return true;
    if (_scannedItems.isEmpty) return true;
    return _scannedBarcodes.length == _scannedItems.length;
  }

  String getScanProgress() {
    if (_selectedOrigin == 'nonpo') return '${_nonPoDetails.length} items';
    if (_scannedItems.isEmpty) return '0/0';
    return '${_scannedBarcodes.length}/${_scannedItems.length}';
  }

  // Submit
  Future<bool> submitForm() async {
    final validationError = validateForm();
    if (validationError != null) throw Exception(validationError);

    _isSubmitting = true;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      late final Uri url;
      late final Map<String, dynamic> body;

      if (_selectedOrigin == 'nonpo') {
        url = Uri.parse('$baseUrl/api/penerimaan-barang/non-po');
        final request = PenerimaanBarangNonPoSubmitRequest(
          gudangId: _selectedGudangId!,
          catatan: catatanController.text.trim(),
          buktiFoto: base64Image,
          detailBarang: _nonPoDetails,
        );
        body = request.toMap();
      } else {
        url = Uri.parse('$baseUrl/api/penerimaan-barang');
        final detailBarang = _scannedItems.map((item) {
          final isScanned = _scannedBarcodes.contains(item.kodeBarang);
          return DetailBarangSubmit(
            id: item.itemBarangId ?? 0,
            kode: item.kodeBarang ?? '',
            namaItem: 'Item ${item.itemBarangId ?? 0}',
            ukuran: '${item.panjang ?? '0'} x ${item.lebar ?? '0'} x ${item.tebal ?? '0'}',
            qty: item.qty ?? item.quantity ?? 1,
            statusScan: isScanned ? 'Terscan' : 'Belum Terscan',
            idRak: _selectedRakId!, 
          );
        }).toList();

        final request = PenerimaanBarangSubmitRequest(
          asalPenerimaan: _selectedOrigin,
          nomorPo: _selectedOrigin == 'purchaseorder' ? _scannedNumber : null,
          nomorMutasi: _selectedOrigin == 'stockmutation' ? _scannedNumber : null,
          gudangId: _selectedGudangId!,
          catatan: catatanController.text.trim(),
          buktiFoto: base64Image,
          detailBarang: detailBarang,
        );
        body = request.toMap();
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true || jsonData['status'] == 'success') {
          return true;
        }
        throw Exception(jsonData['message'] ?? 'Gagal menyimpan data');
      } else {
        String errorDetail = 'Status: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorDetail = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorDetail = errorData['error'];
          }
        } catch (_) {
          // If not JSON, use truncated body
          errorDetail = response.body.length > 100 
            ? '${response.body.substring(0, 100)}...' 
            : response.body;
        }
        throw Exception(errorDetail);
      }
    } catch (e) {
      throw Exception('Gagal menyimpan data: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _selectedOrigin = 'purchaseorder';
    _selectedGudangId = null;
    _selectedGudangName = '';
    _selectedGudangKode = '';
    _selectedImage = null;
    _details.clear();
    _scannedNumber = '';
    _scannedDokumen = null;
    _scannedItems = [];
    _scannedBarcodes.clear();
    _selectedRakId = null;
    _selectedRakKode = '';
    _selectedRakNama = '';
    _nonPoDetails.clear();
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
