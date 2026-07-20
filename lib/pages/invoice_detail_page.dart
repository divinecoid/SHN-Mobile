import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_pod_model.dart';

class InvoiceDetailPage extends StatelessWidget {
  final InvoicePodModel invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

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
      case 'paid':
      case 'lunas':
        return Colors.green[600]!;
      case 'unpaid':
      case 'belum_lunas':
      case 'pending':
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return 'Lunas';
      case 'unpaid':
      case 'belum_lunas':
        return 'Belum Lunas';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Detail Invoice'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            _buildInfoCard(),
            const SizedBox(height: 20),

            // Items Section
            const Text(
              'Item Invoice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (invoice.invoicePodItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Tidak ada item dalam Invoice ini', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...invoice.invoicePodItems.map((item) {
                final mapItem = item as Map<String, dynamic>;
                return _buildItemCard(mapItem);
              }),
            const SizedBox(height: 20),

            // Summary Section Card
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
                  invoice.nomorInvoice ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.statusBayar).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor(invoice.statusBayar)),
                  ),
                  child: Text(
                    _getStatusLabel(invoice.statusBayar),
                    style: TextStyle(
                      color: _getStatusColor(invoice.statusBayar),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow('Pelanggan', invoice.namaPelanggan),
            _buildDetailRow('Gudang', invoice.namaGudang),
            _buildDetailRow('No. SO', invoice.nomorSo),
            _buildDetailRow('No. WO', invoice.nomorWo),
            _buildDetailRow('Tanggal Cetak', _formatDate(invoice.tanggalCetakInvoice)),
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
    final itemName = item['nama_item'] ?? item['item_barang_group'] ?? '-';
    
    final int qty = int.tryParse(item['qty'].toString()) ?? 0;
    final double berat = double.tryParse((item['total_kg'] ?? 0).toString()) ?? 0;
    final double harga = double.tryParse((item['harga_per_unit'] ?? 0).toString()) ?? 0;
    final double total = double.tryParse((item['total_harga'] ?? 0).toString()) ?? 0;
    final String unitName = (item['unit'] ?? '').toString();
    final String dimensi = (item['dimensi_potong'] ?? '').toString();

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
            const Divider(color: Colors.grey, height: 16),
            if (dimensi.isNotEmpty && dimensi != '-') _buildMiniRow('Dimensi', dimensi),
            if (berat > 0) _buildMiniRow('Total Kg', '$berat kg'),
            _buildMiniRow('Qty / Satuan', '$qty $unitName'),
            _buildMiniRow('Harga Satuan', _formatCurrency(harga)),
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

  Widget _buildSummaryCard() {
    // Calculate PPN and Subtotal if not direct
    final double discount = double.tryParse(invoice.discountInvoice) ?? 0.0;
    final double grandTotal = double.tryParse(invoice.grandTotal) ?? 0.0;
    final double uangMuka = double.tryParse(invoice.uangMuka) ?? 0.0;
    final double sisaBayar = double.tryParse(invoice.sisaBayar) ?? 0.0;
    final double ppn = double.tryParse(invoice.ppnInvoice) ?? 0.0;
    final double subtotal = double.tryParse(invoice.totalHargaInvoice) ?? 0.0;

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Tagihan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Divider(color: Colors.grey, height: 24),
            _buildSummaryRow('Total Harga Invoice', _formatCurrency(subtotal)),
            if (discount > 0)
              _buildSummaryRow('Diskon', '- ${_formatCurrency(discount)}', valueColor: Colors.red[300]),
            _buildSummaryRow('PPN (11%)', _formatCurrency(ppn)),
            _buildSummaryRow('Grand Total', _formatCurrency(grandTotal), valueColor: Colors.green),
            _buildSummaryRow('Uang Muka', _formatCurrency(uangMuka)),
            const Divider(color: Colors.grey, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sisa Bayar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _formatCurrency(sisaBayar),
                  style: TextStyle(color: Colors.orange[400], fontWeight: FontWeight.bold, fontSize: 18),
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
