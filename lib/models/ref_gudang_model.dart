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
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      namaGudang: json['nama_gudang'] ?? '',
      tipeGudang: json['tipe_gudang'],
      parentId: json['parent_id'],
      teleponHp: json['telepon_hp'],
      kapasitas: json['kapasitas'],
    );
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
