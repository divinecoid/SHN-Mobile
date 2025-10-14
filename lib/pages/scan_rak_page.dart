import 'package:flutter/material.dart';
import 'qr_scan_page.dart';
import 'input_detail_penerimaan_barang_page.dart';

class ScanRakPage extends StatefulWidget {
  final int idItemBarang;
  final Function(int idRak, int qty) onRakScanned;

  const ScanRakPage({
    super.key,
    required this.idItemBarang,
    required this.onRakScanned,
  });

  @override
  State<ScanRakPage> createState() => _ScanRakPageState();
}

class _ScanRakPageState extends State<ScanRakPage> {
  void _processScannedCode(String code) {
    // Parse the scanned code to extract rak ID
    // Assuming the QR code contains rak ID or we can extract it from the code
    try {
      // For now, we'll use a simple parsing logic
      // In real implementation, you might need to decode the QR code properly
      int rakId = int.tryParse(code) ?? 0;
      
      if (rakId > 0) {
        _navigateToInputDetail(rakId);
      } else {
        _showErrorDialog('QR Code tidak valid. Pastikan QR Code rak benar.');
      }
    } catch (e) {
      _showErrorDialog('Gagal memproses QR Code: $e');
    }
  }

  void _navigateToInputDetail(int rakId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputDetailPenerimaanBarangPage(
          idItemBarang: widget.idItemBarang,
          idRak: rakId,
          onDetailConfirmed: (idItemBarang, idRak, qty) {
            widget.onRakScanned(idRak, qty);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
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
            labelText: 'ID Rak',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'Masukkan ID rak',
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
                _navigateToInputDetail(id);
                Navigator.pop(context);
              } else {
                _showErrorDialog('ID rak tidak valid');
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
      isRack: true,
      onScanResult: _processScannedCode,
    );
  }
}
