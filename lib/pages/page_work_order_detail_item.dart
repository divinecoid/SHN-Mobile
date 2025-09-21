import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/work_order_detail_item_controller.dart';

class WorkOrderDetailItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final int itemIndex;
  final Map<String, String> workOrder;

  const WorkOrderDetailItemPage({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.workOrder,
  });

  @override
  State<WorkOrderDetailItemPage> createState() => _WorkOrderDetailItemPageState();
}

class _WorkOrderDetailItemPageState extends State<WorkOrderDetailItemPage> {
  late WorkOrderDetailItemController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkOrderDetailItemController();
    _controller.initializeWithItem(widget.item);
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
    return Consumer<WorkOrderDetailItemController>(
      builder: (context, controller, child) {
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
      },
    );
  }

  Widget _buildItemDetailGrid(WorkOrderDetailItemController controller) {
    return Column(
      children: [
        // Row 1: Jenis Barang, Bentuk Barang, Grade
        Row(
          children: [
            Expanded(child: _buildDetailItem('Jenis Barang', widget.item['jenisBarang'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Bentuk Barang', widget.item['bentukBarang'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Grade', widget.item['grade'])),
          ],
        ),
        const SizedBox(height: 12),
        
        // Row 2: Ukuran, Qty Planning, Qty Actual
        Row(
          children: [
            Expanded(child: _buildDetailItem('Ukuran (mm)', widget.item['ukuran'])),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem('Qty Planning', widget.item['qtyPlanning'].toString())),
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
            Expanded(child: _buildDetailItem('Berat Planning (kg)', widget.item['beratPlanning'].toString())),
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
        _buildDetailItem('Plat/Shaft Dasar', widget.item['platShaftDasar']),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {String suffix = ''}) {
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
  }



  Widget _buildThumbnailAndInputSection() {
    return Consumer<WorkOrderDetailItemController>(
      builder: (context, controller, child) {
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
                    onTap: _selectThumbnail,
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
                          'Tap untuk memilih thumbnail',
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
      },
    );
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
    return Consumer<WorkOrderDetailItemController>(
      builder: (context, controller, child) {
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
      },
    );
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
          const SizedBox(height: 20),
          
          // Baris 3: Action Buttons
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



  Widget _buildActionButton(Map<String, dynamic> assignment, int index, WorkOrderDetailItemController controller) {
    if (assignment['status'] == 'assigned') {
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
    } else if (assignment['status'] == 'pending') {
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
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  void _selectThumbnail() {
    // Implementasi untuk memilih thumbnail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur upload thumbnail akan diimplementasikan'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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



  void _saveItemDetail() {
    final controller = Provider.of<WorkOrderDetailItemController>(context, listen: false);
    
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

    // Simpan data
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
  }
}
