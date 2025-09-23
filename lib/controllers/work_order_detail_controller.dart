import 'package:flutter/material.dart';
import '../models/work_order_planning_model.dart';

class WorkOrderDetailController extends ChangeNotifier {
  List<WorkOrderPlanningItem> _workOrderItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter untuk mendapatkan data work order items
  List<Map<String, dynamic>> get getWorkOrderItems {
    return _workOrderItems.map((item) => _convertItemToMap(item)).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method untuk mengkonversi WorkOrderPlanningItem ke Map untuk UI
  Map<String, dynamic> _convertItemToMap(WorkOrderPlanningItem item) {
    // Hitung ukuran dari panjang, lebar, tebal
    final ukuran = '${item.panjang} x ${item.lebar} x ${item.tebal}';
    
    // Hitung luas dari panjang x lebar
    final luas = double.tryParse(item.panjang) != null && double.tryParse(item.lebar) != null
        ? (double.parse(item.panjang) * double.parse(item.lebar))
        : null;

    return {
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

}
