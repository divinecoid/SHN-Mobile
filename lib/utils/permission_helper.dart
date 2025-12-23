import 'package:flutter/material.dart';
import '../services/permission_service.dart';

/// Example helper class untuk mengecek permissions di UI
class PermissionHelper {
  /// Check if user can access Dashboard
  static Future<bool> canAccessDashboard() async {
    return await PermissionService.hasMenuAccess('DASHBOARD');
  }

  /// Check if user can access Cek Stok
  static Future<bool> canAccessCekStok() async {
    return await PermissionService.hasMenuAccess('CEK_STOK');
  }

  /// Check if user can access Terima Barang
  static Future<bool> canAccessTerimaBarang() async {
    return await PermissionService.hasMenuAccess('TERIMA_BARANG');
  }

  /// Check if user can access Stock Opname
  static Future<bool> canAccessStockOpname() async {
    return await PermissionService.hasMenuAccess('STOCK_OPNAME');
  }

  /// Check if user can access Work Order
  static Future<bool> canAccessWorkOrder() async {
    return await PermissionService.hasMenuAccess('WORK_ORDER');
  }

  /// Example: Check if user can create in Terima Barang
  static Future<bool> canCreateTerimaBarang() async {
    return await PermissionService.hasPermission('TERIMA_BARANG', 'Create');
  }

  /// Example: Check if user can read Stock Opname
  static Future<bool> canReadStockOpname() async {
    return await PermissionService.hasPermission('STOCK_OPNAME', 'Read');
  }

  /// Example: Check if user can update Work Order
  static Future<bool> canUpdateWorkOrder() async {
    return await PermissionService.hasPermission('WORK_ORDER', 'Update');
  }

  /// Example: Check if user can delete Stock Opname
  static Future<bool> canDeleteStockOpname() async {
    return await PermissionService.hasPermission('STOCK_OPNAME', 'Delete');
  }
}

/// Example Widget yang menggunakan permission check
class ProtectedButton extends StatelessWidget {
  final String menuCode;
  final String permissionName;
  final VoidCallback onPressed;
  final String label;

  const ProtectedButton({
    super.key,
    required this.menuCode,
    required this.permissionName,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PermissionService.hasPermission(menuCode, permissionName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final hasPermission = snapshot.data ?? false;

        if (!hasPermission) {
          return const SizedBox.shrink(); // Hide button if no permission
        }

        return ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        );
      },
    );
  }
}

/// Example penggunaan di page
/// 
/// ```dart
/// // Cek apakah user bisa akses menu
/// final canAccess = await PermissionHelper.canAccessDashboard();
/// if (!canAccess) {
///   // Tampilkan error atau redirect
///   Navigator.pop(context);
///   return;
/// }
/// 
/// // Di dalam widget
/// ProtectedButton(
///   menuCode: 'TERIMA_BARANG',
///   permissionName: 'Create',
///   label: 'Tambah Barang Baru',
///   onPressed: () {
///     // Action untuk create
///   },
/// )
/// ```
