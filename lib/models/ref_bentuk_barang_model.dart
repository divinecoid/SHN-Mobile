class RefBentukBarang {
  final int id;
  final String kode;
  final String namaBentuk;
  final String dimensi;

  RefBentukBarang({
    required this.id,
    required this.kode,
    required this.namaBentuk,
    required this.dimensi,
  });

  factory RefBentukBarang.fromJson(Map<String, dynamic> json) {
    return RefBentukBarang(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      namaBentuk: json['nama_bentuk'] ?? '',
      dimensi: json['dimensi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama_bentuk': namaBentuk,
      'dimensi': dimensi,
    };
  }
}
