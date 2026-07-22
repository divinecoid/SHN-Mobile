import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_barang_model.dart';
import '../models/pindah_rak_model.dart';
import '../utils/auth_helper.dart';

class PindahRakController extends ChangeNotifier {
  ItemBarang? _scannedItem;
  RakDetailInfo? _targetRak;

  bool _isLoadingItem = false;
  bool _isLoadingRak = false;
  bool _isSubmitting = false;

  String? _errorMessage;
  String? _validationError;

  // Getters
  ItemBarang? get scannedItem => _scannedItem;
  RakDetailInfo? get targetRak => _targetRak;

  bool get isLoadingItem => _isLoadingItem;
  bool get isLoadingRak => _isLoadingRak;
  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;
  String? get validationError => _validationError;

  bool get canSubmit =>
      _scannedItem != null &&
      _targetRak != null &&
      _validationError == null &&
      !_isSubmitting;

  /// Private helper untuk mendapatkan auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Private helper untuk mendapatkan base URL
  String _getBaseUrl() {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
  }

  /// Reset semua state
  void reset() {
    _scannedItem = null;
    _targetRak = null;
    _isLoadingItem = false;
    _isLoadingRak = false;
    _isSubmitting = false;
    _errorMessage = null;
    _validationError = null;
    notifyListeners();
  }

  /// Reset hanya rak tujuan
  void resetRakTujuan() {
    _targetRak = null;
    _isLoadingRak = false;
    _validationError = null;
    notifyListeners();
  }

  /// Fetch Item Barang berdasarkan QR Code (String kode barang)
  Future<bool> fetchItemByKode(String kodeBarang, BuildContext context) async {
    _isLoadingItem = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Token autentikasi tidak ditemukan. Silakan login kembali.';
        _isLoadingItem = false;
        notifyListeners();
        return false;
      }

      final baseUrl = _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/item-barang/qr-data-by-kode/$kodeBarang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _scannedItem = ItemBarang.fromMap(data['data'] as Map<String, dynamic>);
          _isLoadingItem = false;
          
          // Re-validate rak if targetRak was scanned already
          _validateRak();
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Barang tidak ditemukan';
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        if (context.mounted) {
          await AuthHelper.handleSessionExpired(context);
        }
        return false;
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Gagal mengambil data barang (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoadingItem = false;
      notifyListeners();
    }
    return false;
  }

  /// Fetch Rak berdasarkan Kode Rak dari QR
  Future<bool> fetchRakByKode(String kodeRak, BuildContext context) async {
    _isLoadingRak = true;
    _errorMessage = null;
    _validationError = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Token autentikasi tidak ditemukan.';
        _isLoadingRak = false;
        notifyListeners();
        return false;
      }

      final baseUrl = _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/api/rak/search-by-kode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'kode': kodeRak}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _targetRak = RakDetailInfo.fromJson(data['data'] as Map<String, dynamic>);
          _isLoadingRak = false;
          
          // Jalankan validasi
          _validateRak();
          notifyListeners();
          return _validationError == null;
        } else {
          _errorMessage = data['message'] ?? 'Rak tidak ditemukan';
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        if (context.mounted) {
          await AuthHelper.handleSessionExpired(context);
        }
        return false;
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Rak dengan kode "$kodeRak" tidak ditemukan';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoadingRak = false;
      notifyListeners();
    }
    return false;
  }

  /// Validasi rak tujuan vs rak asal
  void _validateRak() {
    _validationError = null;

    if (_scannedItem == null || _targetRak == null) {
      return;
    }

    // Jika rak sebelumnya NULL -> TIDAK PERLU VALIDASI GUDANG
    if (_scannedItem!.rakId == null) {
      return;
    }

    // Jika rak sebelumnya ADA -> Rak tujuan HARUS di gudang yang sama
    if (_targetRak!.gudangId != 0 && _targetRak!.gudangId != _scannedItem!.gudangId) {
      _validationError =
          'Rak tujuan (${_targetRak!.namaGudang ?? 'Gudang Lain'}) harus berada di gudang yang sama dengan rak sebelumnya (${_scannedItem!.gudang?.namaGudang ?? 'Gudang Awal'})!';
    }
  }

  /// Submit Pindah Rak ke Backend
  Future<bool> submitPindahRak(BuildContext context) async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Token autentikasi tidak ditemukan.';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      final baseUrl = _getBaseUrl();
      final itemId = _scannedItem!.id;
      final response = await http.patch(
        Uri.parse('$baseUrl/api/item-barang/$itemId/pindah-rak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id_rak': _targetRak!.id,
          'gudang_id': _targetRak!.gudangId != 0 ? _targetRak!.gudangId : _scannedItem!.gudangId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _isSubmitting = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Gagal memindahkan rak';
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        if (context.mounted) {
          await AuthHelper.handleSessionExpired(context);
        }
        return false;
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Gagal memindahkan rak (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return false;
  }
}
