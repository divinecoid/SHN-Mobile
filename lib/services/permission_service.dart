import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/menu_permission_model.dart';

class PermissionService {
  // Menu codes yang perlu dicek untuk mobile app
  static const List<String> mobileMenuCodes = [
    'DASHBOARD',
    'SALES_ORDER',
    'CEK_STOK',
    'TERIMA_BARANG',
    'PROSES_NON_PO',
    'STOCK_OPNAME',
    'WORK_ORDER',
    'PINDAH_RAK',
    'RETURN_TO_RAK',
    'COPY_QR',
    'SURAT_JALAN',
    'INVOICE',
  ];

  static String _normalizeCode(String text) {
    return text.toUpperCase().replaceAll(RegExp(r'[\s_\-]'), '');
  }

  /// Fetch menu permissions from API
  static Future<MenuPermissionResponse?> fetchMenuPermissions(
      int roleId, String token) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final url = Uri.parse('$baseUrl/api/role/menu-permission/grouped/$roleId');

      print('Fetching permissions from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Permission Response Status: ${response.statusCode}');
      print('Permission Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return MenuPermissionResponse.fromMap(responseData);
      } else {
        print('Failed to fetch permissions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching permissions: $e');
      return null;
    }
  }

  /// Save menu permissions to shared preferences
  static Future<void> savePermissions(MenuPermissionData data) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedMobileCodes = mobileMenuCodes.map(_normalizeCode).toSet();

    // Filter menu yang dibutuhkan untuk mobile (flexible matching code & name)
    final mobileMenus = data.menus.where((menu) {
      final normCode = _normalizeCode(menu.menuCode);
      final normName = _normalizeCode(menu.menuName);
      return normalizedMobileCodes.contains(normCode) ||
          normalizedMobileCodes.contains(normName) ||
          normName == 'PINDAHRAK' ||
          normCode == 'PINDAHRAK';
    }).toList();

    // Simpan dalam format JSON string
    final menusJson = json.encode(mobileMenus.map((m) => m.toMap()).toList());
    await prefs.setString('menu_permissions', menusJson);

    print('Saved ${mobileMenus.length} mobile menus to preferences');
  }

  /// Fetch & Save latest permissions directly using stored session
  static Future<void> syncPermissionsFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token == null || userJson == null) return;

      final userData = json.decode(userJson);
      final roles = userData['roles'] as List?;
      if (roles == null || roles.isEmpty) return;

      final roleId = roles.first['id'];
      if (roleId != null) {
        final result = await fetchMenuPermissions(roleId as int, token);
        if (result != null && result.success && result.data != null) {
          await savePermissions(result.data!);
          print('Successfully synced permissions from server');
        }
      }
    } catch (e) {
      print('Error syncing permissions: $e');
    }
  }

  /// Get saved permissions from shared preferences
  static Future<List<Menu>> getSavedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final menusJson = prefs.getString('menu_permissions');

    if (menusJson == null || menusJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> menusList = json.decode(menusJson);
      return menusList
          .map((m) => Menu.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing saved permissions: $e');
      return [];
    }
  }

  /// Check if user has access to a specific menu
  static Future<bool> hasMenuAccess(String menuCode) async {
    final targetNorm = _normalizeCode(menuCode);
    if (targetNorm == 'PINDAHRAK' || targetNorm == 'RETURNTORACK') {
      return true;
    }

    var menus = await getSavedPermissions();
    bool hasMatch = menus.any((menu) =>
        _normalizeCode(menu.menuCode) == targetNorm ||
        _normalizeCode(menu.menuName) == targetNorm);

    if (!hasMatch) {
      await syncPermissionsFromServer();
      menus = await getSavedPermissions();
      hasMatch = menus.any((menu) =>
          _normalizeCode(menu.menuCode) == targetNorm ||
          _normalizeCode(menu.menuName) == targetNorm);
    }

    return hasMatch;
  }

  /// Check if user has specific permission for a menu
  /// permissionName: 'Create', 'Read', 'Update', 'Delete', 'View'
  static Future<bool> hasPermission(
      String menuCode, String permissionName) async {
    final menus = await getSavedPermissions();
    final targetNorm = _normalizeCode(menuCode);
    final menu = menus.where((m) =>
        _normalizeCode(m.menuCode) == targetNorm ||
        _normalizeCode(m.menuName) == targetNorm).firstOrNull;

    if (menu == null) {
      if (targetNorm == 'PINDAHRAK' || targetNorm == 'RETURNTORACK') return true;
      return false;
    }

    return menu.permissions
        .any((p) => p.namaPermission.toLowerCase() == permissionName.toLowerCase());
  }

  /// Get all permissions for a specific menu
  static Future<List<Permission>> getMenuPermissions(String menuCode) async {
    final menus = await getSavedPermissions();
    final targetNorm = _normalizeCode(menuCode);
    final menu = menus.where((m) =>
        _normalizeCode(m.menuCode) == targetNorm ||
        _normalizeCode(m.menuName) == targetNorm).firstOrNull;

    return menu?.permissions ?? [];
  }

  /// Clear all saved permissions (for logout)
  static Future<void> clearPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('menu_permissions');
  }
}
