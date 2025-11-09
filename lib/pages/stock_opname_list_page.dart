import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/stock_opname_list_controller.dart';
import '../models/stock_opname_model.dart';
import 'page_stock_opname.dart';

class StockOpnameListPage extends StatefulWidget {
  const StockOpnameListPage({super.key});

  @override
  State<StockOpnameListPage> createState() => _StockOpnameListPageState();
}

class _StockOpnameListPageState extends State<StockOpnameListPage> {
  late StockOpnameListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StockOpnameListController();
    _initializeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.loadStockOpnameList(refresh: true);
    } catch (e) {
      _showSnackBar('Gagal memuat data: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToStockOpnameForm({int? stockOpnameId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockOpnamePage(stockOpnameId: stockOpnameId),
      ),
    ).then((_) {
      // Refresh list when returning from form page
      _controller.refresh();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.yellow;
      case 'reconciled':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'reconciled':
        return 'Reconciled';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set context for session handling
    _controller.setContext(context);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Navigate to dashboard/home instead of closing app
        // Pop all routes until we reach the root (DashboardPage or HomePage)
        Navigator.of(context).popUntil((route) {
          // Stop when we reach a route that is the root or contains DashboardPage/HomePage
          // Since StockOpnameListPage is used inside DashboardPage/HomePage via bottom nav,
          // we need to pop until we can't pop anymore, which will bring us back to the parent
          return route.isFirst;
        });
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStockOpnameForm(),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Buat Stock Opname Baru',
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refresh,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  if (_controller.isLoading && _controller.stockOpnameList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_controller.error != null && _controller.stockOpnameList.isEmpty) {
                    return _buildErrorWidget();
                  }

                  if (_controller.stockOpnameList.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return _buildListWidget();
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _controller.error ?? 'Unknown error',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey[400],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Data',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai dengan membuat stock opname baru',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _navigateToStockOpnameForm(),
                icon: const Icon(Icons.add),
                label: const Text('Buat Stock Opname Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.stockOpnameList.length + 
                 (_controller.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _controller.stockOpnameList.length) {
          // Load more indicator
          if (_controller.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        final stockOpname = _controller.stockOpnameList[index];
        return _buildListItem(stockOpname);
      },
    );
  }

  Widget _buildListItem(StockOpname stockOpname) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToStockOpnameForm(stockOpnameId: stockOpname.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(stockOpname.createdAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(stockOpname.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(stockOpname.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (stockOpname.gudang != null) ...[
                Row(
                  children: [
                    Icon(Icons.warehouse, color: Colors.orange[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stockOpname.gudang!.namaGudang,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (stockOpname.picUser != null) ...[
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stockOpname.picUser!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (stockOpname.catatan != null && stockOpname.catatan!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stockOpname.catatan!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(stockOpname.createdAt),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
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

