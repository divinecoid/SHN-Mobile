import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = PenerimaanBarangListController();
    _initializeController();
  }

  @override
  void dispose() {
    _controller.dispose();
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


  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTimeHeader(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final dayNames = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayName = dayNames[date.weekday];
      final formattedDate = DateFormat('dd MMM yyyy HH:mm').format(date);
      return '$dayName, $formattedDate';
    } catch (e) {
      return dateString;
    }
  }

  String _getNomorReference(PenerimaanBarang penerimaanBarang) {
    if (penerimaanBarang.origin.toLowerCase() == 'purchaseorder' && 
        penerimaanBarang.purchaseOrder != null) {
      return penerimaanBarang.purchaseOrder!.nomorPo;
    } else if (penerimaanBarang.origin.toLowerCase() == 'stockmutation' && 
               penerimaanBarang.stockMutation != null) {
      return penerimaanBarang.stockMutation!.nomorMutasi;
    }
    return '-';
  }

  String _getReferenceLabel(PenerimaanBarang penerimaanBarang) {
    if (penerimaanBarang.origin.toLowerCase() == 'purchaseorder') {
      return 'Nomor PO';
    } else if (penerimaanBarang.origin.toLowerCase() == 'stockmutation') {
      return 'Nomor Mutasi';
    }
    return 'Nomor Referensi';
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
                      _formatDateTimeHeader(penerimaanBarang.createdAt),
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
              // Tanggal Terima
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tanggal Terima: ${_formatDate(penerimaanBarang.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Gudang
              Row(
                children: [
                  Icon(
                    Icons.warehouse,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Gudang: ${penerimaanBarang.gudang.namaGudang}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Nomor PO/Mutasi
              Row(
                children: [
                  Icon(
                    Icons.receipt,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getReferenceLabel(penerimaanBarang)}: ${_getNomorReference(penerimaanBarang)}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Catatan
              if (penerimaanBarang.catatan.isNotEmpty) ...[
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
              ],
              // Footer info
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
