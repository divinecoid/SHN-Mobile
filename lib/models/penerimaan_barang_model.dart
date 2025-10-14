import 'package:flutter/foundation.dart';

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
      id: map['id'] ?? 0,
      idPenerimaanBarang: map['id_penerimaan_barang'] ?? 0,
      idItemBarang: map['id_item_barang'] ?? 0,
      idRak: map['id_rak'] ?? 0,
      qty: map['qty'] ?? 0,
      idPurchaseOrderItem: map['id_purchase_order_item'],
      idStockMutationDetail: map['id_stock_mutation_detail'],
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
  final String noPo;
  final String tanggalPo;

  PurchaseOrder({
    required this.id,
    required this.noPo,
    required this.tanggalPo,
  });

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'] ?? 0,
      noPo: map['no_po'] ?? '',
      tanggalPo: map['tanggal_po'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_po': noPo,
      'tanggal_po': tanggalPo,
    };
  }
}

class StockMutation {
  final int id;
  final String noMutation;
  final String tanggalMutation;

  StockMutation({
    required this.id,
    required this.noMutation,
    required this.tanggalMutation,
  });

  factory StockMutation.fromMap(Map<String, dynamic> map) {
    return StockMutation(
      id: map['id'] ?? 0,
      noMutation: map['no_mutation'] ?? '',
      tanggalMutation: map['tanggal_mutation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_mutation': noMutation,
      'tanggal_mutation': tanggalMutation,
    };
  }
}

class GudangPenerimaan {
  final int id;
  final String nama;
  final String kode;

  GudangPenerimaan({
    required this.id,
    required this.nama,
    required this.kode,
  });

  factory GudangPenerimaan.fromMap(Map<String, dynamic> map) {
    return GudangPenerimaan(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      kode: map['kode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
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
    this.purchaseOrder,
    this.stockMutation,
    required this.gudang,
    required this.penerimaanBarangDetails,
  });

  factory PenerimaanBarang.fromMap(Map<String, dynamic> map) {
    return PenerimaanBarang(
      id: map['id'] ?? 0,
      origin: map['origin'] ?? '',
      idPurchaseOrder: map['id_purchase_order'],
      idStockMutation: map['id_stock_mutation'],
      idGudang: map['id_gudang'] ?? 0,
      catatan: map['catatan'] ?? '',
      urlFoto: map['url_foto'],
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
      return GudangPenerimaan(id: 0, nama: 'Unknown', kode: 'UNK');
    } catch (e) {
      debugPrint('Error parsing gudang: $e');
      return GudangPenerimaan(id: 0, nama: 'Unknown', kode: 'UNK');
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
      currentPage: map['current_page'] ?? 1,
      data: (map['data'] as List<dynamic>?)
          ?.map((item) => PenerimaanBarang.fromMap(item))
          .toList() ?? [],
      firstPageUrl: map['first_page_url'] ?? '',
      from: map['from'] ?? 0,
      lastPage: map['last_page'] ?? 1,
      lastPageUrl: map['last_page_url'] ?? '',
      nextPageUrl: map['next_page_url'],
      path: map['path'] ?? '',
      perPage: map['per_page'] ?? 10,
      prevPageUrl: map['prev_page_url'],
      to: map['to'] ?? 0,
      total: map['total'] ?? 0,
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
