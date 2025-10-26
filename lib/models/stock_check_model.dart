import 'ref_gudang_model.dart';
import 'ref_jenis_barang_model.dart';
import 'ref_bentuk_barang_model.dart';
import 'ref_grade_barang_model.dart';

class StockCheckItem {
  final int id;
  final String kodeBarang;
  final String namaItemBarang;
  final double sisaLuas;
  final double panjang;
  final double lebar;
  final double tebal;
  final int quantity;
  final int quantityTebalSama;
  final String jenisPotongan;
  final bool isEdit;
  final bool isOnprogressPo;
  final int userId;
  final int gudangId;
  final int jenisBarangId;
  final int bentukBarangId;
  final int gradeBarangId;
  final String createdAt;
  final String updatedAt;
  final RefGudang gudang;
  final RefJenisBarang jenisBarang;
  final RefBentukBarang bentukBarang;
  final RefGradeBarang gradeBarang;

  StockCheckItem({
    required this.id,
    required this.kodeBarang,
    required this.namaItemBarang,
    required this.sisaLuas,
    required this.panjang,
    required this.lebar,
    required this.tebal,
    required this.quantity,
    required this.quantityTebalSama,
    required this.jenisPotongan,
    required this.isEdit,
    required this.isOnprogressPo,
    required this.userId,
    required this.gudangId,
    required this.jenisBarangId,
    required this.bentukBarangId,
    required this.gradeBarangId,
    required this.createdAt,
    required this.updatedAt,
    required this.gudang,
    required this.jenisBarang,
    required this.bentukBarang,
    required this.gradeBarang,
  });

  factory StockCheckItem.fromJson(Map<String, dynamic> json) {
    return StockCheckItem(
      id: json['id'] ?? 0,
      kodeBarang: json['kode_barang'] ?? '',
      namaItemBarang: json['nama_item_barang'] ?? '',
      sisaLuas: (json['sisa_luas'] ?? 0).toDouble(),
      panjang: (json['panjang'] ?? 0).toDouble(),
      lebar: (json['lebar'] ?? 0).toDouble(),
      tebal: (json['tebal'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      quantityTebalSama: json['quantity_tebal_sama'] ?? 0,
      jenisPotongan: json['jenis_potongan'] ?? '',
      isEdit: json['is_edit'] ?? false,
      isOnprogressPo: json['is_onprogress_po'] ?? false,
      userId: json['user_id'] ?? 0,
      gudangId: json['gudang_id'] ?? 0,
      jenisBarangId: json['jenis_barang_id'] ?? 0,
      bentukBarangId: json['bentuk_barang_id'] ?? 0,
      gradeBarangId: json['grade_barang_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      gudang: RefGudang.fromJson(json['gudang'] ?? {}),
      jenisBarang: RefJenisBarang.fromJson(json['jenis_barang'] ?? {}),
      bentukBarang: RefBentukBarang.fromJson(json['bentuk_barang'] ?? {}),
      gradeBarang: RefGradeBarang.fromJson(json['grade_barang'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'nama_item_barang': namaItemBarang,
      'sisa_luas': sisaLuas,
      'panjang': panjang,
      'lebar': lebar,
      'tebal': tebal,
      'quantity': quantity,
      'quantity_tebal_sama': quantityTebalSama,
      'jenis_potongan': jenisPotongan,
      'is_edit': isEdit,
      'is_onprogress_po': isOnprogressPo,
      'user_id': userId,
      'gudang_id': gudangId,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'gudang': gudang.toJson(),
      'jenis_barang': jenisBarang.toJson(),
      'bentuk_barang': bentukBarang.toJson(),
      'grade_barang': gradeBarang.toJson(),
    };
  }
}
