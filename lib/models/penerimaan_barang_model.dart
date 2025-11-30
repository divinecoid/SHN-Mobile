import 'package:flutter/foundation.dart';

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

class PenerimaanBarangDetail {
  final int id;
  final int idPenerimaanBarang;
  final int idItemBarang;
  final int idRak;
  final int qty;
  final int? idPurchaseOrderItem;
  final int? idStockMutationDetail;

  PenerimaanBarangDetail({
    required this.id,
    required this.idPenerimaanBarang,
    required this.idItemBarang,
    required this.idRak,
    required this.qty,
    this.idPurchaseOrderItem,
    this.idStockMutationDetail,
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
    };
  }
}

class PurchaseOrder {
  final int id;
  final String nomorPo;
  final String tanggalPo;

  PurchaseOrder({
    required this.id,
    required this.nomorPo,
    required this.tanggalPo,
  });

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: _parseToInt(map['id']),
      nomorPo: map['nomor_po'] ?? '',
      tanggalPo: map['tanggal_po'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor_po': nomorPo,
      'tanggal_po': tanggalPo,
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

  GudangPenerimaan({
    required this.id,
    required this.namaGudang,
    required this.kode,
  });

  factory GudangPenerimaan.fromMap(Map<String, dynamic> map) {
    return GudangPenerimaan(
      id: _parseToInt(map['id']),
      namaGudang: map['nama_gudang'] ?? '',
      kode: map['kode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_gudang': namaGudang,
      'kode': kode,
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

  DetailBarangSubmit({
    required this.id,
    required this.kode,
    required this.namaItem,
    required this.ukuran,
    required this.qty,
    required this.statusScan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode': kode,
      'nama_item': namaItem,
      'ukuran': ukuran,
      'qty': qty,
      'status_scan': statusScan,
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
    return PenerimaanBarangResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: PenerimaanBarang.fromMap(map['data'] ?? {}),
    );
  }
}
