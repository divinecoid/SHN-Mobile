import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/work_order_detail_item_controller.dart';
import '../models/pelaksana_model.dart';

class WorkOrderDetailItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final int itemIndex;
  final Map<String, String> workOrder;
  final List<Pelaksana>? availablePelaksana;

  const WorkOrderDetailItemPage({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.workOrder,
    this.availablePelaksana,
  });

  @override
  State<WorkOrderDetailItemPage> createState() => _WorkOrderDetailItemPageState();
}

class _WorkOrderDetailItemPageState extends State<WorkOrderDetailItemPage> {
  late WorkOrderDetailItemController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = WorkOrderDetailItemController();
      // Gunakan method baru untuk menangani data API response yang sebenarnya
      _controller.initializeWithApiData(widget.item, pelaksanaList: widget.availablePelaksana);
      
      // Load data sementara jika ada
      _loadTemporaryData();
    } catch (e) {
      // Error handling sudah ada di controller
    }
  }

  // Method untuk memuat data sementara
  Future<void> _loadTemporaryData() async {
    try {
      final workOrderId = int.tryParse(widget.workOrder['id'] ?? '0') ?? 0;
      final itemId = widget.item['id'] as int? ?? 0;
      
      if (workOrderId > 0 && itemId > 0) {
        await _controller.loadTemporaryData(workOrderId, itemId);
      }
    } catch (e) {
      debugPrint('Error loading temporary data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
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
                  // Header dengan tombol back
                  _buildHeader(),
                  const SizedBox(height: 20),
                  
                  // Detail Item WO Card
                  _buildDetailItemWOCard(),
                  const SizedBox(height: 20),
                  
                  // Thumbnail dan Input Section
                  _buildThumbnailAndInputSection(),
                  const SizedBox(height: 20),
                  
                  // Assignment Section
                  _buildAssignmentSection(),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error loading detail item',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'Detail Item WO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemWOCard() {
    try {
      return Consumer<WorkOrderDetailItemController>(
        builder: (context, controller, child) {
          try {
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
                          controller.getItemIcon(widget.item['jenisBarang']),
                          color: Colors.orange[400],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Item ${widget.itemIndex + 1}',
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
                    _buildItemDetailGrid(controller),
                  ],
                ),
              ),
            );
          } catch (e) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[600]!),
              ),
              child: Text(
                'Error loading item details: $e',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[600]!),
        ),
        child: Text(
          'Error loading item details: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildItemDetailGrid(WorkOrderDetailItemController controller) {
    try {
      return Column(
        children: [
          // Row 1: Jenis Barang, Bentuk Barang, Grade
          Row(
            children: [
              Expanded(child: _buildDetailItem('Jenis Barang', widget.item['jenisBarang']?.toString() ?? '-')),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailItem('Bentuk Barang', widget.item['bentukBarang']?.toString() ?? '-')),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailItem('Grade', widget.item['grade']?.toString() ?? '-')),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: Ukuran, Qty Planning, Qty Actual
          Row(
            children: [
              Expanded(child: _buildDetailItem('Ukuran (mm)', widget.item['ukuran']?.toString() ?? '-')),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailItem('Qty Planning', widget.item['qtyPlanning']?.toString() ?? '-')),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem('Qty Actual', widget.item['qtyActual']?.toString() ?? '-'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 3: Berat Planning, Berat Actual, Luas
          Row(
            children: [
              Expanded(child: _buildDetailItem('Berat Planning (kg)', widget.item['beratPlanning']?.toString() ?? '-')),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem('Berat Actual (kg)', widget.item['beratActual']?.toString() ?? '-'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem(
                  'Luas',
                  '${widget.item['luas']?.toString() ?? '-'}${controller.getLuasSuffix(widget.item['jenisBarang'])}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 4: Plat/Shaft Dasar
          _buildDetailItem('Plat/Shaft Dasar', widget.item['platShaftDasar']?.toString() ?? '-'),
        ],
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[600]!),
        ),
        child: Text(
          'Error loading item details: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildDetailItem(String label, String value, {String suffix = ''}) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + suffix,
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
    } catch (e) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + suffix,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Error: $e',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }



  Widget _buildThumbnailAndInputSection() {
    try {
      return Consumer<WorkOrderDetailItemController>(
        builder: (context, controller, child) {
          try {
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
                // Thumbnail Section
                Text(
                  'Thumbnail potongan plat, klik to enlarge',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: InkWell(
                    onTap: _enlargeThumbnail,
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Placeholder thumbnail',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Input Fields
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'Actual Qty',
                        controller.qtyActualController,
                        'pcs',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        'Actual Weight',
                        controller.beratActualController,
                        'kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Warning Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[800]!.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[600]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.yellow[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kalau nilainya meleset jauh dari planning, berikan konfirmasi dan notify admin',
                          style: TextStyle(
                            color: Colors.yellow[100],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
          } catch (e) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[600]!),
              ),
              child: Text(
                'Error loading thumbnail section: $e',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[600]!),
        ),
        child: Text(
          'Error loading thumbnail section: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, String suffix) {
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
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentInputField(String label, String value, String suffix, Function(String) onChanged) {
    final controller = TextEditingController(text: value);
    
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
        const SizedBox(height: 8),
        Container(
          height: 45,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixText: suffix,
              suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
              isDense: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentSection() {
    try {
      return Consumer<WorkOrderDetailItemController>(
        builder: (context, controller, child) {
          try {
            return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignment Pelaksana',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[800]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[600]!),
                                ),
                                child: Text(
                                  'Total Qty: ${controller.calculateTotalQty()}',
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[800]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[600]!),
                                ),
                                child: Text(
                                  'Assigned: ${controller.calculateTotalAssigned()}',
                                  style: TextStyle(
                                    color: Colors.green[300],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.addNewAssignment(),
                      icon: Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Assignment List
                ...controller.getAssignments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final assignment = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildAssignmentRow(assignment, index, controller),
                  );
                }).toList(),
              ],
            ),
          ),
        );
          } catch (e) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[600]!),
              ),
              child: Text(
                'Error loading assignment section: $e',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[600]!),
        ),
        child: Text(
          'Error loading assignment section: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildAssignmentRow(Map<String, dynamic> assignment, int index, WorkOrderDetailItemController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.getAssignmentBorderColor(assignment['status']),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Dropdown Pelaksana
          _buildPelaksanaDropdown(assignment, index, controller),
          const SizedBox(height: 20),
          
          // Baris 2: Qty dan Berat
          Row(
            children: [
              Expanded(
                child: _buildAssignmentInputField(
                  'Qty',
                  assignment['qty'].toString(),
                  'pcs',
                  (value) => controller.updateAssignmentQty(index, value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAssignmentInputField(
                  'Berat',
                  assignment['berat'].toString(),
                  'kg',
                  (value) => controller.updateAssignmentBerat(index, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Baris 3: Informasi Jadwal (jika sudah assigned)
          if ((assignment['status'] as String?) == 'assigned' && assignment['tanggal'] != null)
            _buildScheduleInfo(assignment),
          
          const SizedBox(height: 20),
          
          // Baris 4: Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(assignment, index, controller),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeleteButton(index, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPelaksanaDropdown(Map<String, dynamic> assignment, int index, WorkOrderDetailItemController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pelaksana',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: assignment['pelaksana'],
              isExpanded: true,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              hint: Text(
                'Pilih pelaksana',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              items: [
                // Placeholder item
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Pilih pelaksana',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
                // Available pelaksana items
                ...controller.getAvailablePelaksana.map((String pelaksana) {
                  return DropdownMenuItem<String?>(
                    value: pelaksana,
                    child: Text(
                      pelaksana,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                controller.updateAssignmentPelaksana(index, newValue);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleInfo(Map<String, dynamic> assignment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[600]!.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue[300], size: 16),
              const SizedBox(width: 8),
              Text(
                'Jadwal Pengerjaan',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildScheduleDetail('Tanggal', assignment['tanggal']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScheduleDetail('Jam Mulai', assignment['jamMulai']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScheduleDetail('Jam Selesai', assignment['jamSelesai']),
              ),
            ],
          ),
          if (assignment['catatan'] != null && assignment['catatan'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildScheduleDetail('Catatan', assignment['catatan']),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleDetail(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? '-',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }



  Widget _buildActionButton(Map<String, dynamic> assignment, int index, WorkOrderDetailItemController controller) {
    final status = assignment['status'] as String?;
    if (status == 'assigned') {
      return Container(
        height: 45,
        child: ElevatedButton(
          onPressed: () => controller.cancelAssignment(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (status == 'pending') {
      return Container(
        height: 45,
        child: ElevatedButton(
          onPressed: () => controller.assignTask(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Tetapkan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      return Container(
        height: 45,
        child: ElevatedButton(
          onPressed: () => controller.assignTask(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical:12),
          ),
          child: const Text(
            'Tetapkan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  Widget _buildDeleteButton(int index, WorkOrderDetailItemController controller) {
    return Container(
      height: 45,
      child: ElevatedButton(
        onPressed: () => controller.deleteAssignment(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: const Icon(
          Icons.delete,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    try {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _saveItemDetail(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 3,
          ),
          child: const Text(
            'Simpan Sementara',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[600]!),
        ),
        child: Text(
          'Error loading save button: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }



  void _enlargeThumbnail() {
    // Implementasi untuk enlarge thumbnail
  }

  void _deleteAssignment(int index, WorkOrderDetailItemController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Hapus Assignment',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus assignment ini?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteAssignment(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Assignment berhasil dihapus'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }



  void _saveItemDetail() async {
    try {
      // Gunakan controller yang sudah ada di state, bukan Provider.of
      final controller = _controller;
      
      // Validasi input
      if (!controller.validateInput()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.getValidationErrorMessage()),
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

      // Ambil work order ID dari widget.workOrder
      final workOrderId = int.tryParse(widget.workOrder['id'] ?? '0') ?? 0;
      final itemId = widget.item['id'] as int? ?? 0;

      // Simpan data sementara
      await controller.saveTemporaryData(workOrderId, itemId);

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.getSuccessMessage(widget.itemIndex)),
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
          content: Text('Error saving item detail: $e'),
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
