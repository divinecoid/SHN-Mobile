import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/sales_order_controller.dart';
import '../models/work_order_planning_model.dart';

class SalesOrderDetailPage extends StatefulWidget {
  final int salesOrderId;

  const SalesOrderDetailPage({super.key, required this.salesOrderId});

  @override
  State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends State<SalesOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesOrderController>().fetchSalesOrderDetail(widget.salesOrderId);
    });
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return 'Rp 0';
    try {
      final double number = double.parse(val.toString());
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(number);
    } catch (_) {
      return 'Rp $val';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[700]!;
      case 'partial_wo':
        return Colors.blue[600]!;
      case 'full_wo':
      case 'complete':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'partial_wo':
        return 'Partial WO';
      case 'full_wo':
      case 'complete':
        return 'Selesai';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDimensions(Map<String, dynamic> item) {
    final tebal = item['tebal'] ?? 0;
    final lebar = item['lebar'] ?? 0;
    final panjang = item['panjang'] ?? 0;
    
    final List<String> parts = [];
    if (tebal > 0) parts.add('${tebal.toString().replaceAll(RegExp(r'\.0$'), '')} thk');
    if (lebar > 0) parts.add('${lebar.toString().replaceAll(RegExp(r'\.0$'), '')} w');
    if (panjang > 0) parts.add('${panjang.toString().replaceAll(RegExp(r'\.0$'), '')} L');
    
    if (parts.isEmpty) return '-';
    return parts.join(' x ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Detail Sales Order'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Consumer<SalesOrderController>(
        builder: (context, controller, child) {
          if (controller.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (controller.errorDetail != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorDetail!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchSalesOrderDetail(widget.salesOrderId);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final so = controller.selectedSalesOrder;
          if (so == null) {
            return const Center(
              child: Text('Data Sales Order tidak ditemukan.', style: TextStyle(color: Colors.grey)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Header Card
                _buildInfoCard(so),
                const SizedBox(height: 20),

                // Items Section
                const Text(
                  'Item Sales Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (controller.selectedSalesOrderItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Tidak ada item dalam Sales Order ini', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...controller.selectedSalesOrderItems.map((item) {
                    final mapItem = item as Map<String, dynamic>;
                    return _buildItemCard(mapItem);
                  }),
                const SizedBox(height: 20),

                // Summary Section Card
                _buildSummaryCard(so),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(SalesOrder so) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  so.nomorSo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(so.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor(so.status)),
                  ),
                  child: Text(
                    _getStatusLabel(so.status),
                    style: TextStyle(
                      color: _getStatusColor(so.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow('Pelanggan', so.pelanggan?.namaPelanggan ?? 'ID: ${so.pelangganId}'),
            _buildDetailRow('Gudang Asal', so.gudang?.namaGudang ?? 'ID: ${so.gudangId}'),
            _buildDetailRow('Tanggal SO', _formatDate(so.tanggalSo)),
            _buildDetailRow('Tanggal Pengiriman', _formatDate(so.tanggalPengiriman)),
            _buildDetailRow('Syarat Pembayaran', so.syaratPembayaran.isNotEmpty ? so.syaratPembayaran : '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final jb = item['jenis_barang']?['nama_jenis'] ?? item['jenis_barang']?['nama'] ?? '-';
    final bb = item['bentuk_barang']?['nama_bentuk'] ?? item['bentuk_barang']?['nama'] ?? '-';
    final gb = item['grade_barang']?['nama'] ?? '-';
    final itemName = item['item_barang_group']?['nama_group_barang'] ?? item['master_item_nama'] ?? '-';
    
    final double qty = double.tryParse((item['qty'] ?? item['quantity'] ?? 0).toString()) ?? 0;
    final double berat = double.tryParse((item['berat'] ?? item['weight'] ?? 0).toString()) ?? 0;
    final double harga = double.tryParse((item['harga'] ?? item['price'] ?? 0).toString()) ?? 0;
    final double total = double.tryParse((item['total'] ?? item['subtotal'] ?? 0).toString()) ?? 0;
    final String diskonType = item['diskon_type']?.toString() ?? 'percent';
    final double diskon = double.tryParse((item['diskon'] ?? item['discount'] ?? 0).toString()) ?? 0;
    
    final String unitName = item['satuan_barang']?['nama'] ?? item['unit']?['nama'] ?? item['satuan'] ?? '';

    String diskonDisplay = '-';
    if (diskon > 0) {
      diskonDisplay = diskonType == 'nominal' ? _formatCurrency(diskon) : '${diskon.toString().replaceAll(RegExp(r'\.0$'), '')}%';
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniDetail('Jenis', jb),
                _buildMiniDetail('Bentuk', bb),
                _buildMiniDetail('Grade', gb),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.grey, height: 16),
            _buildMiniRow('Dimensi', _formatDimensions(item)),
            _buildMiniRow('Berat', berat > 0 ? '$berat kg' : '-'),
            _buildMiniRow('Qty / Satuan', '${qty.toString().replaceAll(RegExp(r'\.0$'), '')} $unitName'),
            _buildMiniRow('Harga Satuan', _formatCurrency(harga)),
            _buildMiniRow('Diskon', diskonDisplay),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(total),
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SalesOrder so) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Biaya',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Divider(color: Colors.grey, height: 24),
            _buildSummaryRow('Subtotal', _formatCurrency(so.subtotal)),
            _buildSummaryRow('Total Diskon', '- ${_formatCurrency(so.totalDiskon)}', valueColor: Colors.red[300]),
            _buildSummaryRow('PPN (11%)', _formatCurrency(so.ppnAmount)),
            const Divider(color: Colors.grey, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _formatCurrency(so.totalHargaSo),
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
