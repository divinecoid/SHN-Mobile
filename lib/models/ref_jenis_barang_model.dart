class RefJenisBarang {
  final int id;
  final String kode;
  final String namaJenis;

  RefJenisBarang({
    required this.id,
    required this.kode,
    required this.namaJenis,
  });

  factory RefJenisBarang.fromJson(Map<String, dynamic> json) {
    return RefJenisBarang(
      id: _parseInt(json['id']),
      kode: json['kode'] ?? '',
      namaJenis: json['nama_jenis'] ?? '',
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
      'nama_jenis': namaJenis,
    };
  }
}
