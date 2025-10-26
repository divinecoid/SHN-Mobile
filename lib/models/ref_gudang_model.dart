class RefGudang {
  final int id;
  final String kode;
  final String namaGudang;
  final String? tipeGudang;
  final int? parentId;
  final String? teleponHp;
  final int? kapasitas;

  RefGudang({
    required this.id,
    required this.kode,
    required this.namaGudang,
    this.tipeGudang,
    this.parentId,
    this.teleponHp,
    this.kapasitas,
  });

  factory RefGudang.fromJson(Map<String, dynamic> json) {
    return RefGudang(
      id: _parseInt(json['id']),
      kode: json['kode'] ?? '',
      namaGudang: json['nama_gudang'] ?? '',
      tipeGudang: json['tipe_gudang'],
      parentId: _parseInt(json['parent_id']),
      teleponHp: json['telepon_hp'],
      kapasitas: _parseInt(json['kapasitas']),
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
      'nama_gudang': namaGudang,
      'tipe_gudang': tipeGudang,
      'parent_id': parentId,
      'telepon_hp': teleponHp,
      'kapasitas': kapasitas,
    };
  }
}
