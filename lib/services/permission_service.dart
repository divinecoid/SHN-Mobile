import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/menu_permission_model.dart';

class PermissionService {
  // Menu codes yang perlu dicek untuk mobile app
  static const List<String> mobileMenuCodes = [
    'DASHBOARD',
    'CEK_STOK',
    'TERIMA_BARANG',
    'STOCK_OPNAME',
    'WORK_ORDER',
  ];

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

    // Filter hanya menu yang dibutuhkan untuk mobile
    final mobileMenus = data.menus
        .where((menu) => mobileMenuCodes.contains(menu.menuCode))
        .toList();

    // Simpan dalam format JSON string
    final menusJson = json.encode(mobileMenus.map((m) => m.toMap()).toList());
    await prefs.setString('menu_permissions', menusJson);

    print('Saved ${mobileMenus.length} mobile menus to preferences');
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
    final menus = await getSavedPermissions();
    return menus.any((menu) => menu.menuCode == menuCode);
  }

  /// Check if user has specific permission for a menu
  /// permissionName: 'Create', 'Read', 'Update', 'Delete', 'View'
  static Future<bool> hasPermission(
      String menuCode, String permissionName) async {
    final menus = await getSavedPermissions();
    final menu = menus.where((m) => m.menuCode == menuCode).firstOrNull;

    if (menu == null) return false;

    return menu.permissions
        .any((p) => p.namaPermission.toLowerCase() == permissionName.toLowerCase());
  }

  /// Get all permissions for a specific menu
  static Future<List<Permission>> getMenuPermissions(String menuCode) async {
    final menus = await getSavedPermissions();
    final menu = menus.where((m) => m.menuCode == menuCode).firstOrNull;

    return menu?.permissions ?? [];
  }

  /// Clear all saved permissions (for logout)
  static Future<void> clearPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('menu_permissions');
  }
}
