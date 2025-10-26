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
      id: _parseInt(json['id']),
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
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
      'nama': nama,
    };
  }
}
