class Permission {
  final int permissionId;
  final String namaPermission;

  Permission({
    required this.permissionId,
    required this.namaPermission,
  });

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      permissionId: map['permission_id'] ?? 0,
      namaPermission: map['nama_permission'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'permission_id': permissionId,
      'nama_permission': namaPermission,
    };
  }
}

class Menu {
  final int menuId;
  final String menuCode;
  final String menuName;
  final List<Permission> permissions;

  Menu({
    required this.menuId,
    required this.menuCode,
    required this.menuName,
    required this.permissions,
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      menuId: map['menu_id'] ?? 0,
      menuCode: map['menu_code'] ?? '',
      menuName: map['menu_name'] ?? '',
      permissions: (map['permissions'] as List<dynamic>?)
              ?.map((p) => Permission.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_id': menuId,
      'menu_code': menuCode,
      'menu_name': menuName,
      'permissions': permissions.map((p) => p.toMap()).toList(),
    };
  }
}

class RoleInfo {
  final int id;
  final String name;
  final String roleCode;

  RoleInfo({
    required this.id,
    required this.name,
    required this.roleCode,
  });

  factory RoleInfo.fromMap(Map<String, dynamic> map) {
    return RoleInfo(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      roleCode: map['role_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role_code': roleCode,
    };
  }
}

class MenuPermissionData {
  final RoleInfo role;
  final List<Menu> menus;

  MenuPermissionData({
    required this.role,
    required this.menus,
  });

  factory MenuPermissionData.fromMap(Map<String, dynamic> map) {
    return MenuPermissionData(
      role: RoleInfo.fromMap(map['role'] as Map<String, dynamic>),
      menus: (map['menus'] as List<dynamic>?)
              ?.map((m) => Menu.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.toMap(),
      'menus': menus.map((m) => m.toMap()).toList(),
    };
  }
}

class MenuPermissionResponse {
  final bool success;
  final String message;
  final MenuPermissionData? data;

  MenuPermissionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MenuPermissionResponse.fromMap(Map<String, dynamic> map) {
    return MenuPermissionResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null
          ? MenuPermissionData.fromMap(map['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data?.toMap(),
    };
  }
}
