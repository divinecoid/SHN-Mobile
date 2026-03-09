import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/item_barang_model.dart';
import '../utils/auth_helper.dart';

class CopyQrController extends ChangeNotifier {
  ItemBarang? _itemBarang;
  bool _isLoading = false;
  String _errorMessage = '';

  ItemBarang? get itemBarang => _itemBarang;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void clearData() {
    _itemBarang = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> fetchItemByKode(BuildContext context, String kode) async {
    _isLoading = true;
    _errorMessage = '';
    _itemBarang = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.232.105.4:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/api/item-barang/qr-data-by-kode/$kode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _itemBarang = ItemBarang.fromMap(data['data']);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Data barang tidak ditemukan.';
        }
      } else if (response.statusCode == 401) {
         if (context.mounted) {
           await AuthHelper.handleUnauthorized(context, null);
         }
      } else if (response.statusCode == 404) {
        _errorMessage = 'Item barang dengan kode $kode tidak ditemukan.';
      } else {
         _errorMessage = 'Gagal mengambil data dari server (${response.statusCode}).';
      }
    } catch (e) {
      debugPrint('Error fetching item by kode: $e');
      _errorMessage = 'Terjadi kesalahan sistem: $e';
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return false;
  }
}
