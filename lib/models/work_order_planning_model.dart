class WorkOrderPlanning {
  final int id;
  final String woUniqueId;
  final String nomorWo;
  final DateTime tanggalWo;
  final int idSalesOrder;
  final int idPelanggan;
  final int idGudang;
  final int? idPelaksana;
  final String prioritas;
  final String status;
  final String? namaPelanggan;
  final String? namaGudang;
  final String? nomorSo;
  final int count;
  final List<WorkOrderPlanningItem> workOrderPlanningItems;
  final SalesOrder? salesOrder;
  final Pelanggan? pelanggan;
  final Gudang? gudang;
  final DateTime? deletedAt;

  WorkOrderPlanning({
    required this.id,
    required this.woUniqueId,
    required this.nomorWo,
    required this.tanggalWo,
    required this.idSalesOrder,
    required this.idPelanggan,
    required this.idGudang,
    this.idPelaksana,
    required this.prioritas,
    required this.status,
    this.namaPelanggan,
    this.namaGudang,
    this.nomorSo,
    required this.count,
    required this.workOrderPlanningItems,
    this.salesOrder,
    this.pelanggan,
    this.gudang,
    this.deletedAt,
  });

  factory WorkOrderPlanning.fromMap(Map<String, dynamic> map) {
    return WorkOrderPlanning(
      id: map['id'] ?? 0,
      woUniqueId: map['wo_unique_id'] ?? '',
      nomorWo: map['nomor_wo'] ?? '',
      tanggalWo: DateTime.tryParse(map['tanggal_wo'] ?? '') ?? DateTime.now(),
      idSalesOrder: map['id_sales_order'] ?? 0,
      idPelanggan: map['id_pelanggan'] ?? 0,
      idGudang: map['id_gudang'] ?? 0,
      idPelaksana: map['id_pelaksana'],
      prioritas: map['prioritas'] ?? '',
      status: map['status'] ?? '',
      namaPelanggan: map['nama_pelanggan'],
      namaGudang: map['nama_gudang'],
      nomorSo: map['nomor_so'],
      count: map['count'] ?? 0,
      workOrderPlanningItems: (map['work_order_planning_items'] as List<dynamic>?)
          ?.map((item) => WorkOrderPlanningItem.fromMap(item))
          .toList() ?? [],
      salesOrder: map['sales_order'] != null 
          ? SalesOrder.fromMap(map['sales_order'])
          : null,
      pelanggan: map['pelanggan'] != null 
          ? Pelanggan.fromMap(map['pelanggan'])
          : null,
      gudang: map['gudang'] != null 
          ? Gudang.fromMap(map['gudang'])
          : null,
      deletedAt: map['deleted_at'] != null 
          ? DateTime.tryParse(map['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wo_unique_id': woUniqueId,
      'nomor_wo': nomorWo,
      'tanggal_wo': tanggalWo.toIso8601String(),
      'id_sales_order': idSalesOrder,
      'id_pelanggan': idPelanggan,
      'id_gudang': idGudang,
      'id_pelaksana': idPelaksana,
      'prioritas': prioritas,
      'status': status,
      'nama_pelanggan': namaPelanggan,
      'nama_gudang': namaGudang,
      'nomor_so': nomorSo,
      'count': count,
      'work_order_planning_items': workOrderPlanningItems.map((item) => item.toMap()).toList(),
      'sales_order': salesOrder?.toMap(),
      'pelanggan': pelanggan?.toMap(),
      'gudang': gudang?.toMap(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

class WorkOrderPlanningItem {
  final int id;
  final String woItemUniqueId;
  final String panjang;
  final String lebar;
  final String tebal;
  final String berat;
  final int qty;
  final int jenisBarangId;
  final int bentukBarangId;
  final int gradeBarangId;
  final String satuan;
  final String diskon;
  final String? catatan;
  final bool isAssigned;
  final int workOrderPlanningId;
  final JenisBarang? jenisBarang;
  final BentukBarang? bentukBarang;
  final GradeBarang? gradeBarang;
  final List<PelaksanaItem> pelaksana;

  WorkOrderPlanningItem({
    required this.id,
    required this.woItemUniqueId,
    required this.panjang,
    required this.lebar,
    required this.tebal,
    required this.berat,
    required this.qty,
    required this.jenisBarangId,
    required this.bentukBarangId,
    required this.gradeBarangId,
    required this.satuan,
    required this.diskon,
    this.catatan,
    required this.isAssigned,
    required this.workOrderPlanningId,
    this.jenisBarang,
    this.bentukBarang,
    this.gradeBarang,
    required this.pelaksana,
  });

  factory WorkOrderPlanningItem.fromMap(Map<String, dynamic> map) {
    return WorkOrderPlanningItem(
      id: map['id'] ?? 0,
      woItemUniqueId: map['wo_item_unique_id'] ?? '',
      panjang: map['panjang'] ?? '0.00',
      lebar: map['lebar'] ?? '0.00',
      tebal: map['tebal'] ?? '0.00',
      berat: map['berat'] ?? '0.00',
      qty: map['qty'] ?? 0,
      jenisBarangId: map['jenis_barang_id'] ?? 0,
      bentukBarangId: map['bentuk_barang_id'] ?? 0,
      gradeBarangId: map['grade_barang_id'] ?? 0,
      satuan: map['satuan'] ?? '',
      diskon: map['diskon'] ?? '0.00',
      catatan: map['catatan'],
      isAssigned: map['is_assigned'] ?? false,
      workOrderPlanningId: map['work_order_planning_id'] ?? 0,
      jenisBarang: map['jenis_barang'] != null 
          ? JenisBarang.fromMap(map['jenis_barang'])
          : null,
      bentukBarang: map['bentuk_barang'] != null 
          ? BentukBarang.fromMap(map['bentuk_barang'])
          : null,
      gradeBarang: map['grade_barang'] != null 
          ? GradeBarang.fromMap(map['grade_barang'])
          : null,
      pelaksana: (map['has_many_pelaksana'] as List<dynamic>?)
          ?.map((item) => PelaksanaItem.fromMap(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wo_item_unique_id': woItemUniqueId,
      'panjang': panjang,
      'lebar': lebar,
      'tebal': tebal,
      'berat': berat,
      'qty': qty,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'satuan': satuan,
      'diskon': diskon,
      'catatan': catatan,
      'is_assigned': isAssigned,
      'work_order_planning_id': workOrderPlanningId,
      'jenis_barang': jenisBarang?.toMap(),
      'bentuk_barang': bentukBarang?.toMap(),
      'grade_barang': gradeBarang?.toMap(),
      'has_many_pelaksana': pelaksana.map((item) => item.toMap()).toList(),
    };
  }
}

class PelaksanaItem {
  final int id;
  final int woPlanItemId;
  final int pelaksanaId;
  final int qty;
  final String weight;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String? catatan;
  final WorkOrderPelaksana? pelaksana;

  PelaksanaItem({
    required this.id,
    required this.woPlanItemId,
    required this.pelaksanaId,
    required this.qty,
    required this.weight,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    this.catatan,
    this.pelaksana,
  });

  factory PelaksanaItem.fromMap(Map<String, dynamic> map) {
    return PelaksanaItem(
      id: map['id'] ?? 0,
      woPlanItemId: map['wo_plan_item_id'] ?? 0,
      pelaksanaId: map['pelaksana_id'] ?? 0,
      qty: map['qty'] ?? 0,
      weight: map['weight'] ?? '0.00',
      tanggal: map['tanggal'] ?? '',
      jamMulai: map['jam_mulai'] ?? '',
      jamSelesai: map['jam_selesai'] ?? '',
      catatan: map['catatan'],
      pelaksana: map['pelaksana'] != null 
          ? WorkOrderPelaksana.fromMap(map['pelaksana'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wo_plan_item_id': woPlanItemId,
      'pelaksana_id': pelaksanaId,
      'qty': qty,
      'weight': weight,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'catatan': catatan,
      'pelaksana': pelaksana?.toMap(),
    };
  }
}

class SalesOrder {
  final int id;
  final String nomorSo;
  final DateTime tanggalSo;
  final DateTime tanggalPengiriman;
  final String syaratPembayaran;
  final int gudangId;
  final int pelangganId;
  final String subtotal;
  final String totalDiskon;
  final String ppnPercent;
  final String ppnAmount;
  final String totalHargaSo;
  final String status;
  final String? deleteRequestedBy;
  final DateTime? deleteRequestedAt;
  final String? deleteApprovedBy;
  final DateTime? deleteApprovedAt;
  final String? deleteReason;
  final String? deleteRejectionReason;

  SalesOrder({
    required this.id,
    required this.nomorSo,
    required this.tanggalSo,
    required this.tanggalPengiriman,
    required this.syaratPembayaran,
    required this.gudangId,
    required this.pelangganId,
    required this.subtotal,
    required this.totalDiskon,
    required this.ppnPercent,
    required this.ppnAmount,
    required this.totalHargaSo,
    required this.status,
    this.deleteRequestedBy,
    this.deleteRequestedAt,
    this.deleteApprovedBy,
    this.deleteApprovedAt,
    this.deleteReason,
    this.deleteRejectionReason,
  });

  factory SalesOrder.fromMap(Map<String, dynamic> map) {
    return SalesOrder(
      id: map['id'] ?? 0,
      nomorSo: map['nomor_so'] ?? '',
      tanggalSo: DateTime.tryParse(map['tanggal_so'] ?? '') ?? DateTime.now(),
      tanggalPengiriman: DateTime.tryParse(map['tanggal_pengiriman'] ?? '') ?? DateTime.now(),
      syaratPembayaran: map['syarat_pembayaran'] ?? '',
      gudangId: map['gudang_id'] ?? 0,
      pelangganId: map['pelanggan_id'] ?? 0,
      subtotal: map['subtotal'] ?? '0.00',
      totalDiskon: map['total_diskon'] ?? '0.00',
      ppnPercent: map['ppn_percent'] ?? '0.00',
      ppnAmount: map['ppn_amount'] ?? '0.00',
      totalHargaSo: map['total_harga_so'] ?? '0.00',
      status: map['status'] ?? '',
      deleteRequestedBy: map['delete_requested_by'],
      deleteRequestedAt: map['delete_requested_at'] != null 
          ? DateTime.tryParse(map['delete_requested_at'])
          : null,
      deleteApprovedBy: map['delete_approved_by'],
      deleteApprovedAt: map['delete_approved_at'] != null 
          ? DateTime.tryParse(map['delete_approved_at'])
          : null,
      deleteReason: map['delete_reason'],
      deleteRejectionReason: map['delete_rejection_reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_so': nomorSo,
      'tanggal_so': tanggalSo.toIso8601String(),
      'tanggal_pengiriman': tanggalPengiriman.toIso8601String(),
      'syarat_pembayaran': syaratPembayaran,
      'gudang_id': gudangId,
      'pelanggan_id': pelangganId,
      'subtotal': subtotal,
      'total_diskon': totalDiskon,
      'ppn_percent': ppnPercent,
      'ppn_amount': ppnAmount,
      'total_harga_so': totalHargaSo,
      'status': status,
      'delete_requested_by': deleteRequestedBy,
      'delete_requested_at': deleteRequestedAt?.toIso8601String(),
      'delete_approved_by': deleteApprovedBy,
      'delete_approved_at': deleteApprovedAt?.toIso8601String(),
      'delete_reason': deleteReason,
      'delete_rejection_reason': deleteRejectionReason,
    };
  }
}

class Pelanggan {
  final int id;
  final String kode;
  final String namaPelanggan;
  final String kota;
  final String teleponHp;
  final String contactPerson;

  Pelanggan({
    required this.id,
    required this.kode,
    required this.namaPelanggan,
    required this.kota,
    required this.teleponHp,
    required this.contactPerson,
  });

  factory Pelanggan.fromMap(Map<String, dynamic> map) {
    return Pelanggan(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      namaPelanggan: map['nama_pelanggan'] ?? '',
      kota: map['kota'] ?? '',
      teleponHp: map['telepon_hp'] ?? '',
      contactPerson: map['contact_person'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_pelanggan': namaPelanggan,
      'kota': kota,
      'telepon_hp': teleponHp,
      'contact_person': contactPerson,
    };
  }
}

class Gudang {
  final int id;
  final String kode;
  final String namaGudang;
  final String? tipeGudang;
  final int? parentId;
  final String? teleponHp;
  final String? kapasitas;

  Gudang({
    required this.id,
    required this.kode,
    required this.namaGudang,
    this.tipeGudang,
    this.parentId,
    this.teleponHp,
    this.kapasitas,
  });

  factory Gudang.fromMap(Map<String, dynamic> map) {
    return Gudang(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      namaGudang: map['nama_gudang'] ?? '',
      tipeGudang: map['tipe_gudang'],
      parentId: map['parent_id'],
      teleponHp: map['telepon_hp'],
      kapasitas: map['kapasitas'],
    );
  }

  Map<String, dynamic> toMap() {
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

class WorkOrderPelaksana {
  final int id;
  final String kode;
  final String namaPelaksana;
  final String? jabatan;
  final String? departemen;
  final String? level;

  WorkOrderPelaksana({
    required this.id,
    required this.kode,
    required this.namaPelaksana,
    this.jabatan,
    this.departemen,
    this.level,
  });

  factory WorkOrderPelaksana.fromMap(Map<String, dynamic> map) {
    return WorkOrderPelaksana(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      namaPelaksana: map['nama_pelaksana'] ?? '',
      jabatan: map['jabatan'],
      departemen: map['departemen'],
      level: map['level'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_pelaksana': namaPelaksana,
      'jabatan': jabatan,
      'departemen': departemen,
      'level': level,
    };
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      currentPage: map['current_page'] ?? 1,
      perPage: map['per_page'] ?? 10,
      lastPage: map['last_page'] ?? 1,
      total: map['total'] ?? 0,
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

class WorkOrderPlanningListResponse {
  final bool success;
  final String message;
  final List<WorkOrderPlanning> data;
  final Pagination pagination;

  WorkOrderPlanningListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory WorkOrderPlanningListResponse.fromMap(Map<String, dynamic> map) {
    return WorkOrderPlanningListResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: (map['data'] as List<dynamic>?)
          ?.map((item) => WorkOrderPlanning.fromMap(item))
          .toList() ?? [],
      pagination: Pagination.fromMap(map['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toMap()).toList(),
      'pagination': pagination.toMap(),
    };
  }
}

class WorkOrderPlanningResult {
  final bool success;
  final String message;
  final WorkOrderPlanning data;

  WorkOrderPlanningResult({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WorkOrderPlanningResult.fromMap(Map<String, dynamic> map) {
    return WorkOrderPlanningResult(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: WorkOrderPlanning.fromMap(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.toMap(),
    };
  }
}

class JenisBarang {
  final int id;
  final String kode;
  final String namaJenis;

  JenisBarang({
    required this.id,
    required this.kode,
    required this.namaJenis,
  });

  factory JenisBarang.fromMap(Map<String, dynamic> map) {
    return JenisBarang(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      namaJenis: map['nama_jenis'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_jenis': namaJenis,
    };
  }
}

class BentukBarang {
  final int id;
  final String kode;
  final String namaBentuk;
  final String dimensi;

  BentukBarang({
    required this.id,
    required this.kode,
    required this.namaBentuk,
    required this.dimensi,
  });

  factory BentukBarang.fromMap(Map<String, dynamic> map) {
    return BentukBarang(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      namaBentuk: map['nama_bentuk'] ?? '',
      dimensi: map['dimensi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_bentuk': namaBentuk,
      'dimensi': dimensi,
    };
  }
}

class GradeBarang {
  final int id;
  final String kode;
  final String nama;

  GradeBarang({
    required this.id,
    required this.kode,
    required this.nama,
  });

  factory GradeBarang.fromMap(Map<String, dynamic> map) {
    return GradeBarang(
      id: map['id'] ?? 0,
      kode: map['kode'] ?? '',
      nama: map['nama'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
    };
  }
}
