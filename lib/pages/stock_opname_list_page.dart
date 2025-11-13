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

class _StockOpnameListPageState extends State<StockOpnameListPage> 
    with SingleTickerProviderStateMixin {
  late StockOpnameListController _controller;
  bool _isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = StockOpnameListController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.loadGudangList();
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey[600]!;
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
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Widget _buildFilterSection() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // Date Range Filter
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Dari Tanggal',
                    value: _controller.dateFrom,
                    onDateSelected: (date) {
                      if (date != null) {
                        _controller.setDateFrom(DateFormat('yyyy-MM-dd').format(date));
                      } else {
                        _controller.setDateFrom(null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    label: 'Sampai Tanggal',
                    value: _controller.dateTo,
                    onDateSelected: (date) {
                      if (date != null) {
                        _controller.setDateTo(DateFormat('yyyy-MM-dd').format(date));
                      } else {
                        _controller.setDateTo(null);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Gudang Filter
            _buildDropdownFilter(
              label: 'Gudang',
              value: _controller.selectedGudangId,
              items: _controller.gudangList,
              onChanged: (value) => _controller.setSelectedGudangId(value),
              itemBuilder: (item) => '${item.kode} - ${item.namaGudang}',
            ),
            const SizedBox(height: 12),
            // Status Filter
            _buildStatusDropdownFilter(),
          ],
        );
      },
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String? value,
    required Function(DateTime?) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value != null ? DateTime.parse(value) : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
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
            onDateSelected(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('dd MMM yyyy').format(DateTime.parse(value))
                        : label,
                    style: TextStyle(
                      color: value != null ? Colors.white : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required dynamic value,
    required List<T> items,
    required Function(dynamic) onChanged,
    required String Function(T) itemBuilder,
  }) {
    // Find selected item
    T? selectedItem;
    if (value != null && items.isNotEmpty) {
      try {
        selectedItem = items.firstWhere(
          (item) => (item as dynamic).id == value,
          orElse: () => items.first,
        );
        // Verify the found item actually matches
        if ((selectedItem as dynamic).id != value) {
          selectedItem = null;
        }
      } catch (e) {
        selectedItem = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedItem,
              isExpanded: true,
              hint: Text(
                'Pilih $label',
                style: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey[800],
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text(
                    'Semua $label',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
              ],
              onChanged: (T? newValue) {
                onChanged(newValue != null ? (newValue as dynamic).id : null);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdownFilter() {
    const List<String> statusList = ['draft', 'active', 'completed', 'cancelled', 'reconciled'];
    
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _controller.selectedStatus,
                  isExpanded: true,
                  hint: const Text(
                    'Pilih Status',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[800],
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Semua Status',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...statusList.map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        _getStatusLabel(status),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
                  ],
                  onChanged: (String? newValue) {
                    _controller.setSelectedStatus(newValue);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
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
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStockOpnameForm(),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Buat Stock Opname Baru',
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Filter Section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan toggle button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isFilterExpanded = !_isFilterExpanded;
                        if (_isFilterExpanded) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Filter Pencarian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isFilterExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Collapsible content dengan animasi expand/collapse (atas ke bawah)
                  SizeTransition(
                    sizeFactor: _sizeAnimation,
                    axis: Axis.vertical,
                    axisAlignment: -1.0,
                    child: _isFilterExpanded
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: ListenableBuilder(
                                listenable: _controller,
                                builder: (context, child) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFilterSection(),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _controller.isLoading
                                                  ? null
                                                  : () => _controller.loadStockOpnameList(refresh: true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                              child: _controller.isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text('Cari'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              _controller.clearFilters();
                                              _controller.loadStockOpnameList(refresh: true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[700],
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Reset'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
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
                      _formatDateTimeHeader(stockOpname.createdAt),
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

