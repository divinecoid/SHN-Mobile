import 'package:flutter/material.dart';

class WorkOrderDetailItemController extends ChangeNotifier {
  final TextEditingController qtyActualController = TextEditingController();
  final TextEditingController beratActualController = TextEditingController();
  
  // Data untuk assignment pelaksana
  final List<Map<String, dynamic>> assignments = [
    {'qty': 3, 'berat': 30, 'pelaksana': 'Agus', 'status': 'assigned'},
    {'qty': 7, 'berat': 70, 'pelaksana': 'Rina', 'status': 'pending'},
  ];

  // List pelaksana yang tersedia
  final List<String> availablePelaksana = [
    'Agus',
    'Rina',
    'Budi',
    'Siti',
    'Joko',
    'Joni',
  ];

  // Initialize controller dengan data item
  void initializeWithItem(Map<String, dynamic> item) {
    if (item['qtyActual'] != null) {
      qtyActualController.text = item['qtyActual'].toString();
    }
    if (item['beratActual'] != null) {
      beratActualController.text = item['beratActual'].toString();
    }
  }

  // Getter untuk mendapatkan data assignments
  List<Map<String, dynamic>> get getAssignments => assignments;
  
  // Getter untuk mendapatkan available pelaksana
  List<String> get getAvailablePelaksana => availablePelaksana;

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
      'qty': 0,
      'berat': 0.0,
      'pelaksana': null,
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
    assignments[index]['pelaksana'] = newValue;
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
