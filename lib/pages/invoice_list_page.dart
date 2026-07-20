import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/invoice_pod_controller.dart';
import '../models/invoice_pod_model.dart';
import 'invoice_detail_page.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<InvoicePodController>();
      controller.clearFilters();
      controller.fetchInvoicePods(page: 1, context: context);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final controller = context.read<InvoicePodController>();
      if (!controller.isLoading && controller.pagination != null && _currentPage < controller.pagination!.lastPage) {
        _currentPage++;
        controller.fetchInvoicePods(page: _currentPage, context: context);
      }
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    await context.read<InvoicePodController>().fetchInvoicePods(page: 1, context: context);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String _formatCurrency(String val) {
    try {
      final double number = double.parse(val);
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

  Future<void> _selectDateRange(InvoicePodController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: controller.startDate != null && controller.endDate != null
          ? DateTimeRange(start: controller.startDate!, end: controller.endDate!)
          : DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
      _currentPage = 1;
      controller.fetchInvoicePods(page: 1, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<InvoicePodController>(
        builder: (context, controller, child) {
          // Filter to show only generated invoices
          final listInvoices = controller.invoicePods.where((x) => x.nomorInvoice != null && x.nomorInvoice!.isNotEmpty).toList();
          final double totalNilaiFiltered = listInvoices.fold(0.0, (sum, item) => sum + (double.tryParse(item.grandTotal) ?? 0.0));

          return Column(
            children: [
              // Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDateRange(controller),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.startDate != null && controller.endDate != null
                                        ? '${_formatDate(controller.startDate!)} - ${_formatDate(controller.endDate!)}'
                                        : 'Semua Tanggal',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (controller.startDate != null || controller.endDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                            onPressed: () {
                              controller.setDateRange(null, null);
                              _currentPage = 1;
                              controller.fetchInvoicePods(page: 1, context: context);
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Summary preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Invoice: ${listInvoices.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatCurrency(totalNilaiFiltered.toString()),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // List Content
              Expanded(
                child: controller.isLoading && _currentPage == 1
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : controller.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.errorMessage!,
                                    style: const TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _onRefresh,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : listInvoices.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada Invoice ditemukan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _onRefresh,
                                color: Colors.blue,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: listInvoices.length + (controller.isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == listInvoices.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                                      );
                                    }
                                    
                                    final invoice = listInvoices[index];
                                    return _buildInvoiceCard(invoice);
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard(InvoicePodModel invoice) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailPage(invoice: invoice),
            ),
          );
        },
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
                    fontSize: 16,
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
            const Divider(color: Colors.grey, height: 20),
            _buildDetailRow(Icons.person, 'Pelanggan', invoice.namaPelanggan),
            _buildDetailRow(Icons.warehouse, 'Gudang', invoice.namaGudang),
            _buildDetailRow(Icons.receipt_long, 'No. SO', invoice.nomorSo),
            _buildDetailRow(Icons.assignment, 'No. WO', invoice.nomorWo),
            _buildDetailRow(Icons.calendar_today, 'Tgl Cetak', _formatDate(invoice.tanggalCetakInvoice)),
            const Divider(color: Colors.grey, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sisa Bayar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(invoice.sisaBayar),
                      style: TextStyle(color: Colors.orange[400], fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Grand Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(invoice.grandTotal),
                      style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
