import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_helper.dart';
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
                  
                  // Upload Photos Section
                  _buildUploadPhotosSection(),
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
                if (controller.canvasUrls.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[500],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada gambar canvas',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.canvasUrls.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final canvasUrl = controller.canvasUrls[index];
                        final fullUrl = _buildStorageUrl(canvasUrl) ?? '';
                        
                        return Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: InkWell(
                            onTap: () => _enlargeThumbnail(fullUrl),
                            borderRadius: BorderRadius.circular(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FutureBuilder<String?>(
                                future: SharedPreferences.getInstance().then((p) => p.getString('token')),
                                builder: (context, snapshot) {
                                  return Image.network(
                                    fullUrl,
                                    headers: snapshot.hasData ? {'Authorization': 'Bearer ${snapshot.data}'} : null,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, color: Colors.grey[600], size: 24),
                                            const SizedBox(height: 4),
                                            Text('Gagal', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
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
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        'Actual Weight',
                        controller.beratActualController,
                        'kg',
                        isReadOnly: true,
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

  Widget _buildInputField(String label, TextEditingController controller, String suffix, {bool isReadOnly = false}) {
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
          readOnly: isReadOnly,
          style: TextStyle(
            color: isReadOnly ? Colors.grey[300] : Colors.white, 
            fontSize: 14,
            fontWeight: isReadOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
            filled: true,
            fillColor: isReadOnly ? Colors.grey[800] : Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: isReadOnly ? Colors.grey[600]! : Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: isReadOnly ? Colors.grey[600]! : Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: isReadOnly ? Colors.grey[600]! : Colors.blue[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
        if (isReadOnly) ...[
          const SizedBox(height: 4),
          Text(
            'Otomatis dihitung dari assignment pelaksana',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssignmentInputField(String label, String value, String suffix, Function(String) onChanged, {bool isReadOnly = false}) {
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
            readOnly: isReadOnly,
            style: TextStyle(color: isReadOnly ? Colors.grey[300] : Colors.white, fontSize: 14, fontWeight: isReadOnly ? FontWeight.w600 : FontWeight.w500),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              filled: true,
              fillColor: isReadOnly ? Colors.grey[850] : Colors.grey[800],
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
                borderSide: BorderSide(color: isReadOnly ? Colors.grey[600]! : Colors.blue[400]!),
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

  String? _buildStorageUrl(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final base = baseUrl.replaceAll(RegExp(r'/api$'), '');
      var normalized = path.replaceAll(RegExp(r'^/+'), '');
      
      // Handle the item's foto_bukti specifically
      final itemBuktiMatch = RegExp(r'^work-order-actual/\d+/items/(\d+)/foto_bukti').firstMatch(normalized);
      if (itemBuktiMatch != null) {
        return '$base/api/work-order-actual/item/${itemBuktiMatch.group(1)}/image';
      }

      // Handle the item's foto_sisa_barang specifically
      final itemSisaMatch = RegExp(r'^work-order-actual/\d+/items/(\d+)/foto_sisa_barang').firstMatch(normalized);
      if (itemSisaMatch != null) {
        return '$base/api/work-order-actual/item/${itemSisaMatch.group(1)}/sisa-image';
      }

      // Handle the overall WO foto_bukti specifically
      final globalBuktiMatch = RegExp(r'^work-order-actual/(\d+)/foto_bukti').firstMatch(normalized);
      if (globalBuktiMatch != null) {
        return '$base/api/work-order-actual/${globalBuktiMatch.group(1)}/image';
      }
      
      final hasStoragePrefix = RegExp(r'^storage/').hasMatch(normalized);
      return hasStoragePrefix ? '$base/$normalized' : '$base/storage/$normalized';
    } catch (e) {
      return null;
    }
  }

  Widget _buildUploadPhotosSection() {
    final bool isCompleted = widget.workOrder['status'] == 'Completed' || widget.workOrder['status'] == 'Complete';
    try {
      return Consumer<WorkOrderDetailItemController>(
        builder: (context, controller, child) {
          try {
            return Column(
              children: [
                _buildPhotoSection(
                  title: 'Foto Bukti Pelaksanaan',
                  subtitle: isCompleted ? '' : 'Upload foto bukti pengerjaan item ini',
                  base64Data: controller.fotoBuktiBase64,
                  isCompleted: isCompleted,
                  onCamera: () => controller.pickAndSetFotoBukti(ImageSource.camera),
                  onGallery: () => controller.pickAndSetFotoBukti(ImageSource.gallery),
                  onClear: () => controller.clearFotoBukti(),
                ),
                const SizedBox(height: 20),
                _buildPhotoSection(
                  title: 'Foto Sisa Barang',
                  subtitle: isCompleted ? '' : 'Upload foto sisa potongan plat (Opsional)',
                  base64Data: controller.fotoSisaBase64,
                  isCompleted: isCompleted,
                  onCamera: () => controller.pickAndSetFotoSisa(ImageSource.camera),
                  onGallery: () => controller.pickAndSetFotoSisa(ImageSource.gallery),
                  onClear: () => controller.clearFotoSisa(),
                ),
              ],
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
                'Error loading upload photos section: $e',
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
          'Error loading upload photos section: $e',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildPhotoSection({
    required String title,
    required String subtitle,
    required String? base64Data,
    required bool isCompleted,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onClear,
  }) {
    if (isCompleted && (base64Data == null || base64Data.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (base64Data != null && base64Data.isNotEmpty)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                    image: isCompleted && !base64Data.startsWith('data:image') 
                       ? null 
                       : DecorationImage(
                      image: MemoryImage(base64Decode(base64Data.split(',').last)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isCompleted && !base64Data.startsWith('data:image')
                    ? FutureBuilder<String?>(
                        future: SharedPreferences.getInstance().then((p) => p.getString('token')),
                        builder: (context, snapshot) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _buildStorageUrl(base64Data) ?? '',
                                headers: snapshot.hasData ? {'Authorization': 'Bearer ${snapshot.data}'} : null,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, color: Colors.grey[600], size: 32),
                                        const SizedBox(height: 8),
                                        Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                        }
                      )
                    : null,
                ),
                if (!isCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            )
          else if (!isCompleted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentSection() {
    final bool isCompleted = widget.workOrder['status'] == 'Completed' || widget.workOrder['status'] == 'Complete';
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
                    if (!isCompleted)
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
                    child: _buildAssignmentRow(assignment, index, controller, isCompleted),
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

  Widget _buildAssignmentRow(Map<String, dynamic> assignment, int index, WorkOrderDetailItemController controller, bool isCompleted) {
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
          // Baris 1: Dropdown/Text Pelaksana
          if (isCompleted)
            _buildReadOnlyPelaksana(assignment)
          else
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
                  isReadOnly: isCompleted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAssignmentInputField(
                  'Berat',
                  assignment['berat'].toString(),
                  'kg',
                  (value) => controller.updateAssignmentBerat(index, value),
                  isReadOnly: isCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Baris 3: Informasi Jadwal (jika sudah assigned)
          if ((assignment['status'] as String?) == 'assigned' && assignment['tanggal'] != null)
            _buildScheduleInfo(assignment),
          
          // Baris 4: Action Buttons (Sembunyikan jika completed)
          if (!isCompleted)
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

  Widget _buildReadOnlyPelaksana(Map<String, dynamic> assignment) {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Text(
            assignment['pelaksana']?.toString() ?? 'Belum ada pelaksana',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
        onPressed: () => _deleteAssignment(index, controller),
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
    final bool isCompleted = widget.workOrder['status'] == 'Completed' || widget.workOrder['status'] == 'Complete';
    
    try {
      return Visibility(
        visible: !isCompleted,
        child: SizedBox(
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



  void _enlargeThumbnail(String imageUrl) {
    if (imageUrl.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: FutureBuilder<String?>(
                future: SharedPreferences.getInstance().then((p) => p.getString('token')),
                builder: (context, snapshot) {
                  return Image.network(
                    imageUrl,
                    headers: snapshot.hasData ? {'Authorization': 'Bearer ${snapshot.data}'} : null,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey[600], size: 64),
                            const SizedBox(height: 16),
                            Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
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
