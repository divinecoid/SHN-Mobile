class StockOpnameUser {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String createdAt;
  final String updatedAt;

  StockOpnameUser({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockOpnameUser.fromMap(Map<String, dynamic> map) {
    return StockOpnameUser(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String?,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StockOpnameGudang {
  final int id;
  final String kode;
  final String namaGudang;
  final String? tipeGudang;
  final int? parentId;
  final String? teleponHp;
  final int? kapasitas;
  final String createdAt;
  final String updatedAt;

  StockOpnameGudang({
    required this.id,
    required this.kode,
    required this.namaGudang,
    this.tipeGudang,
    this.parentId,
    this.teleponHp,
    this.kapasitas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockOpnameGudang.fromMap(Map<String, dynamic> map) {
    return StockOpnameGudang(
      id: map['id'] as int? ?? 0,
      kode: map['kode'] as String? ?? '',
      namaGudang: map['nama_gudang'] as String? ?? '',
      tipeGudang: map['tipe_gudang'] as String?,
      parentId: map['parent_id'] as int?,
      teleponHp: map['telepon_hp'] as String?,
      kapasitas: map['kapasitas'] as int?,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_gudang': namaGudang,
      'tipe_gudang': tipeGudang,
      'parent_id': parentId,
      'telepon_hp': teleponHp,
      'kapasitas': kapasitas,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StockOpnameDetailItemBarang {
  final int id;
  final String kodeBarang;
  final String namaItemBarang;
  final int jenisBarangId;
  final int bentukBarangId;
  final int gradeBarangId;
  final int gudangId;
  final String createdAt;
  final String updatedAt;

  StockOpnameDetailItemBarang({
    required this.id,
    required this.kodeBarang,
    required this.namaItemBarang,
    required this.jenisBarangId,
    required this.bentukBarangId,
    required this.gradeBarangId,
    required this.gudangId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockOpnameDetailItemBarang.fromMap(Map<String, dynamic> map) {
    return StockOpnameDetailItemBarang(
      id: map['id'] as int? ?? 0,
      kodeBarang: map['kode_barang'] as String? ?? '',
      namaItemBarang: map['nama_item_barang'] as String? ?? '',
      jenisBarangId: map['jenis_barang_id'] as int? ?? 0,
      bentukBarangId: map['bentuk_barang_id'] as int? ?? 0,
      gradeBarangId: map['grade_barang_id'] as int? ?? 0,
      gudangId: map['gudang_id'] as int? ?? 0,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'nama_item_barang': namaItemBarang,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'gudang_id': gudangId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StockOpnameDetail {
  final int id;
  final int stockOpnameId;
  final int itemBarangId;
  final int? stokSistem;
  final int stokFisik;
  final String? catatan;
  final String createdAt;
  final String updatedAt;
  final StockOpnameDetailItemBarang? itemBarang;

  StockOpnameDetail({
    required this.id,
    required this.stockOpnameId,
    required this.itemBarangId,
    this.stokSistem,
    required this.stokFisik,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.itemBarang,
  });

  factory StockOpnameDetail.fromMap(Map<String, dynamic> map) {
    return StockOpnameDetail(
      id: map['id'] as int? ?? 0,
      stockOpnameId: map['stock_opname_id'] as int? ?? 0,
      itemBarangId: map['item_barang_id'] as int? ?? 0,
      stokSistem: map['stok_sistem'] as int?,
      stokFisik: map['stok_fisik'] as int? ?? 0,
      catatan: map['catatan'] as String?,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
      itemBarang: map['item_barang'] != null
          ? StockOpnameDetailItemBarang.fromMap(map['item_barang'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stock_opname_id': stockOpnameId,
      'item_barang_id': itemBarangId,
      'stok_sistem': stokSistem,
      'stok_fisik': stokFisik,
      'catatan': catatan,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'item_barang': itemBarang?.toMap(),
    };
  }
}

class StockOpname {
  final int id;
  final int picUserId;
  final int gudangId;
  final String? catatan;
  final String status;
  final String createdAt;
  final String updatedAt;
  final StockOpnameUser? picUser;
  final StockOpnameGudang? gudang;
  final List<StockOpnameDetail>? stockOpnameDetails;

  StockOpname({
    required this.id,
    required this.picUserId,
    required this.gudangId,
    this.catatan,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.picUser,
    this.gudang,
    this.stockOpnameDetails,
  });

  factory StockOpname.fromMap(Map<String, dynamic> map) {
    return StockOpname(
      id: map['id'] as int? ?? 0,
      picUserId: map['pic_user_id'] as int? ?? 0,
      gudangId: map['gudang_id'] as int? ?? 0,
      catatan: map['catatan'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
      picUser: map['pic_user'] != null
          ? StockOpnameUser.fromMap(map['pic_user'] as Map<String, dynamic>)
          : null,
      gudang: map['gudang'] != null
          ? StockOpnameGudang.fromMap(map['gudang'] as Map<String, dynamic>)
          : null,
      stockOpnameDetails: map['stock_opname_details'] != null
          ? (map['stock_opname_details'] as List)
              .map((detail) => StockOpnameDetail.fromMap(detail as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pic_user_id': picUserId,
      'gudang_id': gudangId,
      'catatan': catatan,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pic_user': picUser?.toMap(),
      'gudang': gudang?.toMap(),
      'stock_opname_details': stockOpnameDetails?.map((detail) => detail.toMap()).toList(),
    };
  }
}

class StockOpnamePagination {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  StockOpnamePagination({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory StockOpnamePagination.fromMap(Map<String, dynamic> map) {
    return StockOpnamePagination(
      currentPage: map['current_page'] as int? ?? 1,
      perPage: map['per_page'] as int? ?? 100,
      lastPage: map['last_page'] as int? ?? 1,
      total: map['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'last_page': lastPage,
      'total': total,
    };
  }
}

class StockOpnameResult {
  final bool success;
  final String message;
  final List<StockOpname> data;
  final StockOpnamePagination? pagination;

  StockOpnameResult({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory StockOpnameResult.fromMap(Map<String, dynamic> map) {
    return StockOpnameResult(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      data: map['data'] != null
          ? (map['data'] as List)
              .map((item) => StockOpname.fromMap(item as Map<String, dynamic>))
              .toList()
          : [],
      pagination: map['pagination'] != null
          ? StockOpnamePagination.fromMap(map['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toMap()).toList(),
      'pagination': pagination?.toMap(),
    };
  }
}

class StockOpnameDetailResult {
  final bool success;
  final String message;
  final StockOpname? data;

  StockOpnameDetailResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory StockOpnameDetailResult.fromMap(Map<String, dynamic> map) {
    return StockOpnameDetailResult(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      data: map['data'] != null
          ? StockOpname.fromMap(map['data'] as Map<String, dynamic>)
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

