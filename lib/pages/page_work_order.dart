import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/work_order_controller.dart';
import '../models/work_order_planning_model.dart';
import 'page_work_order_detail.dart';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  late WorkOrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkOrderController();
    // Fetch data saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchWorkOrderPlanning(context: context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
