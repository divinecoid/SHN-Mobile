import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/work_order_controller.dart';
import '../models/work_order_planning_model.dart';
import '../models/gudang_model.dart' as gudang_model;
import 'page_work_order_detail.dart';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> 
    with SingleTickerProviderStateMixin {
  late WorkOrderController _controller;
  bool _isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  final TextEditingController _nomorWoController = TextEditingController();
  final TextEditingController _nomorSoController = TextEditingController();
  final TextEditingController _namaCustomerController = TextEditingController();
  final TextEditingController _jumlahItemController = TextEditingController();
  final TextEditingController _jumlahItemMinController = TextEditingController();
  final TextEditingController _jumlahItemMaxController = TextEditingController();
  final FocusNode _nomorWoFocusNode = FocusNode();
  final FocusNode _nomorSoFocusNode = FocusNode();
  final FocusNode _namaCustomerFocusNode = FocusNode();
  final FocusNode _jumlahItemFocusNode = FocusNode();
  final FocusNode _jumlahItemMinFocusNode = FocusNode();
  final FocusNode _jumlahItemMaxFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = WorkOrderController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Fetch data saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadGudangList();
      _controller.fetchWorkOrderPlanning(context: context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomorWoController.dispose();
    _nomorSoController.dispose();
    _namaCustomerController.dispose();
    _jumlahItemController.dispose();
    _jumlahItemMinController.dispose();
    _jumlahItemMaxController.dispose();
    _nomorWoFocusNode.dispose();
    _nomorSoFocusNode.dispose();
    _namaCustomerFocusNode.dispose();
    _jumlahItemFocusNode.dispose();
    _jumlahItemMinFocusNode.dispose();
    _jumlahItemMaxFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Consumer<WorkOrderController>(
                                  builder: (context, controller, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildFilterSection(controller),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: controller.isLoading
                                                    ? null
                                                    : () => controller.fetchWorkOrderPlanning(context: context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                child: controller.isLoading
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
                                                controller.clearFilters();
                                                _nomorWoController.clear();
                                                _nomorSoController.clear();
                                                _namaCustomerController.clear();
                                                _jumlahItemController.clear();
                                                _jumlahItemMinController.clear();
                                                _jumlahItemMaxController.clear();
                                                controller.fetchWorkOrderPlanning(context: context);
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
              // Work Order List with RefreshIndicator
              Expanded(
                child: _buildWorkOrderContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildWorkOrderContent() {
    return Consumer<WorkOrderController>(
      builder: (context, controller, child) {
        // Loading State
        if (controller.isLoading && controller.workOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data work order...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Error State
        if (controller.errorMessage != null && controller.workOrders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.clearError();
                      controller.fetchWorkOrderPlanning(context: context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty State
        if (controller.workOrders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Work Order',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada work order yang tersedia.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.refreshData(context: context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        // Data List with Pull to Refresh
        return RefreshIndicator(
          onRefresh: () => controller.refreshData(context: context),
          color: Colors.blue,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.workOrders.length,
            itemBuilder: (context, index) {
              final workOrder = controller.workOrders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildWorkOrderCardFromModel(workOrder, controller),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkOrderList() {
    return Consumer<WorkOrderController>(
      builder: (context, controller, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.getWorkOrders.length,
          itemBuilder: (context, index) {
            final workOrder = controller.getWorkOrders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildWorkOrderCard(workOrder, controller),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkOrderCardFromModel(WorkOrderPlanning workOrder, WorkOrderController controller) {
    // Helper function untuk mendapatkan nama customer
    String getCustomerName() {
      // Prioritas: gunakan namaPelanggan dari response langsung, fallback ke relasi pelanggan
      return workOrder.namaPelanggan ?? workOrder.pelanggan?.namaPelanggan ?? 'N/A';
    }

    // Helper function untuk mendapatkan info gudang
    String getWarehouseInfo() {
      // Prioritas: gunakan namaGudang dari response langsung, fallback ke relasi gudang
      return workOrder.namaGudang ?? workOrder.gudang?.namaGudang ?? 'N/A';
    }

    // Helper function untuk mendapatkan nomor SO
    String getSalesOrderNumber() {
      // Prioritas: gunakan nomorSo dari response langsung, fallback ke relasi salesOrder
      return workOrder.nomorSo ?? workOrder.salesOrder?.nomorSo ?? 'N/A';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Wo Unique Id
            _buildInfoRow('WO Unique Id', workOrder.woUniqueId),
            const SizedBox(height: 8),
            
            // No. WO
            _buildInfoRow('No. WO', workOrder.nomorWo),
            const SizedBox(height: 8),
            
            // No. SO
            _buildInfoRow('No. SO', getSalesOrderNumber()),
            const SizedBox(height: 8),
            
            // Nama Customer
            _buildInfoRow('Nama Customer', getCustomerName()),
            const SizedBox(height: 8),
            
            // Gudang
            _buildInfoRow('Gudang', getWarehouseInfo()),
            const SizedBox(height: 8),
            
            // Status
            _buildInfoRow('Status', workOrder.status),
            const SizedBox(height: 8),
            
            // Prioritas
            _buildInfoRow('Prioritas', workOrder.prioritas),
            const SizedBox(height: 8),
            
            // Tanggal WO
            _buildInfoRow('Tanggal WO', '${_formatDate(workOrder.tanggalWo)} ${workOrder.tanggalWo.hour.toString().padLeft(2, '0')}:${workOrder.tanggalWo.minute.toString().padLeft(2, '0')}:${workOrder.tanggalWo.second.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            
            // Jumlah Item
            _buildInfoRow('Jumlah Item', '${workOrder.count} item'),
            const SizedBox(height: 20),
            
            // Tombol Aksi
            Center(
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: TextButton(
                  onPressed: () {
                    _handleButtonActionFromModel(workOrder, controller);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    controller.getButtonText(workOrder.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOrderCard(Map<String, String> workOrder, WorkOrderController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No. WO
            _buildInfoRow('No. WO', workOrder['noWO']!),
            const SizedBox(height: 8),
            
            // No. SO
            _buildInfoRow('No. SO', workOrder['noSO']!),
            const SizedBox(height: 8),
            
            // Nama Customer
            _buildInfoRow('Nama Customer', workOrder['customerName']!),
            const SizedBox(height: 8),
            
            // Gudang
            _buildInfoRow('Gudang', workOrder['warehouse']!),
            const SizedBox(height: 8),
            
            // Status
            _buildInfoRow('Status', workOrder['status']!),
            const SizedBox(height: 20),
            
            // Tombol Aksi
            Center(
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: TextButton(
                  onPressed: () {
                    _handleButtonAction(workOrder, controller);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    controller.getButtonText(workOrder['status']!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Consumer<WorkOrderController>(
      builder: (context, controller, child) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  color: controller.getStatusColor(value),
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method untuk format tanggal
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildFilterSection(WorkOrderController controller) {
    // Sync text controllers when controller notifies (only if not focused)
    if (!_nomorWoFocusNode.hasFocus && 
        !_nomorSoFocusNode.hasFocus && 
        !_namaCustomerFocusNode.hasFocus &&
        !_jumlahItemFocusNode.hasFocus &&
        !_jumlahItemMinFocusNode.hasFocus &&
        !_jumlahItemMaxFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_nomorWoFocusNode.hasFocus && 
            !_nomorSoFocusNode.hasFocus && 
            !_namaCustomerFocusNode.hasFocus &&
            !_jumlahItemFocusNode.hasFocus &&
            !_jumlahItemMinFocusNode.hasFocus &&
            !_jumlahItemMaxFocusNode.hasFocus) {
          _nomorWoController.text = controller.nomorWo;
          _nomorSoController.text = controller.nomorSo;
          _namaCustomerController.text = controller.namaCustomer;
          _jumlahItemController.text = controller.jumlahItem?.toString() ?? '';
          _jumlahItemMinController.text = controller.jumlahItemMin?.toString() ?? '';
          _jumlahItemMaxController.text = controller.jumlahItemMax?.toString() ?? '';
        }
      });
    }
    
    return Column(
      children: [
        // Date Range Filter
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                label: 'Tanggal WO Dari',
                value: controller.tanggalWoFrom,
                onDateSelected: (date) {
                  if (date != null) {
                    controller.setTanggalWoFrom(DateFormat('yyyy-MM-dd').format(date));
                  } else {
                    controller.setTanggalWoFrom(null);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                label: 'Tanggal WO Sampai',
                value: controller.tanggalWoTo,
                onDateSelected: (date) {
                  if (date != null) {
                    controller.setTanggalWoTo(DateFormat('yyyy-MM-dd').format(date));
                  } else {
                    controller.setTanggalWoTo(null);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Nomor WO Filter
        _buildTextInputFilter(
          label: 'Nomor WO',
          controller: _nomorWoController,
          value: controller.nomorWo,
          focusNode: _nomorWoFocusNode,
          onChanged: (value) => controller.setNomorWo(value),
        ),
        const SizedBox(height: 12),
        // Nomor SO Filter
        _buildTextInputFilter(
          label: 'Nomor SO',
          controller: _nomorSoController,
          value: controller.nomorSo,
          focusNode: _nomorSoFocusNode,
          onChanged: (value) => controller.setNomorSo(value),
        ),
        const SizedBox(height: 12),
        // Nama Customer Filter
        _buildTextInputFilter(
          label: 'Nama Customer',
          controller: _namaCustomerController,
          value: controller.namaCustomer,
          focusNode: _namaCustomerFocusNode,
          onChanged: (value) => controller.setNamaCustomer(value),
        ),
        const SizedBox(height: 12),
        // Gudang Filter
        _buildDropdownFilter<gudang_model.Gudang>(
          label: 'Gudang',
          value: controller.selectedGudangId,
          items: controller.gudangList,
          onChanged: (value) => controller.setSelectedGudangId(value),
          itemBuilder: (item) => '${item.kode} - ${item.namaGudang}',
        ),
        const SizedBox(height: 12),
        // Status Filter
        _buildStatusDropdownFilter(controller),
        const SizedBox(height: 12),
        // Jumlah Item Filter
        Row(
          children: [
            Expanded(
              child: _buildTextInputFilter(
                label: 'Jumlah Item',
                controller: _jumlahItemController,
                value: controller.jumlahItem?.toString() ?? '',
                focusNode: _jumlahItemFocusNode,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.setJumlahItem(null);
                  } else {
                    final intValue = int.tryParse(value);
                    controller.setJumlahItem(intValue);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextInputFilter(
                label: 'Jumlah Item Min',
                controller: _jumlahItemMinController,
                value: controller.jumlahItemMin?.toString() ?? '',
                focusNode: _jumlahItemMinFocusNode,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.setJumlahItemMin(null);
                  } else {
                    final intValue = int.tryParse(value);
                    controller.setJumlahItemMin(intValue);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextInputFilter(
                label: 'Jumlah Item Max',
                controller: _jumlahItemMaxController,
                value: controller.jumlahItemMax?.toString() ?? '',
                focusNode: _jumlahItemMaxFocusNode,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.setJumlahItemMax(null);
                  } else {
                    final intValue = int.tryParse(value);
                    controller.setJumlahItemMax(intValue);
                  }
                },
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildStatusDropdownFilter(WorkOrderController controller) {
    const List<String> statusList = ['draft', 'On Progress', 'completed', 'cancelled'];
    
    return Consumer<WorkOrderController>(
      builder: (context, ctrl, child) {
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
                  value: ctrl.selectedStatus,
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
                        status,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
                  ],
                  onChanged: (String? newValue) {
                    ctrl.setSelectedStatus(newValue);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextInputFilter({
    required String label,
    required TextEditingController controller,
    required String value,
    required FocusNode focusNode,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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

  void _handleButtonActionFromModel(WorkOrderPlanning workOrder, WorkOrderController controller) {
    final isEditMode = controller.getEditMode(workOrder.status);
    
    // Konversi ke format lama untuk kompatibilitas dengan detail page
    final workOrderMap = {
      'noWO': workOrder.nomorWo,
      'noSO': workOrder.nomorSo ?? workOrder.salesOrder?.nomorSo ?? 'N/A',
      'customerName': workOrder.namaPelanggan ?? workOrder.pelanggan?.namaPelanggan ?? 'N/A',
      'warehouse': workOrder.namaGudang ?? workOrder.gudang?.namaGudang ?? 'N/A',
      'status': workOrder.status,
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkOrderDetailPage(
          workOrder: workOrderMap,
          isEditMode: isEditMode,
          workOrderPlanning: workOrder, // Kirim data asli
          workOrderId: workOrder.id, // Kirim ID untuk fetch data detail
        ),
      ),
    );
  }

  void _handleButtonAction(Map<String, String> workOrder, WorkOrderController controller) {
    final isEditMode = controller.getEditMode(workOrder['status']!);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkOrderDetailPage(
          workOrder: workOrder,
          isEditMode: isEditMode,
        ),
      ),
    );
  }
}
