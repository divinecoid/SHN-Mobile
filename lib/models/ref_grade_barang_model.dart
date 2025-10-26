class RefGradeBarang {
  final int id;
  final String kode;
  final String nama;

  RefGradeBarang({
    required this.id,
    required this.kode,
    required this.nama,
  });

  factory RefGradeBarang.fromJson(Map<String, dynamic> json) {
    return RefGradeBarang(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
    };
  }
}
