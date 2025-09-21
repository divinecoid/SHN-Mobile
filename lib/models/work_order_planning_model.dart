class WorkOrderPlanning {
  final int id;
  final String woUniqueId;
  final String nomorWo;
  final DateTime tanggalWo;
  final int idSalesOrder;
  final int idPelanggan;
  final int idGudang;
  final int idPelaksana;
  final String prioritas;
  final String status;
  final List<WorkOrderPlanningItem> workOrderPlanningItems;
  final SalesOrder? salesOrder;
  final Pelanggan? pelanggan;
  final DateTime? deletedAt;

  WorkOrderPlanning({
    required this.id,
    required this.woUniqueId,
    required this.nomorWo,
    required this.tanggalWo,
    required this.idSalesOrder,
    required this.idPelanggan,
    required this.idGudang,
    required this.idPelaksana,
    required this.prioritas,
    required this.status,
    required this.workOrderPlanningItems,
    this.salesOrder,
    this.pelanggan,
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
      idPelaksana: map['id_pelaksana'] ?? 0,
      prioritas: map['prioritas'] ?? '',
      status: map['status'] ?? '',
      workOrderPlanningItems: (map['work_order_planning_items'] as List<dynamic>?)
          ?.map((item) => WorkOrderPlanningItem.fromMap(item))
          .toList() ?? [],
      salesOrder: map['sales_order'] != null 
          ? SalesOrder.fromMap(map['sales_order'])
          : null,
      pelanggan: map['pelanggan'] != null 
          ? Pelanggan.fromMap(map['pelanggan'])
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
      'work_order_planning_items': workOrderPlanningItems.map((item) => item.toMap()).toList(),
      'sales_order': salesOrder?.toMap(),
      'pelanggan': pelanggan?.toMap(),
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
  final String nama;
  final String? alamat;
  final String? kode;

  Gudang({
    required this.id,
    required this.nama,
    this.alamat,
    this.kode,
  });

  factory Gudang.fromMap(Map<String, dynamic> map) {
    return Gudang(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      alamat: map['alamat'],
      kode: map['kode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'kode': kode,
    };
  }
}

class Pelaksana {
  final int id;
  final String nama;
  final String? jabatan;
  final String? departemen;

  Pelaksana({
    required this.id,
    required this.nama,
    this.jabatan,
    this.departemen,
  });

  factory Pelaksana.fromMap(Map<String, dynamic> map) {
    return Pelaksana(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      jabatan: map['jabatan'],
      departemen: map['departemen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jabatan': jabatan,
      'departemen': departemen,
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
