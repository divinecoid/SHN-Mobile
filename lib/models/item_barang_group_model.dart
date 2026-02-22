import 'ref_jenis_barang_model.dart';
import 'ref_bentuk_barang_model.dart';
import 'ref_grade_barang_model.dart';

class ItemBarangGroup {
  final int id;
  final int jenisBarangId;
  final int bentukBarangId;
  final int gradeBarangId;
  final String? panjang;
  final String? lebar;
  final String? tebal;
  final String? diameterLuar;
  final String? diameterDalam;
  final String? diameter;
  final String? sisi1;
  final String? sisi2;
  final int quantityUtuh;
  final int quantityPotongan;
  final String namaGroupBarang;
  final RefJenisBarang? jenisBarang;
  final RefBentukBarang? bentukBarang;
  final RefGradeBarang? gradeBarang;

  ItemBarangGroup({
    required this.id,
    required this.jenisBarangId,
    required this.bentukBarangId,
    required this.gradeBarangId,
    this.panjang,
    this.lebar,
    this.tebal,
    this.diameterLuar,
    this.diameterDalam,
    this.diameter,
    this.sisi1,
    this.sisi2,
    this.quantityUtuh = 0,
    this.quantityPotongan = 0,
    required this.namaGroupBarang,
    this.jenisBarang,
    this.bentukBarang,
    this.gradeBarang,
  });

  factory ItemBarangGroup.fromJson(Map<String, dynamic> json) {
    return ItemBarangGroup(
      id: _parseInt(json['id']),
      jenisBarangId: _parseInt(json['jenis_barang_id']),
      bentukBarangId: _parseInt(json['bentuk_barang_id']),
      gradeBarangId: _parseInt(json['grade_barang_id']),
      panjang: json['panjang']?.toString(),
      lebar: json['lebar']?.toString(),
      tebal: json['tebal']?.toString(),
      diameterLuar: json['diameter_luar']?.toString(),
      diameterDalam: json['diameter_dalam']?.toString(),
      diameter: json['diameter']?.toString(),
      sisi1: json['sisi1']?.toString(),
      sisi2: json['sisi2']?.toString(),
      quantityUtuh: _parseInt(json['quantity_utuh']),
      quantityPotongan: _parseInt(json['quantity_potongan']),
      namaGroupBarang: json['nama_group_barang'] ?? '',
      jenisBarang: json['jenis_barang'] != null ? RefJenisBarang.fromJson(json['jenis_barang']) : null,
      bentukBarang: json['bentuk_barang'] != null ? RefBentukBarang.fromJson(json['bentuk_barang']) : null,
      gradeBarang: json['grade_barang'] != null ? RefGradeBarang.fromJson(json['grade_barang']) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'panjang': panjang,
      'lebar': lebar,
      'tebal': tebal,
      'diameter_luar': diameterLuar,
      'diameter_dalam': diameterDalam,
      'diameter': diameter,
      'sisi1': sisi1,
      'sisi2': sisi2,
      'quantity_utuh': quantityUtuh,
      'quantity_potongan': quantityPotongan,
      'nama_group_barang': namaGroupBarang,
      'jenis_barang': jenisBarang?.toJson(),
      'bentuk_barang': bentukBarang?.toJson(),
      'grade_barang': gradeBarang?.toJson(),
    };
  }
}
