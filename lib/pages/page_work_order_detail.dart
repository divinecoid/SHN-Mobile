import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/work_order_detail_controller.dart';
import '../models/work_order_planning_model.dart';
import 'page_work_order_detail_item.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final Map<String, String> workOrder;
  final bool isEditMode;
  final WorkOrderPlanning? workOrderPlanning; // Data asli dari model

  const WorkOrderDetailPage({
    super.key,
    required this.workOrder,
    this.isEditMode = false,
    this.workOrderPlanning,
  });

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  late WorkOrderDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkOrderDetailController();
    
    // Set data asli jika tersedia
    if (widget.workOrderPlanning != null) {
      _controller.setWorkOrderItems(widget.workOrderPlanning!.workOrderPlanningItems);
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                const SizedBox(height: 20),
                
                // Work Order Info Card
                _buildWorkOrderInfoCard(),
                const SizedBox(height: 20),
                
                // Work Order Items List
                _buildWorkOrderItemsList(),
                const SizedBox(height: 20),
                
                // Upload Photo Section
                _buildUploadPhotoSection(),
                const SizedBox(height: 24),
                
                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Consumer<WorkOrderDetailController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Icon(
                controller.getHeaderIcon(widget.isEditMode),
                color: Colors.blue[400],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                controller.getHeaderTitle(widget.isEditMode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkOrderInfoCard() {
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
            _buildInfoRow('No. WO', widget.workOrder['noWO']!),
            const SizedBox(height: 8),
            _buildInfoRow('No. SO', widget.workOrder['noSO']!),
            const SizedBox(height: 8),
            _buildInfoRow('Nama Customer', widget.workOrder['customerName']!),
            const SizedBox(height: 8),
            _buildInfoRow('Gudang', widget.workOrder['warehouse']!),
            const SizedBox(height: 8),
            _buildInfoRow('Status', widget.workOrder['status']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Consumer<WorkOrderDetailController>(
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

  Widget _buildWorkOrderItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Item yang Dikerjakan',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<WorkOrderDetailController>(
          builder: (context, controller, child) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.getWorkOrderItems.length,
              itemBuilder: (context, index) {
                final item = controller.getWorkOrderItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildItemCard(item, index, controller),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index, WorkOrderDetailController controller) {
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
            // Item Header
            Row(
              children: [
                Icon(
                  controller.getItemIcon(item['jenisBarang']),
                  color: Colors.orange[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Item Details Grid
            _buildItemDetailGrid(item, index, controller),
            const SizedBox(height: 16),
            
            // Action Button
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
                  onPressed: () => _showItemDetailDialog(item, index),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit / Detail',
                    style: TextStyle(
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

  Widget _buildItemDetailGrid(Map<String, dynamic> item, int index, WorkOrderDetailController controller) {
    return Column(
      children: [
        // Row 1: Jenis Barang, Bentuk Barang, Grade
        Row(
          children: [
            Expanded(child: _buildDetailItem('Jenis Barang', item['jenisBarang'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Bentuk Barang', item['bentukBarang'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Grade', item['grade'])),
          ],
        ),
        const SizedBox(height: 12),
        

        // Row 2: Panjang, Lebar, Tebal
        Row(
          children: [
            Expanded(child: _buildDetailItem('Panjang (mm)', item['panjang'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Lebar (mm)', item['lebar'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Tebal (mm)', item['tebal'])),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Ukuran, Qty Planning, Qty Actual
        Row(
          children: [
            Expanded(child: _buildDetailItem('Qty Planning', item['qtyPlanning'].toString())),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Qty Actual', item['qtyActual']?.toString() ?? '-')),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Satuan', item['satuan'])),
          ],
        ),
        const SizedBox(height: 12),
        
        // Row 3: Berat Planning, Berat Actual, Luas
        Row(
          children: [
            Expanded(child: _buildDetailItem('Berat Planning (kg)', item['beratPlanning'].toString())),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Berat Actual (kg)', item['beratActual']?.toString() ?? '-')),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Luas', '${controller.formatNumberWithCommas(item['luas'])}${controller.getLuasSuffix(item['jenisBarang'])}')),
          ],
        ),
        const SizedBox(height: 12),
        
        // Row 4: Plat/Shaft Dasar
        Row(
          children: [
            Expanded(child: _buildDetailItem('Catatan', item['catatan'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Plat/Shaft Dasar', '-')),
            
          ],
        ),
        
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }



  Widget _buildUploadPhotoSection() {
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
            Row(
              children: [
                Icon(Icons.photo_camera, color: Colors.green[400], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Upload Bukti Foto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[700]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: _selectPhoto,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap untuk memilih foto',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<WorkOrderDetailController>(
      builder: (context, controller, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveWorkOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
            child: Text(
              controller.getSaveButtonText(widget.isEditMode),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectPhoto() {
    // Implementasi untuk memilih foto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur upload foto akan diimplementasikan'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showItemDetailDialog(Map<String, dynamic> item, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkOrderDetailItemPage(
          item: item,
          itemIndex: index,
          workOrder: widget.workOrder,
        ),
      ),
    );
  }

  void _saveWorkOrder() {
    // Implementasi untuk menyimpan work order
    final controller = Provider.of<WorkOrderDetailController>(context, listen: false);
    final message = controller.getSuccessMessage(widget.workOrder['noWO']!, widget.isEditMode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
  }
}
