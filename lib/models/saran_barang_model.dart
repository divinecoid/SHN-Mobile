// Request Payload Model
class SaranBarangRequest {
  int? jenisBarangId;
  int? bentukBarangId;
  int? gradeBarangId;
  int? itemBarangGroupId;
  String? jenisPotongan;
  double? tebal;
  double? panjang;
  double? lebar;
  double? diameterLuar;
  double? diameterDalam;
  double? diameter;
  double? sisi1;
  double? sisi2;
  int perPage;
  int page;

  SaranBarangRequest({
    this.jenisBarangId,
    this.bentukBarangId,
    this.gradeBarangId,
    this.itemBarangGroupId,
    this.jenisPotongan = 'all',
    this.tebal,
    this.panjang,
    this.lebar,
    this.diameterLuar,
    this.diameterDalam,
    this.diameter,
    this.sisi1,
    this.sisi2,
    this.perPage = 6,
    this.page = 1,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'per_page': perPage,
      'page': page,
    };
    
    if (jenisBarangId != null) data['jenis_barang_id'] = '$jenisBarangId';
    if (bentukBarangId != null) data['bentuk_barang_id'] = '$bentukBarangId';
    if (gradeBarangId != null) data['grade_barang_id'] = '$gradeBarangId';
    if (itemBarangGroupId != null) data['item_barang_group_id'] = itemBarangGroupId;
    if (jenisPotongan != null) data['jenis_potongan'] = jenisPotongan;
    
    if (tebal != null) data['tebal'] = tebal;
    if (panjang != null) data['panjang'] = panjang;
    if (lebar != null) data['lebar'] = lebar;
    if (diameterLuar != null) data['diameter_luar'] = diameterLuar;
    if (diameterDalam != null) data['diameter_dalam'] = diameterDalam;
    if (diameter != null) data['diameter'] = diameter;
    if (sisi1 != null) data['sisi1'] = sisi1;
    if (sisi2 != null) data['sisi2'] = sisi2;

    return data;
  }
}

// Response Model
class SaranBarangResponse {
  final int id;
  final String nama;
  final String ukuran;
  final double sisaLuas;
  final double sisaQuantity;

  SaranBarangResponse({
    required this.id,
    required this.nama,
    required this.ukuran,
    required this.sisaLuas,
    required this.sisaQuantity,
  });

  factory SaranBarangResponse.fromJson(Map<String, dynamic> json) {
    return SaranBarangResponse(
      id: _parseInt(json['id']),
      nama: json['nama'] ?? '-',
      ukuran: json['ukuran'] ?? '-',
      sisaLuas: _parseDouble(json['sisa_luas']),
      sisaQuantity: _parseDouble(json['sisa_quantity']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) return intValue;
      final doubleValue = double.tryParse(value);
      return doubleValue?.toInt() ?? 0;
    }
    return 0;
  }
}
