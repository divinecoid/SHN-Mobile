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
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      namaJenis: json['nama_jenis'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama_jenis': namaJenis,
    };
  }
}
