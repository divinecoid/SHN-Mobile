class Gudang {
  final int id;
  final String kode;
  final String namaGudang;
  final String? alamat;
  final double? latitude;
  final double? longitude;
  final String? tipeGudang;
  final int? parentId;
  final String? teleponHp;
  final int? kapasitas;

  Gudang({
    required this.id,
    required this.kode,
    required this.namaGudang,
    this.alamat,
    this.latitude,
    this.longitude,
    this.tipeGudang,
    this.parentId,
    this.teleponHp,
    this.kapasitas,
  });

  factory Gudang.fromMap(Map<String, dynamic> map) {
    return Gudang(
      id: map['id'] as int,
      kode: map['kode'] as String,
      namaGudang: map['nama_gudang'] as String,
      alamat: map['alamat'] as String?,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      tipeGudang: map['tipe_gudang'] as String?,
      parentId: map['parent_id'] as int?,
      teleponHp: map['telepon_hp'] as String?,
      kapasitas: map['kapasitas'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_gudang': namaGudang,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'tipe_gudang': tipeGudang,
      'parent_id': parentId,
      'telepon_hp': teleponHp,
      'kapasitas': kapasitas,
    };
  }

  @override
  String toString() {
    return 'Gudang(id: $id, kode: $kode, namaGudang: $namaGudang, alamat: $alamat, latitude: $latitude, longitude: $longitude, tipeGudang: $tipeGudang, parentId: $parentId, teleponHp: $teleponHp, kapasitas: $kapasitas)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gudang && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class GudangResult {
  final bool success;
  final String message;
  final List<Gudang> data;
  final GudangPagination? pagination;

  GudangResult({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory GudangResult.fromMap(Map<String, dynamic> map) {
    return GudangResult(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: (map['data'] as List<dynamic>)
          .map((item) => Gudang.fromMap(item as Map<String, dynamic>))
          .toList(),
      pagination: map['pagination'] != null
          ? GudangPagination.fromMap(map['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toMap()).toList(),
      'pagination': pagination?.toMap(),
    };
  }
}

class GudangPagination {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  GudangPagination({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory GudangPagination.fromMap(Map<String, dynamic> map) {
    return GudangPagination(
      currentPage: map['current_page'] as int,
      perPage: map['per_page'] as int,
      lastPage: map['last_page'] as int,
      total: map['total'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'last_page': lastPage,
      'total': total,
    };
  }
}
