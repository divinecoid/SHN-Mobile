import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/work_order_planning_model.dart';

class WorkOrderDetailItemController extends ChangeNotifier {
  final TextEditingController qtyActualController = TextEditingController();
  final TextEditingController beratActualController = TextEditingController();
  
  // Data item yang sedang diproses
  WorkOrderPlanningItem? _currentItem;
  
  // Data untuk assignment pelaksana (akan diisi dari data asli)
  List<Map<String, dynamic>> assignments = [];

  // List pelaksana yang tersedia dari API
  List<Map<String, dynamic>> availablePelaksana = [];

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
  void initializeWithApiData(Map<String, dynamic> apiItem, {List<Map<String, dynamic>>? pelaksanaList}) {
    // Debug: Print data yang diterima
    debugPrint('WorkOrderDetailItemController - Data item yang diterima:');
    debugPrint('Keys: ${apiItem.keys.toList()}');
    debugPrint('hasManyPelaksana: ${apiItem['hasManyPelaksana']}');
    
    // Simpan data item untuk referensi
    _currentItem = WorkOrderPlanningItem.fromMap(apiItem);
    
    // Load data pelaksana yang tersedia dari API
    if (pelaksanaList != null) {
      availablePelaksana = pelaksanaList;
    } else {
      // Fetch data pelaksana dari API terpisah
      fetchAvailablePelaksana();
    }
    
    // Load data pelaksana yang sudah ada dari API response
    _loadExistingAssignmentsFromApi(apiItem);
    
    // Validasi dan perbaiki assignment yang sudah ada
    _validateAndFixAssignments();
  }
  
  // Method untuk mengekstrak data pelaksana dari API response
  void _extractPelaksanaFromApiResponse(Map<String, dynamic> apiItem) {
    // Coba ambil data pelaksana dari berbagai kemungkinan struktur API
    List<Map<String, dynamic>> pelaksanaData = [];
    
    // Cek apakah ada data pelaksana di level work order
    if (apiItem['available_pelaksana'] != null) {
      final availablePelaksanaList = apiItem['available_pelaksana'] as List<dynamic>?;
      if (availablePelaksanaList != null) {
        for (var pelaksana in availablePelaksanaList) {
          pelaksanaData.add({
            'id': pelaksana['id'],
            'kode': pelaksana['kode'],
            'nama': pelaksana['nama_pelaksana'] ?? pelaksana['nama'],
            'jabatan': pelaksana['jabatan'],
            'departemen': pelaksana['departemen'],
            'level': pelaksana['level'],
          });
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
        pelaksanaData.add({
          'id': id,
          'kode': 'PLK$id',
          'nama': 'Pelaksana $id',
          'jabatan': null,
          'departemen': null,
          'level': null,
        });
      }
    }
    
    // Pastikan tidak ada duplikasi berdasarkan ID
    final uniquePelaksana = <int, Map<String, dynamic>>{};
    for (var pelaksana in pelaksanaData) {
      final id = pelaksana['id'] as int;
      if (!uniquePelaksana.containsKey(id)) {
        uniquePelaksana[id] = pelaksana;
      }
    }
    
    availablePelaksana = uniquePelaksana.values.toList();
  }
  
  // Load data pelaksana yang sudah ada dari API response
  void _loadExistingAssignmentsFromApi(Map<String, dynamic> apiItem) {
    assignments.clear();
    
    // Debug: Print data pelaksana
    debugPrint('_loadExistingAssignmentsFromApi - hasManyPelaksana: ${apiItem['hasManyPelaksana']}');
    
    // Ambil data pelaksana dari hasManyPelaksana
    final pelaksanaList = apiItem['hasManyPelaksana'] as List<dynamic>?;
    
    debugPrint('_loadExistingAssignmentsFromApi - pelaksanaList: $pelaksanaList');
    debugPrint('_loadExistingAssignmentsFromApi - pelaksanaList length: ${pelaksanaList?.length ?? 0}');
    
    if (pelaksanaList != null && pelaksanaList.isNotEmpty) {
      for (var pelaksanaData in pelaksanaList) {
        // Ambil nama pelaksana berdasarkan pelaksana_id
        String namaPelaksana = _getPelaksanaNameById(pelaksanaData['pelaksana_id']);
        
        debugPrint('_loadExistingAssignmentsFromApi - Adding assignment: $namaPelaksana');
        
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
      }
    }
    
    debugPrint('_loadExistingAssignmentsFromApi - Final assignments: ${assignments.length}');
    notifyListeners();
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
    for (var pelaksana in availablePelaksana) {
      if (pelaksana['id'] == pelaksanaId) {
        return pelaksana['nama_pelaksana'] ?? pelaksana['nama'] ?? 'Pelaksana $pelaksanaId';
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
        .map((pelaksana) => pelaksana['nama'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toSet() // Remove duplicates
        .toList();
    
    debugPrint('getAvailablePelaksana: $names');
    return names;
  }
  
  // Getter untuk mendapatkan available pelaksana dengan detail
  List<Map<String, dynamic>> get getAvailablePelaksanaWithDetails => availablePelaksana;
  
  // Method untuk mengupdate data pelaksana yang tersedia
  void updateAvailablePelaksana(List<Map<String, dynamic>> pelaksanaList) {
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
  Future<void> fetchAvailablePelaksana() async {
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
        List<Map<String, dynamic>> pelaksanaData = [];
        for (var pelaksana in pelaksanaList) {
          pelaksanaData.add({
            'id': pelaksana['id'],
            'kode': pelaksana['kode'],
            'nama': pelaksana['nama_pelaksana'],
            'nama_pelaksana': pelaksana['nama_pelaksana'],
            'jabatan': pelaksana['jabatan'],
            'departemen': pelaksana['departemen'],
            'level': pelaksana['level'],
          });
        }
        
        availablePelaksana = pelaksanaData;
        notifyListeners();
        
        debugPrint('Loaded ${pelaksanaData.length} pelaksana');
      } else {
        debugPrint('Failed to fetch pelaksana: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching pelaksana: $e');
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

  // Method untuk mendapatkan warna border assignment berdasarkan status
  Color getAssignmentBorderColor(String status) {
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
    return assignments.fold(0, (int sum, assignment) => sum + (assignment['qty'] as int));
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
    notifyListeners();
  }

  // Method untuk membatalkan assignment
  void cancelAssignment(int index) {
    assignments[index]['status'] = 'pending';
    assignments[index]['qty'] = 0;
    assignments[index]['berat'] = 0.0;
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
    notifyListeners();
  }

  // Method untuk update qty assignment
  void updateAssignmentQty(int index, String value) {
    assignments[index]['qty'] = int.tryParse(value) ?? 0;
    notifyListeners();
  }

  // Method untuk update berat assignment
  void updateAssignmentBerat(int index, String value) {
    assignments[index]['berat'] = double.tryParse(value) ?? 0.0;
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
        if (pelaksana['nama'] == newValue) {
          assignments[index]['pelaksana_id'] = pelaksana['id'];
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
    
    for (int i = 0; i < assignments.length; i++) {
      final assignment = assignments[i];
      final currentPelaksana = assignment['pelaksana'] as String?;
      
      debugPrint('_validateAndFixAssignments - Assignment $i: $currentPelaksana');
      
      if (currentPelaksana != null && !availableNames.contains(currentPelaksana)) {
        debugPrint('_validateAndFixAssignments - Invalid pelaksana "$currentPelaksana" found, resetting to null');
        assignments[i]['pelaksana'] = null;
        assignments[i]['pelaksana_id'] = null;
      }
    }
    
    debugPrint('_validateAndFixAssignments - Final assignments: ${assignments.map((a) => a['pelaksana']).toList()}');
    notifyListeners();
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
    return 'Detail Item ${itemIndex + 1} berhasil disimpan!';
  }

  @override
  void dispose() {
    qtyActualController.dispose();
    beratActualController.dispose();
    super.dispose();
  }
}
