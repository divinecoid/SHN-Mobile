import 'ref_jenis_barang_model.dart';
import 'ref_bentuk_barang_model.dart';
import 'ref_grade_barang_model.dart';
import 'gudang_model.dart';

class ItemBarang {
  final int id;
  final String kodeBarang;
  final int jenisBarangId;
  final int bentukBarangId;
  final int gradeBarangId;
  final double panjang;
  final double lebar;
  final double tebal;
  final double quantity;
  final double quantityTebalSama;
  final String jenisPotongan;
  final bool isAvailable;
  final String namaItemBarang;
  final double sisaLuas;
  final int isOnprogressPo;
  final int isEdit;
  final int? userId;
  final String? canvasFile;
  final String? canvasImage;
  final String? convertDate;
  final int gudangId;
  final String? splitDate;
  final String? mergeDate;
  final String? frozenAt;
  final int? frozenBy;
  final RefJenisBarang? jenisBarang;
  final RefBentukBarang? bentukBarang;
  final RefGradeBarang? gradeBarang;
  final Gudang? gudang;

  ItemBarang({
    required this.id,
    required this.kodeBarang,
    required this.jenisBarangId,
    required this.bentukBarangId,
    required this.gradeBarangId,
    required this.panjang,
    required this.lebar,
    required this.tebal,
    required this.quantity,
    required this.quantityTebalSama,
    required this.jenisPotongan,
    required this.isAvailable,
    required this.namaItemBarang,
    required this.sisaLuas,
    required this.isOnprogressPo,
    required this.isEdit,
    this.userId,
    this.canvasFile,
    this.canvasImage,
    this.convertDate,
    required this.gudangId,
    this.splitDate,
    this.mergeDate,
    this.frozenAt,
    this.frozenBy,
    this.jenisBarang,
    this.bentukBarang,
    this.gradeBarang,
    this.gudang,
  });

  factory ItemBarang.fromMap(Map<String, dynamic> map) {
    return ItemBarang(
      id: _parseInt(map['id']) ?? 0,
      kodeBarang: map['kode_barang']?.toString() ?? '',
      jenisBarangId: _parseInt(map['jenis_barang_id']) ?? 0,
      bentukBarangId: _parseInt(map['bentuk_barang_id']) ?? 0,
      gradeBarangId: _parseInt(map['grade_barang_id']) ?? 0,
      panjang: _parseDouble(map['panjang']),
      lebar: _parseDouble(map['lebar']),
      tebal: _parseDouble(map['tebal']),
      quantity: _parseDouble(map['quantity']),
      quantityTebalSama: _parseDouble(map['quantity_tebal_sama']),
      jenisPotongan: map['jenis_potongan']?.toString() ?? '',
      isAvailable: _parseBool(map['is_available']) ?? false,
      namaItemBarang: map['nama_item_barang']?.toString() ?? '',
      sisaLuas: _parseDouble(map['sisa_luas']),
      isOnprogressPo: _parseInt(map['is_onprogress_po']) ?? 0,
      isEdit: _parseInt(map['is_edit']) ?? 0,
      userId: _parseInt(map['user_id']),
      canvasFile: map['canvas_file']?.toString(),
      canvasImage: map['canvas_image']?.toString(),
      convertDate: map['convert_date']?.toString(),
      gudangId: _parseInt(map['gudang_id']) ?? 0,
      splitDate: map['split_date']?.toString(),
      mergeDate: map['merge_date']?.toString(),
      frozenAt: map['frozen_at']?.toString(),
      frozenBy: _parseInt(map['frozen_by']),
      jenisBarang: map['jenis_barang'] != null && map['jenis_barang'] is Map<String, dynamic>
          ? RefJenisBarang.fromJson(map['jenis_barang'] as Map<String, dynamic>)
          : null,
      bentukBarang: map['bentuk_barang'] != null && map['bentuk_barang'] is Map<String, dynamic>
          ? RefBentukBarang.fromJson(map['bentuk_barang'] as Map<String, dynamic>)
          : null,
      gradeBarang: map['grade_barang'] != null && map['grade_barang'] is Map<String, dynamic>
          ? RefGradeBarang.fromJson(map['grade_barang'] as Map<String, dynamic>)
          : null,
      gudang: map['gudang'] != null && map['gudang'] is Map<String, dynamic>
          ? Gudang.fromMap(map['gudang'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'panjang': panjang.toStringAsFixed(2),
      'lebar': lebar.toStringAsFixed(2),
      'tebal': tebal.toStringAsFixed(2),
      'quantity': quantity.toStringAsFixed(2),
      'quantity_tebal_sama': quantityTebalSama.toStringAsFixed(2),
      'jenis_potongan': jenisPotongan,
      'is_available': isAvailable,
      'nama_item_barang': namaItemBarang,
      'sisa_luas': sisaLuas.toStringAsFixed(2),
      'is_onprogress_po': isOnprogressPo,
      'is_edit': isEdit,
      'user_id': userId,
      'canvas_file': canvasFile,
      'canvas_image': canvasImage,
      'convert_date': convertDate,
      'gudang_id': gudangId,
      'split_date': splitDate,
      'merge_date': mergeDate,
      'frozen_at': frozenAt,
      'frozen_by': frozenBy,
      'jenis_barang': jenisBarang?.toJson(),
      'bentuk_barang': bentukBarang?.toJson(),
      'grade_barang': gradeBarang?.toJson(),
      'gudang': gudang?.toMap(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }
}

class ItemBarangResult {
  final bool success;
  final String message;
  final List<ItemBarang> data;
  final ItemBarangPagination? pagination;

  ItemBarangResult({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory ItemBarangResult.fromMap(Map<String, dynamic> map) {
    return ItemBarangResult(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: (map['data'] as List<dynamic>)
          .map((item) => ItemBarang.fromMap(item as Map<String, dynamic>))
          .toList(),
      pagination: map['pagination'] != null
          ? ItemBarangPagination.fromMap(map['pagination'] as Map<String, dynamic>)
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

class ItemBarangPagination {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  ItemBarangPagination({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory ItemBarangPagination.fromMap(Map<String, dynamic> map) {
    return ItemBarangPagination(
      currentPage: map['current_page'] as int,
      perPage: map['per_page'] as int,
      lastPage: map['last_page'] as int,
      total: map['total'] as int,
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

