import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_barang_model.dart';
import '../models/pindah_rak_model.dart';
import '../utils/auth_helper.dart';

class ReturnToRackController extends ChangeNotifier {
  ItemBarang? _scannedItem;
  RakDetailInfo? _targetRak;

  bool _isLoadingItem = false;
  bool _isLoadingRak = false;
  bool _isSubmitting = false;
  bool _isLoadingHistory = false;

  String? _errorMessage;
  String? _successMessage;
  String _catatan = "";
  List<dynamic> _history = [];

  // Getters
  ItemBarang? get scannedItem => _scannedItem;
  RakDetailInfo? get targetRak => _targetRak;

  bool get isLoadingItem => _isLoadingItem;
  bool get isLoadingRak => _isLoadingRak;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingHistory => _isLoadingHistory;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get catatan => _catatan;
  List<dynamic> get history => _history;

  bool get canSubmit =>
      _scannedItem != null &&
      _targetRak != null &&
      !_isSubmitting;

  set catatan(String val) {
    _catatan = val;
    notifyListeners();
  }

  /// Private helper untuk mendapatkan auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Private helper untuk mendapatkan base URL
  String _getBaseUrl() {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
  }

  /// Reset semua state form
  void reset() {
    _scannedItem = null;
    _targetRak = null;
    _isLoadingItem = false;
    _isLoadingRak = false;
    _isSubmitting = false;
    _errorMessage = null;
    _successMessage = null;
    _catatan = "";
    notifyListeners();
  }

  /// Fetch Item Barang berdasarkan QR Code (String kode barang)
  Future<bool> fetchItemByKode(String kodeBarang, BuildContext context) async {
    _isLoadingItem = true;
    _errorMessage = null;
    _successMessage = null;
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
    _successMessage = null;
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
          notifyListeners();
          return true;
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

  /// Submit Kembalikan Barang ke Rak ke Backend
  Future<bool> submitReturnToRack(BuildContext context) async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/work-order-actual/return-to-rack'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'item_barang_id': _scannedItem!.id,
          'rak_id': _targetRak!.id,
          'catatan': _catatan.isNotEmpty ? _catatan : null,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['data'] != null) {
          _successMessage = 'Barang ${_scannedItem!.kodeBarang} berhasil dikembalikan ke rak ${_targetRak!.kode}.';
          reset();
          fetchHistory(context);
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Gagal mengembalikan barang ke rak';
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        if (context.mounted) {
          await AuthHelper.handleSessionExpired(context);
        }
        return false;
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Gagal mengembalikan barang ke rak (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return false;
  }

  /// Fetch Riwayat Pengembalian Barang ke Rak
  Future<void> fetchHistory(BuildContext context) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _isLoadingHistory = false;
        notifyListeners();
        return;
      }

      final baseUrl = _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/work-order-actual/return-history?per_page=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _history = data['data'] as List<dynamic>;
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        if (context.mounted) {
          await AuthHelper.handleSessionExpired(context);
        }
      }
    } catch (e) {
      debugPrint('Error fetchHistory: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
}
