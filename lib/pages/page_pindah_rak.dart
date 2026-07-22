import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pindah_rak_controller.dart';
import 'qr_scan_page.dart';

class PindahRakPage extends StatefulWidget {
  const PindahRakPage({super.key});

  @override
  State<PindahRakPage> createState() => _PindahRakPageState();
}

class _PindahRakPageState extends State<PindahRakPage> {
  void _openScanBarang(BuildContext context) {
    final controller = context.read<PindahRakController>();
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
    final controller = context.read<PindahRakController>();
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
                context.read<PindahRakController>().fetchItemByKode(text, context);
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
                context.read<PindahRakController>().fetchRakByKode(text, context);
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
    final controller = context.read<PindahRakController>();
    final success = await controller.submitPindahRak(context);

    if (mounted) {
      if (success) {
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
            content: const Text(
              'Posisi rak barang berhasil diperbarui ke rak baru!',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  controller.reset();
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
    return Consumer<PindahRakController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
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
                  subtitle: 'Pindai QR pada label barang untuk melihat rak awal',
                  isDone: controller.scannedItem != null,
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildItemSection(context, controller),

                const SizedBox(height: 24),

                // STEP 2: Scan Rak Tujuan
                _buildStepHeader(
                  stepNumber: '2',
                  title: 'Scan QR Rak Tujuan',
                  subtitle: 'Pindai QR rak lokasi penyimpanan baru',
                  isDone: controller.targetRak != null && controller.validationError == null,
                  isActive: controller.scannedItem != null,
                ),
                const SizedBox(height: 12),
                _buildRakSection(context, controller),

                const SizedBox(height: 28),

                // STEP 3: Summary & Submit Button
                if (controller.scannedItem != null && controller.targetRak != null) ...[
                  _buildSummaryCard(controller),
                  const SizedBox(height: 20),
                ],

                ElevatedButton.icon(
                  onPressed: controller.canSubmit ? () => _handleSubmit(context) : null,
                  icon: controller.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.swap_horiz, size: 22),
                  label: Text(
                    controller.isSubmitting ? 'Memproses...' : 'Simpan Pindah Rak',
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
                    onPressed: () => controller.reset(),
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
              ],
            ),
          ),
        );
      },
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

  Widget _buildItemSection(BuildContext context, PindahRakController controller) {
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
    final hasRak = item.rakId != null && item.rak != null;
    final rakName = hasRak ? item.rak!.namaRak : 'Belum Ada Rak (NULL)';
    final gudangName = item.gudang?.namaGudang ?? 'ID Gudang: ${item.gudangId}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[700]!.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.namaItemBarang.isNotEmpty ? item.namaItemBarang : item.kodeBarang,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _openScanBarang(context),
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                tooltip: 'Scan Ulang Barang',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.blue[300],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 4),
          _buildInfoRow('Kode Barang:', item.kodeBarang),
          _buildInfoRow('Gudang Asal:', gudangName),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Rak Asal: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasRak ? Colors.orange[900]!.withOpacity(0.5) : Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: hasRak ? Colors.orange[600]! : Colors.grey[600]!,
                  ),
                ),
                child: Text(
                  rakName,
                  style: TextStyle(
                    color: hasRak ? Colors.orange[200] : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRakSection(BuildContext context, PindahRakController controller) {
    final isEnabled = controller.scannedItem != null;

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
          color: isEnabled ? Colors.grey[900] : Colors.grey[900]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isEnabled ? Colors.grey[800]! : Colors.grey[850]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 48,
              color: isEnabled ? Colors.green[400] : Colors.grey[700],
            ),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Rak Tujuan Di-Scan',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEnabled
                  ? 'Pindai QR rak lokasi baru'
                  : 'Selesaikan langkah 1 (Scan Barang) lebih dulu',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isEnabled ? () => _openScanRak(context) : null,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Scan QR Rak Tujuan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      disabledBackgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isEnabled ? () => _showManualInputRakDialog(context) : null,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Input Manual Kode Rak',
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
    final hasValidationError = controller.validationError != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValidationError
              ? Colors.red[600]!
              : Colors.green[700]!.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rak.namaRak.isNotEmpty ? rak.namaRak : rak.kode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _openScanRak(context),
                icon: const Icon(Icons.qr_code_2, size: 20),
                tooltip: 'Scan Ulang Rak',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.green[300],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 4),
          _buildInfoRow('Kode Rak:', rak.kode),
          _buildInfoRow(
            'Gudang Rak:',
            rak.namaGudang != null && rak.namaGudang!.isNotEmpty
                ? rak.namaGudang!
                : (rak.gudangId != 0 ? 'ID Gudang: ${rak.gudangId}' : '-'),
          ),
          
          if (hasValidationError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[950],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red[800]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.validationError!,
                      style: TextStyle(color: Colors.red[200], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[400], size: 16),
                const SizedBox(width: 6),
                Text(
                  controller.scannedItem?.rakId == null
                      ? 'Valid (Rak awal Kosong - Bebas pindah gudang)'
                      : 'Valid (Gudang Rak Sesuai)',
                  style: TextStyle(color: Colors.green[300], fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PindahRakController controller) {
    final item = controller.scannedItem!;
    final rak = controller.targetRak!;
    final rakLamaNama = item.rakId != null && item.rak != null ? item.rak!.namaRak : 'Tanpa Rak';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[500]!.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Perubahan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rak Asal', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      rakLamaNama,
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Rak Baru', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      rak.namaRak.isNotEmpty ? rak.namaRak : rak.kode,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
