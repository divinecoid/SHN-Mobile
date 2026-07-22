import 'item_barang_model.dart';
import 'ref_rak_model.dart';

class PindahRakRequest {
  final int idItemBarang;
  final int idRak;
  final int gudangId;

  PindahRakRequest({
    required this.idItemBarang,
    required this.idRak,
    required this.gudangId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_rak': idRak,
      'gudang_id': gudangId,
    };
  }
}

class RakDetailInfo {
  final int id;
  final String kode;
  final String namaRak;
  final int gudangId;
  final String? namaGudang;

  RakDetailInfo({
    required this.id,
    required this.kode,
    required this.namaRak,
    required this.gudangId,
    this.namaGudang,
  });

  factory RakDetailInfo.fromJson(Map<String, dynamic> json) {
    int parsedGudangId = 0;
    String? gudangName;

    if (json['gudang_id'] != null) {
      parsedGudangId = _parseInt(json['gudang_id']);
    }

    if (json['gudang'] != null && json['gudang'] is Map<String, dynamic>) {
      final gudangMap = json['gudang'] as Map<String, dynamic>;
      if (parsedGudangId == 0 && gudangMap['id'] != null) {
        parsedGudangId = _parseInt(gudangMap['id']);
      }
      gudangName = gudangMap['nama_gudang']?.toString();
    }

    return RakDetailInfo(
      id: _parseInt(json['id']),
      kode: json['kode']?.toString() ?? '',
      namaRak: json['nama_rak']?.toString() ?? '',
      gudangId: parsedGudangId,
      namaGudang: gudangName,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
