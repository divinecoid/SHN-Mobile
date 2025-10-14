import 'package:flutter/material.dart';
import 'qr_scan_page.dart';

class ScanBarangPage extends StatefulWidget {
  final Function(int idItemBarang) onItemScanned;

  const ScanBarangPage({
    super.key,
    required this.onItemScanned,
  });

  @override
  State<ScanBarangPage> createState() => _ScanBarangPageState();
}

class _ScanBarangPageState extends State<ScanBarangPage> {
  void _processScannedCode(String code) {
    // Parse the scanned code to extract item ID
    // Assuming the QR code contains item ID or we can extract it from the code
    try {
      // For now, we'll use a simple parsing logic
      // In real implementation, you might need to decode the QR code properly
      int itemId = int.tryParse(code) ?? 0;
      
      if (itemId > 0) {
        widget.onItemScanned(itemId);
        Navigator.pop(context);
      } else {
        _showErrorDialog('QR Code tidak valid. Pastikan QR Code barang benar.');
      }
    } catch (e) {
      _showErrorDialog('Gagal memproses QR Code: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Input Manual',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ID Item Barang',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'Masukkan ID item barang',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final id = int.tryParse(controller.text);
              if (id != null && id > 0) {
                widget.onItemScanned(id);
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                _showErrorDialog('ID item barang tidak valid');
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QRScanPage(
      isRack: false,
      onScanResult: _processScannedCode,
    );
  }
}
