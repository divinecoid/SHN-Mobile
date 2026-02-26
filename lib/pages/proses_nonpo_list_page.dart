import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../controllers/proses_nonpo_controller.dart';
import '../models/penerimaan_barang_model.dart';
import 'input_proses_nonpo_page.dart';

class ProsesNonPoListPage extends StatefulWidget {
  const ProsesNonPoListPage({super.key});

  @override
  State<ProsesNonPoListPage> createState() => _ProsesNonPoListPageState();
}

class _ProsesNonPoListPageState extends State<ProsesNonPoListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initial fetch when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProsesNonPoController>();
      controller.refreshAll();
    });

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildList(
    BuildContext context, 
    ProsesNonPoController controller,
    List<PenerimaanBarangDetail> items, 
    bool isLoading, 
    String? error, 
    bool hasMore, 
    VoidCallback onLoadMore,
    VoidCallback onRefresh,
    bool isPendingPanel
  ) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey[600],
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isPendingPanel ? 'Belum ada data pending' : 'Belum ada data selesai',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            // Reached end, trigger load more if not already loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore();
            });
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final detail = items[index];
          return _buildCard(context, controller, detail, isPendingPanel);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProsesNonPoController controller, PenerimaanBarangDetail detail, bool isPendingPanel) {
    final group = detail.itemBarangGroup;
    final namaItem = group?.namaGroupBarang ?? 'Unknown Item';
    final gudang = detail.penerimaanBarang?.gudang.namaGudang ?? '-';
    // Gunakan tanggal penerimaan header untuk yang pending (karena update_at nya mungkin belum ada yang berarti)
    // Dan update_at dari detail untuk yang selesai.
    final tgl = isPendingPanel 
      ? (detail.penerimaanBarang?.createdAt ?? '') 
      : (detail.itemBarang?.createdAt ?? ''); // item_barang.created_at indicates when it was processed
    final formattedDate = _formatDateTime(tgl);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isPendingPanel)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.selectedProcessedIds.contains(detail.id),
                        onChanged: (bool? val) {
                          controller.toggleSelection(detail.id);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    namaItem,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isPendingPanel)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Info Row 1: Gudang
            Row(
              children: [
                Icon(Icons.warehouse, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Gudang: $gudang',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Info Row 2: Rak & Tipe Terima
            Row(
              children: [
                Icon(Icons.shelves, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Rak: ${detail.rak?.namaRak ?? '-'}',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Tipe: ${detail.tipeTerima ?? '-'}',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Info Row 3: Qty & Date
            Row(
              children: [
                Icon(Icons.numbers, size: 16, color: Colors.blue[400]),
                const SizedBox(width: 8),
                Text(
                  'Qty: ${detail.qty}',
                  style: TextStyle(
                    color: Colors.blue[300], 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  isPendingPanel ? 'Masuk: $formattedDate' : 'Diproses: $formattedDate',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),

            if (isPendingPanel) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                     final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputProsesNonPoPage(detail: detail),
                      ),
                    );

                    // If true is returned, the item was processed successfully, trigger refresh
                    if (result == true && context.mounted) {
                      context.read<ProsesNonPoController>().refreshAll();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Proses Barang'),
                ),
              )
            ],

            if (!isPendingPanel) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak struk QR...'), duration: Duration(seconds: 1)));
                      await controller.printSingleQR(detail);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Print QR'),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Input Harga Non-PO'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      floatingActionButton: Consumer<ProsesNonPoController>(
        builder: (context, controller, child) {
          if (_tabController.index == 1 && controller.selectedProcessedIds.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak batch struk QR...'), duration: Duration(seconds: 1)));
                  await controller.printBatchQR();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.print, color: Colors.white),
              label: Text('Print Batch (${controller.selectedProcessedIds.length})', style: const TextStyle(color: Colors.white)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: Consumer<ProsesNonPoController>(
        builder: (context, controller, child) {
          // Keep search in sync
          if (_searchController.text != controller.searchQuery) {
            _searchController.text = controller.searchQuery;
          }

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[900],
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari nama item/kode...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                              controller.refreshAll();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    controller.setSearchQuery(value);
                    controller.refreshAll();
                  },
                ),
              ),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab Pending
                    _buildList(
                      context,
                      controller,
                      controller.pendingList,
                      controller.isLoadingPending,
                      controller.errorPending,
                      controller.hasMorePending,
                      () => controller.loadPendingList(),
                      () => controller.loadPendingList(refresh: true),
                      true,
                    ),
                    
                    // Tab Selesai
                    _buildList(
                      context,
                      controller,
                      controller.processedList,
                      controller.isLoadingProcessed,
                      controller.errorProcessed,
                      controller.hasMoreProcessed,
                      () => controller.loadProcessedList(),
                      () => controller.loadProcessedList(refresh: true),
                      false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
