import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/penerimaan_barang_list_controller.dart';
import '../models/penerimaan_barang_model.dart';
import 'input_penerimaan_barang_page.dart';
import 'penerimaan_barang_detail_page.dart';

class PenerimaanBarangListPage extends StatefulWidget {
  const PenerimaanBarangListPage({super.key});

  @override
  State<PenerimaanBarangListPage> createState() => _PenerimaanBarangListPageState();
}

class _PenerimaanBarangListPageState extends State<PenerimaanBarangListPage> {
  late PenerimaanBarangListController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PenerimaanBarangListController();
    _initializeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.loadPenerimaanBarangList(refresh: true);
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

  void _navigateToInputPenerimaanBarang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InputPenerimaanBarangPage(),
      ),
    ).then((_) {
      // Refresh list when returning from input page
      _controller.refresh();
    });
  }

  void _navigateToDetail(PenerimaanBarang penerimaanBarang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PenerimaanBarangDetailPage(
          penerimaanBarang: penerimaanBarang,
        ),
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    _controller.search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    // Set context for session handling
    _controller.setContext(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refresh,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  if (_controller.isLoading && _controller.penerimaanBarangList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_controller.error != null && _controller.penerimaanBarangList.isEmpty) {
                    return _buildErrorWidget();
                  }

                  if (_controller.penerimaanBarangList.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return _buildListWidget();
                },
              ),
            ),
          ),
        ],
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
                'Mulai dengan menambahkan penerimaan barang baru',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _navigateToInputPenerimaanBarang,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Penerimaan Barang'),
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
      itemCount: _controller.penerimaanBarangList.length + 
                 (_controller.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _controller.penerimaanBarangList.length) {
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

        final penerimaanBarang = _controller.penerimaanBarangList[index];
        return _buildListItem(penerimaanBarang);
      },
    );
  }

  Widget _buildListItem(PenerimaanBarang penerimaanBarang) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(penerimaanBarang),
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
                      'ID: ${penerimaanBarang.id}',
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
              const SizedBox(height: 8),
              Text(
                penerimaanBarang.gudang.nama,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                penerimaanBarang.catatan,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${penerimaanBarang.penerimaanBarangDetails.length} item',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (penerimaanBarang.urlFoto != null)
                    Icon(
                      Icons.photo,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
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
