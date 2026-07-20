import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/sales_order_controller.dart';
import '../models/work_order_planning_model.dart';
import 'sales_order_detail_page.dart';

class SalesOrderListPage extends StatefulWidget {
  const SalesOrderListPage({super.key});

  @override
  State<SalesOrderListPage> createState() => _SalesOrderListPageState();
}

class _SalesOrderListPageState extends State<SalesOrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<SalesOrderController>();
      controller.clearFilters();
      controller.fetchSalesOrders(page: 1, context: context);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final controller = context.read<SalesOrderController>();
      if (!controller.isLoading && controller.pagination != null && _currentPage < controller.pagination!.lastPage) {
        _currentPage++;
        controller.fetchSalesOrders(page: _currentPage, context: context);
      }
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    await context.read<SalesOrderController>().fetchSalesOrders(page: 1, context: context);
  }

  String _formatDate(DateTime dateTime) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<SalesOrderController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // Search & Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Cari No. SO...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        controller.setSearchQuery('');
                                        _currentPage = 1;
                                        controller.fetchSalesOrders(page: 1, context: context);
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {}); // To trigger clear button visibility
                            },
                            onSubmitted: (value) {
                              controller.setSearchQuery(value);
                              _currentPage = 1;
                              controller.fetchSalesOrders(page: 1, context: context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', 'all', controller),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pending', 'pending', controller),
                          const SizedBox(width: 8),
                          _buildFilterChip('Partial WO', 'partial_wo', controller),
                          const SizedBox(width: 8),
                          _buildFilterChip('Selesai', 'full_wo', controller),
                        ],
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
                        : controller.salesOrders.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada Sales Order ditemukan',
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
                                  itemCount: controller.salesOrders.length + (controller.isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == controller.salesOrders.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                                      );
                                    }
                                    
                                    final so = controller.salesOrders[index];
                                    return _buildSoCard(so);
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

  Widget _buildFilterChip(String label, String value, SalesOrderController controller) {
    final isSelected = (controller.selectedStatus ?? 'all') == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue[800],
      disabledColor: Colors.transparent,
      backgroundColor: Colors.grey[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[300],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          controller.setSelectedStatus(value == 'all' ? null : value);
          _currentPage = 1;
          controller.fetchSalesOrders(page: 1, context: context);
        }
      },
    );
  }

  Widget _buildSoCard(SalesOrder so) {
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
              builder: (context) => SalesOrderDetailPage(salesOrderId: so.id),
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
                  so.nomorSo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    so.pelanggan?.namaPelanggan ?? 'Pelanggan ID: ${so.pelangganId}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.warehouse, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    so.gudang?.namaGudang ?? 'Gudang ID: ${so.gudangId}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tgl SO',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(so.tanggalSo),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Harga SO',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(so.totalHargaSo),
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
}
