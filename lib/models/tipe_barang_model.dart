class TipeBarang {
  final int id;
  final String name;
  final String? desc;
  final bool diameterLuar;
  final bool diameterDalam;
  final bool diameter;
  final bool sisi1;
  final bool sisi2;
  final bool tebal;
  final bool lebar;
  final bool panjang;

  TipeBarang({
    required this.id,
    required this.name,
    this.desc,
    this.diameterLuar = false,
    this.diameterDalam = false,
    this.diameter = false,
    this.sisi1 = false,
    this.sisi2 = false,
    this.tebal = false,
    this.lebar = false,
    this.panjang = false,
  });

  factory TipeBarang.fromJson(Map<String, dynamic> json) {
    return TipeBarang(
      id: _parseInt(json['id']),
      name: json['name'] ?? json['nama'] ?? '',
      desc: json['desc'] ?? json['deskripsi'],
      diameterLuar: _parseBool(json['diameter_luar']),
      diameterDalam: _parseBool(json['diameter_dalam']),
      diameter: _parseBool(json['diameter']),
      sisi1: _parseBool(json['sisi1']),
      sisi2: _parseBool(json['sisi2']),
      tebal: _parseBool(json['tebal']),
      lebar: _parseBool(json['lebar']),
      panjang: _parseBool(json['panjang']),
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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'diameter_luar': diameterLuar,
      'diameter_dalam': diameterDalam,
      'diameter': diameter,
      'sisi1': sisi1,
      'sisi2': sisi2,
      'tebal': tebal,
      'lebar': lebar,
      'panjang': panjang,
    };
  }
}
