import 'package:flutter/foundation.dart';

// ItemBarang model
class ItemBarang {
  final int id;
  final String kodeBarang;
  final int? jenisBarangId;
  final int? bentukBarangId;
  final int? gradeBarangId;
  final String namaItemBarang;
  final double? sisaLuas;
  final String? panjang;
  final String? lebar;
  final String? tebal;
  final String? berat;
  final int? quantity;
  final int? quantityTebalSama;
  final String? jenisPotongan;
  final bool? isAvailable;
  final bool? isEdit;
  final bool? isOnprogressPo;
  final int? userId;
  final String? canvasFile;
  final String? canvasImage;
  final String? convertDate;
  final String? splitDate;
  final String? mergeDate;
  final int? gudangId;
  final int? idRak;
  final String? frozenAt;
  final int? frozenBy;
  final String? createdAt;
  final String? updatedAt;

  ItemBarang({
    required this.id,
    required this.kodeBarang,
    this.jenisBarangId,
    this.bentukBarangId,
    this.gradeBarangId,
    required this.namaItemBarang,
    this.sisaLuas,
    this.panjang,
    this.lebar,
    this.tebal,
    this.berat,
    this.quantity,
    this.quantityTebalSama,
    this.jenisPotongan,
    this.isAvailable,
    this.isEdit,
    this.isOnprogressPo,
    this.userId,
    this.canvasFile,
    this.canvasImage,
    this.convertDate,
    this.splitDate,
    this.mergeDate,
    this.gudangId,
    this.idRak,
    this.frozenAt,
    this.frozenBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemBarang.fromMap(Map<String, dynamic> map) {
    return ItemBarang(
      id: _parseToInt(map['id']),
      kodeBarang: map['kode_barang'] ?? '',
      jenisBarangId: map['jenis_barang_id'] != null ? _parseToInt(map['jenis_barang_id']) : null,
      bentukBarangId: map['bentuk_barang_id'] != null ? _parseToInt(map['bentuk_barang_id']) : null,
      gradeBarangId: map['grade_barang_id'] != null ? _parseToInt(map['grade_barang_id']) : null,
      namaItemBarang: map['nama_item_barang'] ?? '',
      sisaLuas: map['sisa_luas'] != null ? _parseToDouble(map['sisa_luas']) : null,
      panjang: map['panjang']?.toString(),
      lebar: map['lebar']?.toString(),
      tebal: map['tebal']?.toString(),
      berat: map['berat']?.toString(),
      quantity: map['quantity'] != null ? _parseToInt(map['quantity']) : null,
      quantityTebalSama: map['quantity_tebal_sama'] != null ? _parseToInt(map['quantity_tebal_sama']) : null,
      jenisPotongan: map['jenis_potongan'],
      isAvailable: map['is_available'] as bool?,
      isEdit: map['is_edit'] as bool?,
      isOnprogressPo: map['is_onprogress_po'] as bool?,
      userId: map['user_id'] != null ? _parseToInt(map['user_id']) : null,
      canvasFile: map['canvas_file'],
      canvasImage: map['canvas_image'],
      convertDate: map['convert_date'],
      splitDate: map['split_date'],
      mergeDate: map['merge_date'],
      gudangId: map['gudang_id'] != null ? _parseToInt(map['gudang_id']) : null,
      idRak: map['id_rak'] != null ? _parseToInt(map['id_rak']) : null,
      frozenAt: map['frozen_at'],
      frozenBy: map['frozen_by'] != null ? _parseToInt(map['frozen_by']) : null,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'jenis_barang_id': jenisBarangId,
      'bentuk_barang_id': bentukBarangId,
      'grade_barang_id': gradeBarangId,
      'nama_item_barang': namaItemBarang,
      'sisa_luas': sisaLuas,
      'panjang': panjang,
      'lebar': lebar,
      'tebal': tebal,
      'berat': berat,
      'quantity': quantity,
      'quantity_tebal_sama': quantityTebalSama,
      'jenis_potongan': jenisPotongan,
      'is_available': isAvailable,
      'is_edit': isEdit,
      'is_onprogress_po': isOnprogressPo,
      'user_id': userId,
      'canvas_file': canvasFile,
      'canvas_image': canvasImage,
      'convert_date': convertDate,
      'split_date': splitDate,
      'merge_date': mergeDate,
      'gudang_id': gudangId,
      'id_rak': idRak,
      'frozen_at': frozenAt,
      'frozen_by': frozenBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Rak model
class Rak {
  final int id;
  final String kode;
  final String namaRak;
  final int? gudangId;
  final int? kapasitas;

  Rak({
    required this.id,
    required this.kode,
    required this.namaRak,
    this.gudangId,
    this.kapasitas,
  });

  factory Rak.fromMap(Map<String, dynamic> map) {
    return Rak(
      id: _parseToInt(map['id']),
      kode: map['kode'] ?? '',
      namaRak: map['nama_rak'] ?? '',
      gudangId: map['gudang_id'] != null ? _parseToInt(map['gudang_id']) : null,
      kapasitas: map['kapasitas'] != null ? _parseToInt(map['kapasitas']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_rak': namaRak,
      'gudang_id': gudangId,
      'kapasitas': kapasitas,
    };
  }
}

// Helper functions to safely parse values that might be String or num
int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

class PenerimaanBarangDetail {
  final int id;
  final int idPenerimaanBarang;
  final int idItemBarang;
  final int idRak;
  final int qty;
  final int? idPurchaseOrderItem;
  final int? idStockMutationDetail;
  final ItemBarang? itemBarang;
  final Rak? rak;

  PenerimaanBarangDetail({
    required this.id,
    required this.idPenerimaanBarang,
    required this.idItemBarang,
    required this.idRak,
    required this.qty,
    this.idPurchaseOrderItem,
    this.idStockMutationDetail,
    this.itemBarang,
    this.rak,
  });

  factory PenerimaanBarangDetail.fromMap(Map<String, dynamic> map) {
    return PenerimaanBarangDetail(
      id: _parseToInt(map['id']),
      idPenerimaanBarang: _parseToInt(map['id_penerimaan_barang']),
      idItemBarang: _parseToInt(map['id_item_barang']),
      idRak: _parseToInt(map['id_rak']),
      qty: _parseToInt(map['qty']),
      idPurchaseOrderItem: map['id_purchase_order_item'] != null ? _parseToInt(map['id_purchase_order_item']) : null,
      idStockMutationDetail: map['id_stock_mutation_detail'] != null ? _parseToInt(map['id_stock_mutation_detail']) : null,
      itemBarang: _parseItemBarang(map['item_barang']),
      rak: _parseRak(map['rak']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_penerimaan_barang': idPenerimaanBarang,
      'id_item_barang': idItemBarang,
      'id_rak': idRak,
      'qty': qty,
      'id_purchase_order_item': idPurchaseOrderItem,
      'id_stock_mutation_detail': idStockMutationDetail,
      'item_barang': itemBarang?.toMap(),
      'rak': rak?.toMap(),
    };
  }

  static ItemBarang? _parseItemBarang(dynamic itemBarang) {
    try {
      if (itemBarang is Map<String, dynamic>) {
        return ItemBarang.fromMap(itemBarang);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing item_barang: $e');
      return null;
    }
  }

  static Rak? _parseRak(dynamic rak) {
    try {
      if (rak is Map<String, dynamic>) {
        return Rak.fromMap(rak);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing rak: $e');
      return null;
    }
  }
}

class PurchaseOrder {
  final int id;
  final String nomorPo;
  final String tanggalPo;
  final int? idSupplier;
  final String? tanggalPenerimaan;
  final String? status;
  final double? totalHarga;

  PurchaseOrder({
    required this.id,
    required this.nomorPo,
    required this.tanggalPo,
    this.idSupplier,
    this.tanggalPenerimaan,
    this.status,
    this.totalHarga,
  });

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: _parseToInt(map['id']),
      nomorPo: map['nomor_po'] ?? '',
      tanggalPo: map['tanggal_po'] ?? '',
      idSupplier: map['id_supplier'] != null ? _parseToInt(map['id_supplier']) : null,
      tanggalPenerimaan: map['tanggal_penerimaan'],
      status: map['status'],
      totalHarga: map['total_harga'] != null ? _parseToDouble(map['total_harga']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_po': nomorPo,
      'tanggal_po': tanggalPo,
      'id_supplier': idSupplier,
      'tanggal_penerimaan': tanggalPenerimaan,
      'status': status,
      'total_harga': totalHarga,
    };
  }
}

class StockMutation {
  final int id;
  final String nomorMutasi;
  final String createdAt;

  StockMutation({
    required this.id,
    required this.nomorMutasi,
    required this.createdAt,
  });

  factory StockMutation.fromMap(Map<String, dynamic> map) {
    return StockMutation(
      id: _parseToInt(map['id']),
      nomorMutasi: map['nomor_mutasi'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_mutasi': nomorMutasi,
      'created_at': createdAt,
    };
  }
}

class GudangPenerimaan {
  final int id;
  final String namaGudang;
  final String kode;
  final String? kodeGudang;
  final String? alamat;
  final String? tipeGudang;

  GudangPenerimaan({
    required this.id,
    required this.namaGudang,
    required this.kode,
    this.kodeGudang,
    this.alamat,
    this.tipeGudang,
  });

  factory GudangPenerimaan.fromMap(Map<String, dynamic> map) {
    return GudangPenerimaan(
      id: _parseToInt(map['id']),
      namaGudang: map['nama_gudang'] ?? '',
      // Support both old 'kode' and new 'kode_gudang' for backward compatibility
      kode: map['kode'] ?? map['kode_gudang'] ?? '',
      kodeGudang: map['kode_gudang'],
      alamat: map['alamat'],
      tipeGudang: map['tipe_gudang'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_gudang': namaGudang,
      'kode': kode,
      'kode_gudang': kodeGudang,
      'alamat': alamat,
      'tipe_gudang': tipeGudang,
    };
  }
}

class PenerimaanBarang {
  final int id;
  final String origin;
  final int? idPurchaseOrder;
  final int? idStockMutation;
  final int idGudang;
  final String catatan;
  final String? urlFoto;
  final String createdAt;
  final PurchaseOrder? purchaseOrder;
  final StockMutation? stockMutation;
  final GudangPenerimaan gudang;
  final List<PenerimaanBarangDetail> penerimaanBarangDetails;

  PenerimaanBarang({
    required this.id,
    required this.origin,
    this.idPurchaseOrder,
    this.idStockMutation,
    required this.idGudang,
    required this.catatan,
    this.urlFoto,
    required this.createdAt,
    this.purchaseOrder,
    this.stockMutation,
    required this.gudang,
    required this.penerimaanBarangDetails,
  });

  factory PenerimaanBarang.fromMap(Map<String, dynamic> map) {
    return PenerimaanBarang(
      id: _parseToInt(map['id']),
      origin: map['origin'] ?? '',
      idPurchaseOrder: map['id_purchase_order'] != null ? _parseToInt(map['id_purchase_order']) : null,
      idStockMutation: map['id_stock_mutation'] != null ? _parseToInt(map['id_stock_mutation']) : null,
      idGudang: _parseToInt(map['id_gudang']),
      catatan: map['catatan'] ?? '',
      urlFoto: map['url_foto'],
      createdAt: map['created_at'] ?? '',
      purchaseOrder: _parsePurchaseOrder(map['purchase_order']),
      stockMutation: _parseStockMutation(map['stock_mutation']),
      gudang: _parseGudang(map['gudang']),
      penerimaanBarangDetails: _parsePenerimaanBarangDetails(map['penerimaan_barang_details']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origin': origin,
      'id_purchase_order': idPurchaseOrder,
      'id_stock_mutation': idStockMutation,
      'id_gudang': idGudang,
      'catatan': catatan,
      'url_foto': urlFoto,
      'created_at': createdAt,
      'purchase_order': purchaseOrder?.toMap(),
      'stock_mutation': stockMutation?.toMap(),
      'gudang': gudang.toMap(),
      'penerimaan_barang_details': penerimaanBarangDetails.map((detail) => detail.toMap()).toList(),
    };
  }

  static PurchaseOrder? _parsePurchaseOrder(dynamic purchaseOrder) {
    try {
      if (purchaseOrder is Map<String, dynamic>) {
        return PurchaseOrder.fromMap(purchaseOrder);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing purchase_order: $e');
      return null;
    }
  }

  static StockMutation? _parseStockMutation(dynamic stockMutation) {
    try {
      if (stockMutation is Map<String, dynamic>) {
        return StockMutation.fromMap(stockMutation);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing stock_mutation: $e');
      return null;
    }
  }

  static GudangPenerimaan _parseGudang(dynamic gudang) {
    try {
      if (gudang is Map<String, dynamic>) {
        return GudangPenerimaan.fromMap(gudang);
      }
      return GudangPenerimaan(id: 0, namaGudang: 'Unknown', kode: 'UNK');
    } catch (e) {
      debugPrint('Error parsing gudang: $e');
      return GudangPenerimaan(id: 0, namaGudang: 'Unknown', kode: 'UNK');
    }
  }

  static List<PenerimaanBarangDetail> _parsePenerimaanBarangDetails(dynamic details) {
    if (details == null) return [];
    
    try {
      if (details is List) {
        return details
            .where((detail) => detail is Map<String, dynamic>)
            .map((detail) => PenerimaanBarangDetail.fromMap(detail as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing penerimaan_barang_details: $e');
      return [];
    }
  }
}

class PenerimaanBarangDetailInput {
  final int idItemBarang;
  final int idRak;
  final int qty;
  final int? idPurchaseOrderItem;
  final int? idStockMutationDetail;

  PenerimaanBarangDetailInput({
    required this.idItemBarang,
    required this.idRak,
    required this.qty,
    this.idPurchaseOrderItem,
    this.idStockMutationDetail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_item_barang': idItemBarang,
      'id_rak': idRak,
      'qty': qty,
      'id_purchase_order_item': idPurchaseOrderItem,
      'id_stock_mutation_detail': idStockMutationDetail,
    };
  }
}

class PenerimaanBarangInput {
  final String origin;
  final int? idPurchaseOrder;
  final int? idStockMutation;
  final int idGudang;
  final String catatan;
  final String? urlFoto;
  final List<PenerimaanBarangDetailInput> details;

  PenerimaanBarangInput({
    required this.origin,
    this.idPurchaseOrder,
    this.idStockMutation,
    required this.idGudang,
    required this.catatan,
    this.urlFoto,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'id_purchase_order': idPurchaseOrder,
      'id_stock_mutation': idStockMutation,
      'id_gudang': idGudang,
      'catatan': catatan,
      'url_foto': urlFoto,
      'details': details.map((detail) => detail.toMap()).toList(),
    };
  }
}

// New models for the updated API format
class PenerimaanBarangSubmitRequest {
  final String asalPenerimaan;
  final String? nomorPo;
  final String? nomorMutasi;
  final int gudangId;
  final String catatan;
  final String? buktiFoto; // base64 string
  final List<DetailBarangSubmit> detailBarang;

  PenerimaanBarangSubmitRequest({
    required this.asalPenerimaan,
    this.nomorPo,
    this.nomorMutasi,
    required this.gudangId,
    required this.catatan,
    this.buktiFoto,
    required this.detailBarang,
  });

  Map<String, dynamic> toMap() {
    return {
      'asal_penerimaan': asalPenerimaan,
      'nomor_po': nomorPo,
      'nomor_mutasi': nomorMutasi,
      'gudang_id': gudangId,
      'catatan': catatan,
      'bukti_foto': buktiFoto,
      'detail_barang': detailBarang.map((detail) => detail.toMap()).toList(),
    };
  }
}

class DetailBarangSubmit {
  final int id;
  final String kode;
  final String namaItem;
  final String ukuran;
  final int qty;
  final String statusScan;
  final int idRak;

  DetailBarangSubmit({
    required this.id,
    required this.kode,
    required this.namaItem,
    required this.ukuran,
    required this.qty,
    required this.statusScan,
    required this.idRak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_item': namaItem,
      'ukuran': ukuran,
      'qty': qty,
      'status_scan': statusScan,
      'id_rak': idRak,
    };
  }
}

class PenerimaanBarangListResponse {
  final bool success;
  final String message;
  final PenerimaanBarangListData data;

  PenerimaanBarangListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PenerimaanBarangListResponse.fromMap(Map<String, dynamic> map) {
    return PenerimaanBarangListResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: PenerimaanBarangListData.fromMap(map['data'] ?? {}),
    );
  }
}

class PenerimaanBarangListData {
  final int currentPage;
  final List<PenerimaanBarang> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  PenerimaanBarangListData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PenerimaanBarangListData.fromMap(Map<String, dynamic> map) {
    return PenerimaanBarangListData(
      currentPage: _parseToInt(map['current_page']),
      data: (map['data'] as List<dynamic>?)
          ?.map((item) => PenerimaanBarang.fromMap(item))
          .toList() ?? [],
      firstPageUrl: map['first_page_url'] ?? '',
      from: _parseToInt(map['from']),
      lastPage: _parseToInt(map['last_page']),
      lastPageUrl: map['last_page_url'] ?? '',
      nextPageUrl: map['next_page_url'],
      path: map['path'] ?? '',
      perPage: _parseToInt(map['per_page']),
      prevPageUrl: map['prev_page_url'],
      to: _parseToInt(map['to']),
      total: _parseToInt(map['total']),
    );
  }
}

class PenerimaanBarangResponse {
  final bool success;
  final String message;
  final PenerimaanBarang data;

  PenerimaanBarangResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PenerimaanBarangResponse.fromMap(Map<String, dynamic> map) {
    // Handle both old format (success: boolean) and new format (status: "success")
    bool isSuccess = false;
    if (map.containsKey('success')) {
      isSuccess = map['success'] ?? false;
    } else if (map.containsKey('status')) {
      isSuccess = map['status'] == 'success';
    }
    
    return PenerimaanBarangResponse(
      success: isSuccess,
      message: map['message'] ?? '',
      data: PenerimaanBarang.fromMap(map['data'] ?? {}),
    );
  }
}
