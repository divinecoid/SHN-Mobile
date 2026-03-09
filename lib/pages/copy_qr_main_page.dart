import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/copy_qr_controller.dart';
import '../services/printer_service.dart';
import 'qr_scan_page.dart';

class CopyQrMainPage extends StatefulWidget {
  const CopyQrMainPage({super.key});

  @override
  State<CopyQrMainPage> createState() => _CopyQrMainPageState();
}

class _CopyQrMainPageState extends State<CopyQrMainPage> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _kodeController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  Future<void> _processKode(String kode) async {
    if (kode.isEmpty) return;
    
    final controller = Provider.of<CopyQrController>(context, listen: false);
    
    // Hide keyboard if open
    FocusScope.of(context).unfocus();
    
    final success = await controller.fetchItemByKode(context, kode);
    if (success && mounted) {
      _kodeController.clear();
      _showPrintDialog(context, controller);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onScanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: false,
          onScanResult: (result) {
            _processKode(result);
          },
        ),
      ),
    );
  }

  void _showPrintDialog(BuildContext context, CopyQrController controller) {
    final item = controller.itemBarang;
    if (item == null) return;

    _qtyController.text = "1";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Konfirmasi Print Copy QR',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Kode:', item.kodeBarang),
              const SizedBox(height: 8),
              _buildInfoRow('Nama:', item.namaItemBarang),
              const SizedBox(height: 8),
              _buildInfoRow('Jenis:', item.jenisBarang?.namaJenis ?? item.itemBarangGroup?.jenisBarang?.namaJenis ?? "-"),
              const SizedBox(height: 8),
              _buildInfoRow('Bentuk:', item.bentukBarang?.namaBentuk ?? item.itemBarangGroup?.bentukBarang?.namaBentuk ?? "-"),
              const SizedBox(height: 8),
              _buildInfoRow('Grade:', item.gradeBarang?.nama ?? item.itemBarangGroup?.gradeBarang?.nama ?? "-"),
              const SizedBox(height: 16),
              const Text(
                'Jumlah Print:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                int copies = int.tryParse(_qtyController.text) ?? 0;
                if (copies <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jumlah print harus lebih dari 0'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context); // Tutup dialog sebelum proses

                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );

                  await PrinterService().printCopyItemBarangQR(item, copies);

                  if (mounted) {
                    Navigator.pop(context); // Tutup loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil mencetak Copy QR'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    controller.clearData();
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Tutup loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('PRINT QR COPY', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CopyQrController>(
        builder: (context, controller, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Copy QR Label Barang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan QR Code barang untuk mencetak\nsalinan label dengan mudah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                if (controller.isLoading)
                  const CircularProgressIndicator(color: Colors.blue)
                else ...[
                  ElevatedButton.icon(
                    onPressed: _onScanQR,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('SCAN SEKARANG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Atau input manual kode barang:',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _kodeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Masukkan Kode Barang',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onSubmitted: (value) => _processKode(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => _processKode(_kodeController.text),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
