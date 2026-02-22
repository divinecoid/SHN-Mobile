import 'tipe_barang_model.dart';

class RefBentukBarang {
  final int id;
  final String kode;
  final String namaBentuk;
  final String dimensi;
  final TipeBarang? tipeBarang;

  RefBentukBarang({
    required this.id,
    required this.kode,
    required this.namaBentuk,
    required this.dimensi,
    this.tipeBarang,
  });

  factory RefBentukBarang.fromJson(Map<String, dynamic> json) {
    return RefBentukBarang(
      id: _parseInt(json['id']),
      kode: json['kode'] ?? '',
      namaBentuk: json['nama_bentuk'] ?? '',
      dimensi: json['dimensi'] ?? '',
      tipeBarang: json['tipe_barang'] != null ? TipeBarang.fromJson(json['tipe_barang']) : null,
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
      'kode': kode,
      'nama_bentuk': namaBentuk,
      'dimensi': dimensi,
      'tipe_barang': tipeBarang?.toJson(),
    };
  }
}

