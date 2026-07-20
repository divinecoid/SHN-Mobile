import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../controllers/proses_nonpo_controller.dart';
import '../models/penerimaan_barang_model.dart';
import 'input_proses_nonpo_page.dart';

class ProsesNonPoListPage extends StatefulWidget {
  final int initialTabIndex;
  final String? initialSearchQuery;
  final int? initialPenerimaanBarangId;

  const ProsesNonPoListPage({
    super.key, 
    this.initialTabIndex = 0,
    this.initialSearchQuery,
    this.initialPenerimaanBarangId,
  });

  @override
  State<ProsesNonPoListPage> createState() => _ProsesNonPoListPageState();
}

class _ProsesNonPoListPageState extends State<ProsesNonPoListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
      // Need to notify the controller about the search query
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProsesNonPoController>().setSearchQuery(widget.initialSearchQuery!);
      });
    }

    if (widget.initialPenerimaanBarangId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProsesNonPoController>().setPenerimaanBarangId(widget.initialPenerimaanBarangId);
      });
    }
    
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

  Future<Map<String, dynamic>?> _showPrintDialog() async {
    final TextEditingController copiesController = TextEditingController(text: '1');
    String selectedType = 'QR'; // default
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Cetak Label', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Format Cetak:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Radio<String>(
                    value: 'QR',
                    groupValue: selectedType,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text('QR Code', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 24),
                  Radio<String>(
                    value: 'Barcode',
                    groupValue: selectedType,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    activeColor: Colors.blue,
                  ),
                  const Text('Barcode', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Masukkan jumlah copy yang ingin dicetak:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: copiesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Misal: 3',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(copiesController.text);
                if (val != null && val > 0) {
                  Navigator.pop(context, {'copies': val, 'type': selectedType});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan angka yang valid'), backgroundColor: Colors.orange),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Cetak', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaItem,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isPendingPanel) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (detail.itemBarang?.isQrcodePrinted ?? false)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (detail.itemBarang?.isQrcodePrinted ?? false)
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.orange.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (detail.itemBarang?.isQrcodePrinted ?? false)
                                    ? Icons.check_circle_outline
                                    : Icons.print_disabled_outlined,
                                size: 12,
                                color: (detail.itemBarang?.isQrcodePrinted ?? false)
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (detail.itemBarang?.isQrcodePrinted ?? false)
                                    ? 'Printed'
                                    : 'Belum Cetak',
                                style: TextStyle(
                                  color: (detail.itemBarang?.isQrcodePrinted ?? false)
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shelves, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Rak: ${detail.rak?.namaRak ?? '-'}',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      detail.tipeTerima == 'bundle'
                          ? 'Tipe: Bundle${detail.qtyPerIkat != null ? ' (${detail.qtyPerIkat} pcs/ikat)' : ''}'
                          : 'Tipe: ${detail.tipeTerima ?? '-'}',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Info Row 3: Qty & Date
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.numbers, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Text(
                      detail.tipeTerima == 'bundle' && detail.qtyPerIkat != null
                          ? 'Qty: ${detail.qty} Ikat (Total: ${detail.qty * detail.qtyPerIkat!} pcs)'
                          : 'Qty: ${detail.qty} pcs',
                      style: TextStyle(
                        color: Colors.blue[300], 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      isPendingPanel ? 'Masuk: $formattedDate' : 'Diproses: $formattedDate',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
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
                    final printParams = await _showPrintDialog();
                    if (printParams == null) return;
                    final copies = printParams['copies'] as int;
                    final type = printParams['type'] as String;
                    
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mencetak label $type...'), duration: const Duration(seconds: 1)));
                      await controller.printSingleItem(detail, copies, type);
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
                  label: const Text('Print Label'),
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
                final printParams = await _showPrintDialog();
                if (printParams == null) return;
                final copies = printParams['copies'] as int;
                final type = printParams['type'] as String;

                try {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mencetak batch label $type...'), duration: const Duration(seconds: 1)));
                  await controller.printBatchItem(copies, type);
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
              
              // Filter Indicator
              if (controller.penerimaanBarangId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Filtered from notification batch',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          controller.setPenerimaanBarangId(null);
                          controller.refreshAll();
                        },
                        icon: const Icon(Icons.clear, size: 14, color: Colors.blue),
                        label: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
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
