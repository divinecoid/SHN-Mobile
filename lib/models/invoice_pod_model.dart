class InvoicePodModel {
  final int id;
  final String? nomorInvoice;
  final String? nomorPod;
  final DateTime? tanggalCetakInvoice;
  final DateTime? tanggalCetakPod;
  final String totalHargaInvoice;
  final String discountInvoice;
  final String grandTotal;
  final String uangMuka;
  final String sisaBayar;
  final String statusBayar;
  final String statusPod;
  
  // Relations mapped flatly for easy UI usage
  final String nomorSo;
  final String nomorWo;
  final String namaPelanggan;
  final String namaGudang;

  InvoicePodModel({
    required this.id,
    this.nomorInvoice,
    this.nomorPod,
    this.tanggalCetakInvoice,
    this.tanggalCetakPod,
    required this.totalHargaInvoice,
    required this.discountInvoice,
    required this.grandTotal,
    required this.uangMuka,
    required this.sisaBayar,
    required this.statusBayar,
    required this.statusPod,
    required this.nomorSo,
    required this.nomorWo,
    required this.namaPelanggan,
    required this.namaGudang,
  });

  factory InvoicePodModel.fromMap(Map<String, dynamic> map) {
    // Parse nested relationships
    final so = map['sales_order'] ?? map['salesOrder'] ?? {};
    final pelanggan = so['pelanggan'] ?? so['customer'] ?? {};
    final wo = map['work_order_planning'] ?? map['workOrderPlanning'] ?? {};
    final gudang = wo['gudang'] ?? wo['warehouse'] ?? {};

    return InvoicePodModel(
      id: map['id'] ?? 0,
      nomorInvoice: map['nomor_invoice'] ?? map['nomorInvoice'],
      nomorPod: map['nomor_pod'] ?? map['nomorPod'],
      tanggalCetakInvoice: map['tanggal_cetak_invoice'] != null
          ? DateTime.tryParse(map['tanggal_cetak_invoice'].toString())
          : null,
      tanggalCetakPod: map['tanggal_cetak_pod'] != null
          ? DateTime.tryParse(map['tanggal_cetak_pod'].toString())
          : null,
      totalHargaInvoice: (map['total_harga_invoice'] ?? map['totalHargaInvoice'] ?? '0').toString(),
      discountInvoice: (map['discount_invoice'] ?? map['discountInvoice'] ?? '0').toString(),
      grandTotal: (map['grand_total'] ?? map['grandTotal'] ?? '0').toString(),
      uangMuka: (map['uang_muka'] ?? map['uangMuka'] ?? '0').toString(),
      sisaBayar: (map['sisa_bayar'] ?? map['sisaBayar'] ?? '0').toString(),
      statusBayar: (map['status_bayar'] ?? map['statusBayar'] ?? '').toString(),
      statusPod: (map['status_pod'] ?? map['statusPod'] ?? '').toString(),
      nomorSo: (so['nomor_so'] ?? so['nomorSo'] ?? wo['nomor_so'] ?? '').toString(),
      nomorWo: (wo['nomor_wo'] ?? wo['nomorWo'] ?? map['nomor_wo'] ?? '').toString(),
      namaPelanggan: (pelanggan['nama_pelanggan'] ?? pelanggan['namaPelanggan'] ?? pelanggan['nama'] ?? 'ID: ${so['pelanggan_id']}').toString(),
      namaGudang: (gudang['nama_gudang'] ?? gudang['namaGudang'] ?? gudang['nama'] ?? 'ID: ${wo['gudang_id']}').toString(),
    );
  }
}
