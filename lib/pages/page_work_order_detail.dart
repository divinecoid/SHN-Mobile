import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
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

  // Method untuk refresh data saat kembali dari halaman detail item
  Future<void> _refreshData() async {
    if (widget.workOrderId != null) {
      debugPrint('Refreshing data for work order ${widget.workOrderId}');
      await _controller.loadAndUpdateTempData(widget.workOrderId!);
      // Force rebuild dengan setState
      if (mounted) {
        setState(() {});
      }
    }
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
                    const SizedBox(height: 5),
                    
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
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.workOrderId != null 
                  ? controller.getWorkOrderItemsWithTempData(widget.workOrderId!)
                  : Future.value(controller.getWorkOrderItems),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  debugPrint('Displaying ${snapshot.data!.length} items with temp data');
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      debugPrint('Item $index: qtyActual=${item['qtyActual']}, beratActual=${item['beratActual']}');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildItemCard(item, index, controller),
                      );
                    },
                  );
                } else {
                  debugPrint('Using fallback data without temp data');
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
                }
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
            Expanded(child: _buildDetailItemWithHighlight(
              'Qty Actual', 
              item['qtyActual']?.toString() ?? '-',
              item['qtyActual'] != null && item['qtyActual'] != '-'
            )),
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
            Expanded(child: _buildDetailItemWithHighlight(
              'Berat Actual (kg)', 
              item['beratActual']?.toString() ?? '-',
              item['beratActual'] != null && item['beratActual'] != '-'
            )),
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

  // Method untuk menampilkan detail item dengan highlight hijau untuk data yang sudah terset
  Widget _buildDetailItemWithHighlight(String label, String value, bool isHighlighted) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.green[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isHighlighted ? Border.all(color: Colors.green[300]!, width: 1) : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isHighlighted ? Colors.green[800] : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
    return Consumer<WorkOrderDetailController>(
      builder: (context, controller, child) {
        final hasPhoto = controller.fotoBuktiBase64 != null && controller.fotoBuktiBase64!.isNotEmpty;
        Uint8List? photoBytes;
        if (hasPhoto) {
          try {
            final dataUri = controller.fotoBuktiBase64!;
            final base64Part = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
            photoBytes = base64Decode(base64Part);
          } catch (_) {
            photoBytes = null;
          }
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
                    const Spacer(),
                    if (hasPhoto)
                      TextButton(
                        onPressed: () => controller.clearFotoBukti(),
                        child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[700]!,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _selectPhoto,
                    borderRadius: BorderRadius.circular(8),
                    child: hasPhoto && photoBytes != null
                        ? Image.memory(photoBytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk ambil foto',
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
      },
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

  void _selectPhoto() async {
    try {
      await _controller.pickAndSetFotoBukti(ImageSource.camera);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOrderDetailItemPage(
              item: itemDetail ?? item, // Gunakan data dari API jika tersedia, fallback ke data asli
              itemIndex: index,
              workOrder: {
                ...widget.workOrder,
                'id': widget.workOrderId?.toString() ?? '0', // Tambahkan work order ID
              },
              availablePelaksana: controller?.availablePelaksana,
            ),
          ),
        );
        
        // Refresh data setelah kembali dari halaman detail item
        debugPrint('Refreshing data after returning from detail item');
        await _refreshData();
        
        // Tambahkan delay kecil untuk memastikan data sementara sudah tersimpan
        await Future.delayed(const Duration(milliseconds: 500));
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

  // Method untuk menampilkan dialog konfirmasi item yang belum diproses
  Future<void> _showUnprocessedItemsDialog(int unprocessedCount) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Simpan Actual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ada $unprocessedCount item yang belum diproses.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Yakin lanjut simpan actual?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan semua detail item sudah diisi sebelum menyimpan actual.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Lanjutkan dengan proses simpan actual
                _saveWorkOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Lanjutkan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _saveWorkOrder() async {
    try {
      // Validasi wajib foto bukti
      if (_controller.fotoBuktiBase64 == null || _controller.fotoBuktiBase64!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Harap ambil/buat foto bukti terlebih dahulu.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Gunakan controller yang sudah ada di state
      if (widget.workOrderId != null) {
        // Validasi apakah semua item sudah diproses
        final allItemsProcessed = await _controller.validateAllItemsProcessed(widget.workOrderId!);
        
        if (!allItemsProcessed) {
          // Tutup loading dialog
          Navigator.of(context).pop();
          
          // Ada item yang belum diproses, tampilkan dialog konfirmasi
          final unprocessedCount = await _controller.getUnprocessedItemsCount(widget.workOrderId!);
          await _showUnprocessedItemsDialog(unprocessedCount);
          return;
        }
        
        // Ambil semua data sementara
        final allTempData = await _controller.getAllTemporaryWorkOrderData(widget.workOrderId!);
        
        if (allTempData.isNotEmpty) {
          // Kirim data ke API
          final success = await _controller.saveActualWorkOrderData(
            widget.workOrderId!, 
            allTempData, 
            context: context
          );
          
          // Tutup loading dialog
          Navigator.of(context).pop();
          
          if (success) {
            // Hapus data sementara setelah berhasil disimpan
            await _controller.clearAllTemporaryWorkOrderData(widget.workOrderId!);
            
            // Tampilkan pesan sukses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Work Order ${widget.workOrder['noWO']} berhasil disimpan!'),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            
            // Navigate kembali ke halaman work order
            Navigator.of(context).pop();
          } else {
            // Tampilkan pesan error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_controller.errorMessage ?? 'Gagal menyimpan work order. Silakan coba lagi.'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } else {
          // Tutup loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tidak ada data sementara yang ditemukan. Silakan isi detail item terlebih dahulu.'),
              backgroundColor: Colors.orange[600],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        // Tutup loading dialog
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Work Order ID tidak tersedia.'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Tutup loading dialog jika ada error
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
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
