class Pelaksana {
  final int id;
  final String kode;
  final String namaPelaksana;
  final String level;

  Pelaksana({
    required this.id,
    required this.kode,
    required this.namaPelaksana,
    required this.level,
  });

  factory Pelaksana.fromMap(Map<String, dynamic> map) {
    return Pelaksana(
      id: map['id'] as int,
      kode: map['kode'] as String,
      namaPelaksana: map['nama_pelaksana'] as String,
      level: map['level'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_pelaksana': namaPelaksana,
      'level': level,
    };
  }

  @override
  String toString() {
    return 'Pelaksana(id: $id, kode: $kode, namaPelaksana: $namaPelaksana, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pelaksana && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PelaksanaResult {
  final bool success;
  final String message;
  final List<Pelaksana> data;
  final PelaksanaPagination? pagination;

  PelaksanaResult({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory PelaksanaResult.fromMap(Map<String, dynamic> map) {
    return PelaksanaResult(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: (map['data'] as List<dynamic>)
          .map((item) => Pelaksana.fromMap(item as Map<String, dynamic>))
          .toList(),
      pagination: map['pagination'] != null
          ? PelaksanaPagination.fromMap(map['pagination'] as Map<String, dynamic>)
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

class PelaksanaPagination {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  PelaksanaPagination({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory PelaksanaPagination.fromMap(Map<String, dynamic> map) {
    return PelaksanaPagination(
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
