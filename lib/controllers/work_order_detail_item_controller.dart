import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/work_order_planning_model.dart';
import '../models/pelaksana_model.dart';
import '../utils/auth_helper.dart';

class WorkOrderDetailItemController extends ChangeNotifier {
  final TextEditingController qtyActualController = TextEditingController();
  final TextEditingController beratActualController = TextEditingController();
  
  // Data item yang sedang diproses
  WorkOrderPlanningItem? _currentItem;
  
  // Data untuk assignment pelaksana (akan diisi dari data asli)
  List<Map<String, dynamic>> assignments = [];

  // List pelaksana yang tersedia dari API
  List<Pelaksana> availablePelaksana = [];

  // Initialize controller dengan data item
  void initializeWithItem(Map<String, dynamic> item) {
    // Simpan data item untuk referensi
    _currentItem = WorkOrderPlanningItem.fromMap(item);
    
    if (item['qtyActual'] != null) {
      qtyActualController.text = item['qtyActual'].toString();
    }
    if (item['beratActual'] != null) {
      beratActualController.text = item['beratActual'].toString();
    }
    
    // Load data pelaksana yang sudah ada dari model
    _loadExistingAssignments();
  }
  
  // Method untuk initialize dengan data dari API response yang sebenarnya
  void initializeWithApiData(Map<String, dynamic> apiItem, {List<Pelaksana>? pelaksanaList}) {
    try {
      // Simpan data item untuk referensi
      _currentItem = WorkOrderPlanningItem.fromMap(apiItem);
      
      // Load data pelaksana yang tersedia dari API
      if (pelaksanaList != null && pelaksanaList.isNotEmpty) {
        availablePelaksana = pelaksanaList;
      } else {
        // Fetch data pelaksana dari API terpisah
        fetchAvailablePelaksana();
      }
      
      // Load data pelaksana yang sudah ada dari API response
      _loadExistingAssignmentsFromApi(apiItem);
      
      // Validasi dan perbaiki assignment yang sudah ada
      _validateAndFixAssignments();
    } catch (e) {
      // Tetap lanjutkan dengan data yang ada
    }
  }
  
  // Method untuk mengekstrak data pelaksana dari API response
  void _extractPelaksanaFromApiResponse(Map<String, dynamic> apiItem) {
    // Coba ambil data pelaksana dari berbagai kemungkinan struktur API
    List<Pelaksana> pelaksanaData = [];
    
    // Cek apakah ada data pelaksana di level work order
    if (apiItem['available_pelaksana'] != null) {
      final availablePelaksanaList = apiItem['available_pelaksana'] as List<dynamic>?;
      if (availablePelaksanaList != null) {
        for (var pelaksana in availablePelaksanaList) {
          pelaksanaData.add(Pelaksana.fromMap(pelaksana as Map<String, dynamic>));
        }
      }
    }
    
    // Jika tidak ada data pelaksana yang tersedia, buat data default
    if (pelaksanaData.isEmpty) {
      // Buat data pelaksana default berdasarkan ID yang ada di has_many_pelaksana
      final existingPelaksanaIds = <int>{};
      if (apiItem['has_many_pelaksana'] != null) {
        final pelaksanaList = apiItem['has_many_pelaksana'] as List<dynamic>?;
        if (pelaksanaList != null) {
          for (var pelaksana in pelaksanaList) {
            final pelaksanaId = pelaksana['pelaksana_id'] as int?;
            if (pelaksanaId != null) {
              existingPelaksanaIds.add(pelaksanaId);
            }
          }
        }
      }
      
      // Buat data pelaksana default untuk ID yang ada
      for (var id in existingPelaksanaIds) {
        pelaksanaData.add(Pelaksana(
          id: id,
          kode: 'PLK$id',
          namaPelaksana: 'Pelaksana $id',
          level: '1',
        ));
      }
    }
    
    // Pastikan tidak ada duplikasi berdasarkan ID
    final uniquePelaksana = <int, Pelaksana>{};
    for (var pelaksana in pelaksanaData) {
      if (!uniquePelaksana.containsKey(pelaksana.id)) {
        uniquePelaksana[pelaksana.id] = pelaksana;
      }
    }
    
    availablePelaksana = uniquePelaksana.values.toList();
  }
  
  // Load data pelaksana yang sudah ada dari API response
  void _loadExistingAssignmentsFromApi(Map<String, dynamic> apiItem) {
    try {
      assignments.clear();
      
      // Ambil data pelaksana dari hasManyPelaksana
      final pelaksanaList = apiItem['hasManyPelaksana'] as List<dynamic>?;
      
      if (pelaksanaList != null && pelaksanaList.isNotEmpty) {
        for (var pelaksanaData in pelaksanaList) {
          try {
            // Ambil nama pelaksana dari data pelaksana yang sudah ada
            String namaPelaksana = 'Pelaksana ${pelaksanaData['pelaksana']['nama_pelaksana']}';
            if (pelaksanaData['pelaksana'] != null) {
              final pelaksanaInfo = pelaksanaData['pelaksana'] as Map<String, dynamic>;
              namaPelaksana = pelaksanaInfo['nama_pelaksana'] ?? namaPelaksana;
              
              // Tambahkan pelaksana ke available list jika belum ada
              final pelaksanaId = pelaksanaData['pelaksana']['id'] as int;
              final existingPelaksana = availablePelaksana.where((p) => p.id == pelaksanaId).isEmpty;
              if (existingPelaksana) {
                availablePelaksana.add(Pelaksana(
                  id: pelaksanaId,
                  kode: pelaksanaInfo['kode'] ?? 'PLK$pelaksanaId',
                  namaPelaksana: namaPelaksana,
                  level: pelaksanaInfo['level'] ?? '1',
                ));
              }
            }
            
            assignments.add({
              'id': pelaksanaData['id'],
              'qty': pelaksanaData['qty'],
              'berat': pelaksanaData['weight'] ?? 0.0,
              'pelaksana': namaPelaksana,
              'pelaksana_id': pelaksanaData['pelaksana_id'],
              'tanggal': _formatDateFromApi(pelaksanaData['tanggal']),
              'jamMulai': pelaksanaData['jam_mulai'],
              'jamSelesai': pelaksanaData['jam_selesai'],
              'catatan': pelaksanaData['catatan'],
              'status': 'assigned',
            });
          } catch (e) {
            // Skip this pelaksana and continue
          }
        }
      }
      
      // Update actual values setelah load assignments
      _updateActualValues();
      notifyListeners();
    } catch (e) {
      // Tetap lanjutkan dengan assignments kosong
      _updateActualValues();
      notifyListeners();
    }
  }
  
  // Load data pelaksana yang sudah ada
  void _loadExistingAssignments() {
    assignments.clear();
    
    if (_currentItem != null && _currentItem!.pelaksana.isNotEmpty) {
      for (var pelaksanaItem in _currentItem!.pelaksana) {
        // Ambil nama pelaksana berdasarkan pelaksana_id
        String namaPelaksana = _getPelaksanaNameById(pelaksanaItem.pelaksanaId);
        
        assignments.add({
          'id': pelaksanaItem.id,
          'qty': pelaksanaItem.qty,
          'berat': pelaksanaItem.weight ?? 0.0,
          'pelaksana': namaPelaksana,
          'pelaksana_id': pelaksanaItem.pelaksanaId,
          'tanggal': _formatDateFromApi(pelaksanaItem.tanggal),
          'jamMulai': pelaksanaItem.jamMulai,
          'jamSelesai': pelaksanaItem.jamSelesai,
          'catatan': pelaksanaItem.catatan,
          'status': 'assigned',
        });
      }
    }
    
    // Update actual values setelah load assignments
    _updateActualValues();
    notifyListeners();
  }
  
  // Helper method untuk format tanggal dari API
  String _formatDateFromApi(String apiDate) {
    try {
      // API mengirim format: "2025-09-14T00:00:00.000000Z"
      // Kita perlu format ke: "2025-09-14"
      final dateTime = DateTime.parse(apiDate);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return apiDate; // Return as is jika parsing gagal
    }
  }
  
  // Helper method untuk mendapatkan nama pelaksana berdasarkan ID
  String _getPelaksanaNameById(int pelaksanaId) {
    // Cari pelaksana berdasarkan ID dari data yang tersedia
    if (availablePelaksana.isNotEmpty) {
      for (var pelaksana in availablePelaksana) {
        if (pelaksana.id == pelaksanaId) {
          return pelaksana.namaPelaksana;
        }
      }
    }
    return 'Pelaksana $pelaksanaId';
  }
  

  // Getter untuk mendapatkan data assignments
  List<Map<String, dynamic>> get getAssignments => assignments;
  
  // Getter untuk mendapatkan available pelaksana
  List<String> get getAvailablePelaksana {
    // Pastikan tidak ada duplikasi dan filter null values
    final names = availablePelaksana
        .map((pelaksana) => pelaksana.namaPelaksana)
        .where((name) => name.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
    
    debugPrint('getAvailablePelaksana: $names');
    debugPrint('getAvailablePelaksana - availablePelaksana count: ${availablePelaksana.length}');
    return names;
  }
  
  // Getter untuk mendapatkan available pelaksana dengan detail
  List<Pelaksana> get getAvailablePelaksanaWithDetails => availablePelaksana;
  
  // Method untuk mengupdate data pelaksana yang tersedia
  void updateAvailablePelaksana(List<Pelaksana> pelaksanaList) {
    availablePelaksana = pelaksanaList;
    notifyListeners();
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
  
  // Method untuk fetch data pelaksana dari API
  Future<void> fetchAvailablePelaksana({BuildContext? context}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        debugPrint('Token autentikasi tidak ditemukan');
        return;
      }

      // Get base URL and endpoint from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final pelaksanaEndpoint = dotenv.env['API_PELAKSANA'] ?? '/api/pelaksana';
      final url = Uri.parse('$baseUrl$pelaksanaEndpoint');
      
      debugPrint('Fetching pelaksana from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('Pelaksana API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle different API response structures
        List<dynamic> pelaksanaList = [];
        if (jsonData['data'] != null) {
          pelaksanaList = jsonData['data'] as List<dynamic>;
        } else if (jsonData is List) {
          pelaksanaList = jsonData;
        }
        
        // Convert to our format
        List<Pelaksana> pelaksanaData = [];
        for (var pelaksana in pelaksanaList) {
          pelaksanaData.add(Pelaksana.fromMap(pelaksana as Map<String, dynamic>));
        }
        
        availablePelaksana = pelaksanaData;
        notifyListeners();
        
        debugPrint('Loaded ${pelaksanaData.length} pelaksana');
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthHelper.handleUnauthorized(context, 'Sesi Anda telah berakhir. Silakan login kembali.');
        }
        debugPrint('Unauthorized: Sesi telah berakhir');
      } else {
        debugPrint('Failed to fetch pelaksana: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching pelaksana: $e');
    }
  }

  // Method untuk mendapatkan icon berdasarkan jenis barang
  IconData getItemIcon(String? jenisBarang) {
    if (jenisBarang == null || jenisBarang.isEmpty) {
      return Icons.inventory;
    }
    
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
  String getLuasSuffix(String? jenisBarang) {
    if (jenisBarang == null || jenisBarang.isEmpty) {
      return '';
    }
    return jenisBarang == 'Aluminium' ? ' (mm²)' : '';
  }

  // Method untuk mendapatkan warna border assignment berdasarkan status
  Color getAssignmentBorderColor(String? status) {
    if (status == null || status.isEmpty) {
      return Colors.grey[600]!;
    }
    
    switch (status) {
      case 'assigned':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'empty':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  // Method untuk menghitung total qty
  int calculateTotalQty() {
    try {
      return assignments.fold(0, (int sum, assignment) {
        final qty = assignment['qty'];
        if (qty is int) {
          return sum + qty;
        } else if (qty is String) {
          return sum + (int.tryParse(qty) ?? 0);
        }
        return sum;
      });
    } catch (e) {
      debugPrint('Error calculating total qty: $e');
      return 0;
    }
  }

  // Method untuk menghitung total assigned
  int calculateTotalAssigned() {
    return assignments.where((assignment) => assignment['status'] == 'assigned').length;
  }

  // Method untuk menambah assignment baru
  void addNewAssignment() {
    assignments.add({
      'id': null, // ID akan di-generate saat save
      'qty': 0,
      'berat': 0.0,
      'pelaksana': null,
      'pelaksana_id': null,
      'tanggal': DateTime.now().toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'jamMulai': '09:00:00',
      'jamSelesai': '17:00:00',
      'catatan': null,
      'status': 'empty',
    });
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk membatalkan assignment
  void cancelAssignment(int index) {
    assignments[index]['status'] = 'pending';
    assignments[index]['qty'] = 0;
    assignments[index]['berat'] = 0.0;
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk menetapkan task
  void assignTask(int index) {
    assignments[index]['status'] = 'assigned';
    notifyListeners();
  }

  // Method untuk menghapus assignment
  void deleteAssignment(int index) {
    assignments.removeAt(index);
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk update qty assignment
  void updateAssignmentQty(int index, String value) {
    assignments[index]['qty'] = int.tryParse(value) ?? 0;
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk update berat assignment
  void updateAssignmentBerat(int index, String value) {
    assignments[index]['berat'] = double.tryParse(value) ?? 0.0;
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk update pelaksana assignment
  void updateAssignmentPelaksana(int index, String? newValue) {
    // Validasi bahwa nilai yang dipilih ada dalam daftar available pelaksana
    if (newValue != null && !getAvailablePelaksana.contains(newValue)) {
      debugPrint('Warning: Selected pelaksana "$newValue" not found in available list');
      // Reset ke null jika tidak valid
      newValue = null;
    }
    
    assignments[index]['pelaksana'] = newValue;
    
    // Update pelaksana_id juga jika ada
    if (newValue != null) {
      // Cari ID pelaksana berdasarkan nama
      for (var pelaksana in availablePelaksana) {
        if (pelaksana.namaPelaksana == newValue) {
          assignments[index]['pelaksana_id'] = pelaksana.id;
          break;
        }
      }
    } else {
      assignments[index]['pelaksana_id'] = null;
    }
    notifyListeners();
  }

  // Method untuk validasi dan memperbaiki assignment yang sudah ada
  void _validateAndFixAssignments() {
    final availableNames = getAvailablePelaksana;
    debugPrint('_validateAndFixAssignments - Available names: $availableNames');
    debugPrint('_validateAndFixAssignments - Current assignments: ${assignments.map((a) => a['pelaksana']).toList()}');
    
    for (int i = 0; i < assignments.length; i++) {
      final assignment = assignments[i];
      final currentPelaksana = assignment['pelaksana'] as String?;
      
      debugPrint('_validateAndFixAssignments - Assignment $i: $currentPelaksana');
      
      // Hanya reset jika pelaksana tidak valid dan bukan dari data yang sudah ada
      if (currentPelaksana != null && !availableNames.contains(currentPelaksana)) {
        debugPrint('_validateAndFixAssignments - Invalid pelaksana "$currentPelaksana" found, but keeping it as it might be from existing data');
        // Jangan reset, biarkan data yang sudah ada tetap ada
        // assignments[i]['pelaksana'] = null;
        // assignments[i]['pelaksana_id'] = null;
      }
    }
    
    debugPrint('_validateAndFixAssignments - Final assignments: ${assignments.map((a) => a['pelaksana']).toList()}');
    _updateActualValues();
    notifyListeners();
  }

  // Method untuk mengupdate actual qty dan weight berdasarkan assignments
  void _updateActualValues() {
    int totalQty = 0;
    double totalWeight = 0.0;
    
    // Hitung total dari semua assignment yang memiliki pelaksana
    for (var assignment in assignments) {
      if (assignment['pelaksana'] != null && assignment['pelaksana'].toString().isNotEmpty) {
        final qty = assignment['qty'];
        final berat = assignment['berat'];
        
        if (qty is int) {
          totalQty += qty;
        } else if (qty is String) {
          totalQty += int.tryParse(qty) ?? 0;
        }
        
        if (berat is double) {
          totalWeight += berat;
        } else if (berat is String) {
          totalWeight += double.tryParse(berat) ?? 0.0;
        }
      }
    }
    
    // Update controller text fields
    qtyActualController.text = totalQty.toString();
    beratActualController.text = totalWeight.toString();
    
    debugPrint('_updateActualValues - Total Qty: $totalQty, Total Weight: $totalWeight');
  }

  // Method untuk validasi input
  bool validateInput() {
    return qtyActualController.text.isNotEmpty && beratActualController.text.isNotEmpty;
  }

  // Method untuk mendapatkan message error validasi
  String getValidationErrorMessage() {
    return 'Mohon isi Qty Actual dan Berat Actual';
  }

  // Method untuk mendapatkan message success
  String getSuccessMessage(int itemIndex) {
    return 'Detail Item ${itemIndex + 1} berhasil disimpan sementara!';
  }

  // Method untuk menyimpan data sementara ke SharedPreferences
  Future<void> saveTemporaryData(int workOrderId, int itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Buat key untuk data sementara berdasarkan work order ID dan item ID
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${itemId}';
      
      // Siapkan data yang akan disimpan
      final tempData = {
        'qtyActual': qtyActualController.text,
        'beratActual': beratActualController.text,
        'assignments': assignments,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      debugPrint('Saving temporary data with key: $tempDataKey');
      debugPrint('Data to save: $tempData');
      debugPrint('Qty Actual: ${qtyActualController.text}');
      debugPrint('Berat Actual: ${beratActualController.text}');
      
      // Simpan ke SharedPreferences
      await prefs.setString(tempDataKey, json.encode(tempData));
      
      // Verifikasi bahwa data benar-benar tersimpan
      final savedData = prefs.getString(tempDataKey);
      debugPrint('Verification - saved data: $savedData');
      
      debugPrint('Data sementara disimpan untuk work order $workOrderId, item $itemId');
    } catch (e) {
      debugPrint('Error saving temporary data: $e');
    }
  }

  // Method untuk memuat data sementara dari SharedPreferences
  Future<void> loadTemporaryData(int workOrderId, int itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${itemId}';
      
      final tempDataString = prefs.getString(tempDataKey);
      if (tempDataString != null) {
        final tempData = json.decode(tempDataString) as Map<String, dynamic>;
        
        // Load assignments terlebih dahulu
        if (tempData['assignments'] != null) {
          assignments = List<Map<String, dynamic>>.from(
            (tempData['assignments'] as List).map((item) => Map<String, dynamic>.from(item))
          );
        }
        
        // Update actual values berdasarkan assignments
        _updateActualValues();
        
        notifyListeners();
        debugPrint('Data sementara dimuat untuk work order $workOrderId, item $itemId');
      }
    } catch (e) {
      debugPrint('Error loading temporary data: $e');
    }
  }

  // Method untuk menghapus data sementara
  Future<void> clearTemporaryData(int workOrderId, int itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempDataKey = 'temp_work_order_${workOrderId}_item_${itemId}';
      
      await prefs.remove(tempDataKey);
      debugPrint('Data sementara dihapus untuk work order $workOrderId, item $itemId');
    } catch (e) {
      debugPrint('Error clearing temporary data: $e');
    }
  }

  // Method untuk mendapatkan data yang akan dikirim ke API
  Map<String, dynamic> getDataForApi() {
    return {
      'qtyActual': qtyActualController.text,
      'beratActual': beratActualController.text,
      'assignments': assignments,
    };
  }

  @override
  void dispose() {
    qtyActualController.dispose();
    beratActualController.dispose();
    super.dispose();
  }
}
