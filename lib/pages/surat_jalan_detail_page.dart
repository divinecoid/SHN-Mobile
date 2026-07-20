import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_pod_model.dart';

class SuratJalanDetailPage extends StatelessWidget {
  final InvoicePodModel pod;

  const SuratJalanDetailPage({super.key, required this.pod});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'handover':
      case 'hand_over':
      case 'complete':
      case 'selesai':
        return Colors.green[600]!;
      case 'pending':
      case 'proses':
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'handover':
      case 'hand_over':
        return 'Hand Over';
      case 'pending':
        return 'Pending';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Detail Surat Jalan'),
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
              'Item Surat Jalan (POD)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (pod.invoicePodItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Tidak ada item dalam Surat Jalan ini', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...pod.invoicePodItems.map((item) {
                final mapItem = item as Map<String, dynamic>;
                return _buildItemCard(mapItem);
              }),
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
                  pod.nomorPod ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pod.statusPod).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor(pod.statusPod)),
                  ),
                  child: Text(
                    _getStatusLabel(pod.statusPod),
                    style: TextStyle(
                      color: _getStatusColor(pod.statusPod),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow('Pelanggan', pod.namaPelanggan),
            _buildDetailRow('Gudang', pod.namaGudang),
            _buildDetailRow('No. SO', pod.nomorSo),
            _buildDetailRow('No. WO', pod.nomorWo),
            _buildDetailRow('Tanggal Cetak POD', _formatDate(pod.tanggalCetakPod)),
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
}
