import 'package:flutter/material.dart';

class HomeController {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  String getCurrentPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Terima Barang';
      case 1:
        return 'Mutasi Barang';
      case 2:
        return 'Stock Opname';
      case 3:
        return 'Work Order';
      default:
        return 'SHN Mobile';
    }
  }
} 