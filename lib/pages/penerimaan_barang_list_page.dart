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

class _PenerimaanBarangListPageState extends State<PenerimaanBarangListPage> 
    with SingleTickerProviderStateMixin {
  late PenerimaanBarangListController _controller;
  bool _isFilterExpanded = false;
  final TextEditingController _nomorPoController = TextEditingController();
  final TextEditingController _nomorMutasiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final FocusNode _nomorPoFocusNode = FocusNode();
  final FocusNode _nomorMutasiFocusNode = FocusNode();
  final FocusNode _catatanFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = PenerimaanBarangListController();
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
    _nomorPoController.dispose();
    _nomorMutasiController.dispose();
    _catatanController.dispose();
    _nomorPoFocusNode.dispose();
    _nomorMutasiFocusNode.dispose();
    _catatanFocusNode.dispose();
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.loadGudangList();
      await _controller.loadPenerimaanBarangList(refresh: true);
      // Sync text controllers with filter values
      _syncTextControllers();
    } catch (e) {
      _showSnackBar('Gagal memuat data: $e');
    }
  }

  void _syncTextControllers() {
    _nomorPoController.text = _controller.nomorPo;
    _nomorMutasiController.text = _controller.nomorMutasi;
    _catatanController.text = _controller.catatan;
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
            // Nomor PO Filter
            _buildTextInputFilter(
              label: 'Nomor PO',
              controller: _nomorPoController,
              value: _controller.nomorPo,
              focusNode: _nomorPoFocusNode,
              onChanged: (value) => _controller.setNomorPo(value),
            ),
            const SizedBox(height: 12),
            // Nomor Mutasi Filter
            _buildTextInputFilter(
              label: 'Nomor Mutasi',
              controller: _nomorMutasiController,
              value: _controller.nomorMutasi,
              focusNode: _nomorMutasiFocusNode,
              onChanged: (value) => _controller.setNomorMutasi(value),
            ),
            const SizedBox(height: 12),
            // Catatan Filter
            _buildTextInputFilter(
              label: 'Catatan',
              controller: _catatanController,
              value: _controller.catatan,
              focusNode: _catatanFocusNode,
              onChanged: (value) => _controller.setCatatan(value),
            ),
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
                        : '$label',
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

  Widget _buildTextInputFilter({
    required String label,
    required TextEditingController controller,
    required String value,
    required FocusNode focusNode,
    required Function(String) onChanged,
  }) {
    // Sync controller text with value if different (only when not focused)
    if (controller.text != value && !focusNode.hasFocus) {
      controller.text = value;
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
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set context for session handling
    _controller.setContext(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
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
                                  // Sync text controllers when controller notifies (only if not focused)
                                  if (!_nomorPoFocusNode.hasFocus && 
                                      !_nomorMutasiFocusNode.hasFocus && 
                                      !_catatanFocusNode.hasFocus) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (!_nomorPoFocusNode.hasFocus && 
                                          !_nomorMutasiFocusNode.hasFocus && 
                                          !_catatanFocusNode.hasFocus) {
                                        _syncTextControllers();
                                      }
                                    });
                                  }
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
                                                  : () => _controller.loadPenerimaanBarangList(refresh: true),
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
                                              _nomorPoController.clear();
                                              _nomorMutasiController.clear();
                                              _catatanController.clear();
                                              _controller.loadPenerimaanBarangList(refresh: true);
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
