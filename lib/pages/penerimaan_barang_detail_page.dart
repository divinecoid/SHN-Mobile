import 'package:flutter/material.dart';
import '../models/penerimaan_barang_model.dart';

class PenerimaanBarangDetailPage extends StatelessWidget {
  final PenerimaanBarang penerimaanBarang;

  const PenerimaanBarangDetailPage({
    super.key,
    required this.penerimaanBarang,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Detail Penerimaan Barang',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              _buildHeaderSection(),
              const SizedBox(height: 16),

              // Origin Info
              _buildOriginSection(),
              const SizedBox(height: 16),

              // Gudang Info
              _buildGudangSection(),
              const SizedBox(height: 16),

              // Catatan
              _buildCatatanSection(),
              const SizedBox(height: 16),

              // Photo
              if (penerimaanBarang.urlFoto != null) ...[
                _buildPhotoSection(),
                const SizedBox(height: 16),
              ],

              // Details List
              _buildDetailsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.blue[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Informasi Penerimaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getOriginColor(penerimaanBarang.origin),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getOriginLabel(penerimaanBarang.origin),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Penerimaan',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${penerimaanBarang.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source, color: Colors.cyan[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Asal Penerimaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (penerimaanBarang.purchaseOrder != null)
            _buildPurchaseOrderInfo()
          else if (penerimaanBarang.stockMutation != null)
            _buildStockMutationInfo()
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Text(
                'Tidak ada informasi asal',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOrderInfo() {
    final po = penerimaanBarang.purchaseOrder!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Order',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. PO',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      po.nomorPo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal PO',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      po.tanggalPo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockMutationInfo() {
    final sm = penerimaanBarang.stockMutation!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Mutation',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. Mutation',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      sm.nomorMutasi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Mutation',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      sm.createdAt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGudangSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Gudang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Gudang',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penerimaanBarang.gudang.namaGudang,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            penerimaanBarang.gudang.kode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${penerimaanBarang.gudang.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: Colors.yellow[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Catatan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Text(
              penerimaanBarang.catatan,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo, color: Colors.green[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Bukti Foto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                penerimaanBarang.urlFoto!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory, color: Colors.orange[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Detail Barang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${penerimaanBarang.penerimaanBarangDetails.length} item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (penerimaanBarang.penerimaanBarangDetails.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada detail barang',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: penerimaanBarang.penerimaanBarangDetails.length,
              itemBuilder: (context, index) {
                final detail = penerimaanBarang.penerimaanBarangDetails[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item ID: ${detail.idItemBarang}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rak ID: ${detail.idRak}',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${detail.qty} pcs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (detail.idPurchaseOrderItem != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'PO Item ID: ${detail.idPurchaseOrderItem}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                        if (detail.idStockMutationDetail != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Stock Mutation Detail ID: ${detail.idStockMutationDetail}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getOriginColor(String origin) {
    switch (origin.toLowerCase()) {
      case 'purchaseorder':
        return Colors.green[600]!;
      case 'stockmutation':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getOriginLabel(String origin) {
    switch (origin.toLowerCase()) {
      case 'purchaseorder':
        return 'Purchase Order';
      case 'stockmutation':
        return 'Stock Mutation';
      default:
        return origin.toUpperCase();
    }
  }
}
