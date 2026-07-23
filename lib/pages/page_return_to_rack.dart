import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/return_to_rack_controller.dart';
import 'qr_scan_page.dart';

class ReturnToRackPage extends StatefulWidget {
  const ReturnToRackPage({super.key});

  @override
  State<ReturnToRackPage> createState() => _ReturnToRackPageState();
}

class _ReturnToRackPageState extends State<ReturnToRackPage> {
  final TextEditingController _catatanTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ReturnToRackController>();
      controller.reset();
      controller.fetchHistory(context);
    });
  }

  @override
  void dispose() {
    _catatanTextController.dispose();
    super.dispose();
  }

  void _openScanBarang(BuildContext context) {
    final controller = context.read<ReturnToRackController>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: false,
          onScanResult: (code) {
            controller.fetchItemByKode(code, context);
          },
        ),
      ),
    );
  }

  void _openScanRak(BuildContext context) {
    final controller = context.read<ReturnToRackController>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: true,
          onScanResult: (code) {
            controller.fetchRakByKode(code, context);
          },
        ),
      ),
    );
  }

  void _showManualInputBarangDialog(BuildContext context) {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Input Kode Barang', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: inputController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan Kode Barang (cth: ITM-001)',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = inputController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<ReturnToRackController>().fetchItemByKode(text, context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _showManualInputRakDialog(BuildContext context) {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Input Kode Rak Tujuan', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: inputController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan Kode Rak (cth: RAK-A1)',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = inputController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<ReturnToRackController>().fetchRakByKode(text, context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final controller = context.read<ReturnToRackController>();
    controller.catatan = _catatanTextController.text;
    final success = await controller.submitReturnToRack(context);

    if (mounted) {
      if (success) {
        _catatanTextController.clear();
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[400]),
                const SizedBox(width: 8),
                const Text('Berhasil', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              controller.successMessage ?? 'Barang berhasil dikembalikan ke rak!',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kembalikan ke Rak'),
        backgroundColor: Colors.black,
      ),
      body: Consumer<ReturnToRackController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display Error Banner if any
                if (controller.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[900]!.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[700]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage!,
                            style: TextStyle(color: Colors.red[200], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // STEP 1: Scan Barang
                _buildStepHeader(
                  stepNumber: '1',
                  title: 'Scan QR Barang',
                  subtitle: 'Pindai QR pada label barang',
                  isDone: controller.scannedItem != null,
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildItemSection(context, controller),

                const SizedBox(height: 24),

                // STEP 2: Scan Rak
                _buildStepHeader(
                  stepNumber: '2',
                  title: 'Scan QR Rak',
                  subtitle: 'Pindai QR rak penyimpanan',
                  isDone: controller.targetRak != null,
                  isActive: controller.scannedItem != null,
                ),
                const SizedBox(height: 12),
                _buildRakSection(context, controller),

                const SizedBox(height: 24),

                // Catatan Field
                if (controller.scannedItem != null && controller.targetRak != null) ...[
                  const Text(
                    'Catatan Tambahan (Opsional)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _catatanTextController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Save and Reset buttons
                ElevatedButton.icon(
                  onPressed: controller.canSubmit ? () => _handleSubmit(context) : null,
                  icon: controller.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.archive, size: 22),
                  label: Text(
                    controller.isSubmitting ? 'Memproses...' : 'Simpan Pengembalian',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                if (controller.scannedItem != null || controller.targetRak != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.reset();
                      _catatanTextController.clear();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset Form'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // History Section
                _buildHistorySection(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? Colors.green[600]
                : (isActive ? Colors.blue[600] : Colors.grey[800]),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    stepNumber,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemSection(BuildContext context, ReturnToRackController controller) {
    if (controller.isLoadingItem) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    final item = controller.scannedItem;
    if (item == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner, size: 48, color: Colors.blue[400]),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Barang Di-Scan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Pindai label barang untuk memulai',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openScanBarang(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan QR Barang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showManualInputBarangDialog(context),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Input Manual Kode',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Display Scanned Item Info
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[800]!.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.kodeBarang,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          _buildInfoRow('Nama Item', item.namaItemBarang ?? 'N/A'),
          _buildInfoRow('Jenis', item.jenisBarang?.namaJenis ?? 'N/A'),
          _buildInfoRow('Bentuk', item.bentukBarang?.namaBentuk ?? 'N/A'),
          _buildInfoRow('Grade', item.gradeBarang?.nama ?? 'N/A'),
          _buildInfoRow('Dimensi', '${item.panjang.toString().replaceAll(RegExp(r'\.0$'), '')}x${item.lebar.toString().replaceAll(RegExp(r'\.0$'), '')}x${item.tebal.toString().replaceAll(RegExp(r'\.0$'), '')}'),
          _buildInfoRow('Status Asal', item.jenisPotongan == 'potongan' ? 'Potongan' : 'Utuh'),
          _buildInfoRow('Rak Asal', item.rak?.kode ?? 'Tidak ada rak'),
          _buildInfoRow('Gudang Asal', item.gudang?.namaGudang ?? 'Tidak ada gudang'),
        ],
      ),
    );
  }

  Widget _buildRakSection(BuildContext context, ReturnToRackController controller) {
    if (controller.scannedItem == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Center(
          child: Text(
            'Selesaikan langkah 1 terlebih dahulu',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      );
    }

    if (controller.isLoadingRak) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    final rak = controller.targetRak;
    if (rak == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          children: [
            Icon(Icons.door_sliding, size: 48, color: Colors.green[400]),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Rak Di-Scan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Pindai QR rak tujuan penyimpanan barang',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openScanRak(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan QR Rak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showManualInputRakDialog(context),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Input Manual Kode',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Display Scanned Rak Info
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[800]!.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rak.kode,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          _buildInfoRow('Nama Rak', rak.namaRak),
          _buildInfoRow('Gudang', rak.namaGudang ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(ReturnToRackController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Riwayat Pengembalian Terakhir',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (controller.history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: const Center(
              child: Text(
                'Tidak ada riwayat pengembalian barang.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.history.length,
            itemBuilder: (context, index) {
              final item = controller.history[index];
              final itemBarang = item['item_barang'] ?? {};
              final rak = item['rak'] ?? {};
              
              String dateStr = item['created_at'] ?? '';
              try {
                if (dateStr.isNotEmpty) {
                  final dt = DateTime.parse(dateStr).toLocal();
                  dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                }
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemBarang['kode_barang'] ?? 'N/A',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      itemBarang['nama_item_barang'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.door_sliding, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Dikembalikan ke: ${rak['kode'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                    if (item['catatan'] != null && item['catatan'].toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Catatan: ${item['catatan']}',
                          style: TextStyle(color: Colors.grey[300], fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
