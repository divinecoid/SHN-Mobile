import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/work_order_detail_controller.dart';
import '../models/work_order_planning_model.dart';
import 'page_work_order_detail_item.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final Map<String, String> workOrder;
  final bool isEditMode;
  final WorkOrderPlanning? workOrderPlanning; // Data asli dari model
  final int? workOrderId; // ID work order untuk mengambil data detail

  const WorkOrderDetailPage({
    super.key,
    required this.workOrder,
    this.isEditMode = false,
    this.workOrderPlanning,
    this.workOrderId,
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
    
    // Fetch data detail jika ada workOrderId
    if (widget.workOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.fetchWorkOrderPlanningDetail(widget.workOrderId!, context: context);
      });
    }
    
    // Fetch data pelaksana saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAvailablePelaksana(context: context);
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
          child: Consumer<WorkOrderDetailController>(
            builder: (context, controller, child) {
              // Loading State
              if (controller.isLoading && controller.getWorkOrderItems.isEmpty) {
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
              if (controller.errorMessage != null && controller.getWorkOrderItems.isEmpty) {
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
                            if (widget.workOrderId != null) {
                              controller.fetchWorkOrderPlanningDetail(widget.workOrderId!, context: context);
                            }
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

              return SingleChildScrollView(
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
              );
            },
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
        
        // Row 4: Catatan dan Pelaksana
        Row(
          children: [
            Expanded(child: _buildDetailItem('Catatan', item['catatan'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Pelaksana', _getPelaksanaInfo(item, controller))),
          ],
        ),
        const SizedBox(height: 12),
        
        // Row 5: Info Pelaksana Detail
        if (_hasPelaksanaInfo(item))
          _buildPelaksanaInfoSection(item, controller),
        
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

  // Method untuk mendapatkan informasi pelaksana
  String _getPelaksanaInfo(Map<String, dynamic> item, WorkOrderDetailController controller) {
    final pelaksanaList = item['hasManyPelaksana'] as List<dynamic>?;
    if (pelaksanaList == null || pelaksanaList.isEmpty) {
      return 'Belum ada pelaksana';
    }
    
    final pelaksanaNames = pelaksanaList
        .where((p) => p['pelaksana'] != null)
        .map((p) => p['pelaksana']['nama_pelaksana'] as String)
        .toList();
    
    if (pelaksanaNames.isEmpty) {
      return 'Pelaksana belum ditentukan';
    }
    
    return pelaksanaNames.join(', ');
  }

  // Method untuk mengecek apakah ada informasi pelaksana
  bool _hasPelaksanaInfo(Map<String, dynamic> item) {
    final pelaksanaList = item['hasManyPelaksana'] as List<dynamic>?;
    return pelaksanaList != null && pelaksanaList.isNotEmpty;
  }

  // Widget untuk menampilkan informasi detail pelaksana
  Widget _buildPelaksanaInfoSection(Map<String, dynamic> item, WorkOrderDetailController controller) {
    final pelaksanaList = item['hasManyPelaksana'] as List<dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.blue[400], size: 16),
              const SizedBox(width: 8),
              Text(
                'Detail Pelaksana (${pelaksanaList.length} orang)',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pelaksanaList.map((pelaksana) => _buildPelaksanaItem(pelaksana)).toList(),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item pelaksana individual
  Widget _buildPelaksanaItem(Map<String, dynamic> pelaksana) {
    final pelaksanaData = pelaksana['pelaksana'] as Map<String, dynamic>?;
    if (pelaksanaData == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pelaksanaData['nama_pelaksana']} (${pelaksanaData['kode']})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Qty: ${pelaksana['qty']} | ${pelaksana['jam_mulai']} - ${pelaksana['jam_selesai']}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
                if (pelaksana['catatan'] != null && pelaksana['catatan'].toString().isNotEmpty)
                  Text(
                    'Catatan: ${pelaksana['catatan']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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

  void _showItemDetailDialog(Map<String, dynamic> item, int index) async {
    try {
      // Cek apakah controller tersedia di context
      WorkOrderDetailController? controller;
      try {
        controller = Provider.of<WorkOrderDetailController>(context, listen: false);
      } catch (e) {
        // Lanjutkan tanpa controller, akan fetch pelaksana di halaman detail
      }

      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Ambil ID work order planning item dari data item
        final itemId = item['id'] as int?;
        if (itemId == null) {
          throw Exception('ID item tidak ditemukan');
        }

        // Panggil API showItem untuk mendapatkan data detail item
        Map<String, dynamic>? itemDetail;
        if (controller != null) {
          itemDetail = await controller.fetchWorkOrderItemDetail(itemId);
        }

        // Tutup loading dialog
        Navigator.of(context).pop();

        // Navigate ke halaman detail item dengan data yang sudah di-fetch
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOrderDetailItemPage(
              item: itemDetail ?? item, // Gunakan data dari API jika tersedia, fallback ke data asli
              itemIndex: index,
              workOrder: widget.workOrder,
              availablePelaksana: controller?.availablePelaksana,
            ),
          ),
        );
      } catch (e) {
        // Tutup loading dialog jika ada error
        Navigator.of(context).pop();
        
        // Tampilkan error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil data item: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error membuka detail item: $e'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _saveWorkOrder() {
    try {
      // Implementasi untuk menyimpan work order
      WorkOrderDetailController? controller;
      try {
        controller = Provider.of<WorkOrderDetailController>(context, listen: false);
      } catch (e) {
        // Controller tidak ditemukan, gunakan fallback message
      }
      
      final message = controller?.getSuccessMessage(widget.workOrder['noWO']!, widget.isEditMode) ?? 
                     'Work Order ${widget.workOrder['noWO']} berhasil ${widget.isEditMode ? 'diupdate' : 'disimpan'}!';
      
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving work order: $e'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
