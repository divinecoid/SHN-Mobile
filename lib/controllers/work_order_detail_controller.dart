import 'package:flutter/material.dart';

class WorkOrderDetailController extends ChangeNotifier {
  // Data dummy untuk detail item work order
  final List<Map<String, dynamic>> workOrderItems = [
    {
      'jenisBarang': 'Aluminium',
      'bentukBarang': 'PLAT',
      'grade': '1100',
      'ukuran': '150 x 120 x 20',
      'qtyPlanning': 10,
      'qtyActual': null,
      'beratPlanning': 150,
      'beratActual': null,
      'luas': null,
      'platShaftDasar': '<nama itembrg>',
    },
    {
      'jenisBarang': 'Aluminium',
      'bentukBarang': 'PLAT',
      'grade': '2024',
      'ukuran': '200 x 300 x 20',
      'qtyPlanning': 2,
      'qtyActual': null,
      'beratPlanning': 50,
      'beratActual': null,
      'luas': 60000,
      'platShaftDasar': '<nama itembrg>',
    },
  ];



  // Getter untuk mendapatkan data work order items
  List<Map<String, dynamic>> get getWorkOrderItems => workOrderItems;

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


}
