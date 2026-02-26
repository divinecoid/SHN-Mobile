import 'dart:convert';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/penerimaan_barang_model.dart';
import 'package:intl/intl.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    try {
      return await bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting devices: $e");
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == true) {
        await bluetooth.disconnect();
      }
      await bluetooth.connect(device);
      
      // Save the last connected device address
      if (device.address != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_printer_address', device.address!);
      }
      return true;
    } catch (e) {
      print("Error connecting to printer: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
    } catch (e) {
      print("Error disconnecting from printer: $e");
    }
  }

  Future<bool> get isConnected async {
    return await bluetooth.isConnected ?? false;
  }

  /// Tries to auto-connect to the last used printer. 
  /// Returns [true] if successful.
  Future<bool> autoConnect() async {
    try {
      if (await isConnected) return true;
      
      final prefs = await SharedPreferences.getInstance();
      String? lastAddress = prefs.getString('last_printer_address');
      
      if (lastAddress != null) {
        List<BluetoothDevice> devices = await getDevices();
        for (var device in devices) {
          if (device.address == lastAddress) {
            return await connect(device);
          }
        }
      }
    } catch (e) {
      print("Auto connect error: $e");
    }
    return false;
  }

  /// Memformat teks dimensi (mengikuti logic desktop)
  String _buildDimensiItem(PenerimaanBarangDetail detail) {
    if (detail.itemBarangGroup == null) return "-";
    final group = detail.itemBarangGroup!;
    List<double> dimensions = [];

    double? parseDim(String? val) {
      if (val == null) return null;
      return double.tryParse(val.replaceAll(',', '.'));
    }

    final dLuar = parseDim(group.diameterLuar);
    if (dLuar != null && dLuar > 0) dimensions.add(dLuar);
    
    final dDalam = parseDim(group.diameterDalam);
    if (dDalam != null && dDalam > 0) dimensions.add(dDalam);
    
    final d = parseDim(group.diameter);
    if (d != null && d > 0) dimensions.add(d);
    
    final s1 = parseDim(group.sisi1);
    if (s1 != null && s1 > 0) dimensions.add(s1);
    
    final s2 = parseDim(group.sisi2);
    if (s2 != null && s2 > 0) dimensions.add(s2);
    
    final t = parseDim(group.tebal);
    if (t != null && t > 0) dimensions.add(t);
    
    final l = parseDim(group.lebar);
    if (l != null && l > 0) dimensions.add(l);
    
    final p = parseDim(group.panjang);
    if (p != null && p > 0) dimensions.add(p);

    if (dimensions.isEmpty) return "-";
    return dimensions.join("x");
  }

  /// Print single item QR
  Future<void> printItemQR(PenerimaanBarangDetail detail) async {
    bool connected = await isConnected;
    if (!connected) {
      connected = await autoConnect();
      if (!connected) {
        throw Exception("Printer belum terkoneksi. Silakan sambungkan di pengaturan.");
      }
    }

    final item = detail.itemBarang;
    if (item == null) {
      throw Exception("Data Item Barang tidak ditemukan.");
    }
    final group = detail.itemBarangGroup;

    // Build payload for QR
    final payloadMap = {
      "id": item.id,
      "kode": item.kodeBarang,
      "nama": item.namaItemBarang
    };
    final payloadJson = jsonEncode(payloadMap);
    
    // Dimensi
    final String dimensi = _buildDimensiItem(detail);
    
    // Format tanggal cetak
    final dateStr = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    try {
      bluetooth.printCustom("PT SURYA LOGAM JAYA", 1, 1);
      bluetooth.printNewLine();

      // Render QR Code 
      // width and height usually around 200-300 for 58mm printer to look decent
      bluetooth.printQRcode(payloadJson, 250, 250, 1);
      bluetooth.printNewLine();

      // Item Information
      // Size 0 = Normal, 1 = Normal Bold, 2 = Large
      // Align 0 = kiri, 1 = tengah, 2 = kanan
      bluetooth.printCustom("Kode Barang:", 0, 0);
      bluetooth.printCustom(item.kodeBarang, 1, 0);
      
      bluetooth.printCustom("Nama Item:", 0, 0);
      bluetooth.printCustom(item.namaItemBarang, 1, 0);
      
      bluetooth.printCustom("Jenis:", 0, 0);
      bluetooth.printCustom(group?.jenisBarang?.namaJenis ?? "-", 1, 0);
      
      bluetooth.printCustom("Bentuk:", 0, 0);
      bluetooth.printCustom(group?.bentukBarang?.namaBentuk ?? "-", 1, 0);
      
      bluetooth.printCustom("Grade:", 0, 0);
      bluetooth.printCustom(group?.gradeBarang?.nama ?? "-", 1, 0);
      
      bluetooth.printCustom("Dimensi:", 0, 0);
      bluetooth.printCustom(dimensi, 1, 0);

      bluetooth.printNewLine();
      bluetooth.printCustom("Date Printed:", 0, 0);
      bluetooth.printCustom(dateStr, 0, 0);

      bluetooth.printNewLine();
      bluetooth.printCustom("----------------", 1, 1);
      bluetooth.printCustom("SHN WMS", 0, 1);
      
      // Feed paper to make room for tearing
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
    } catch (e) {
      print("Error printing: $e");
      throw Exception("Gagal mencetak: $e");
    }
  }

  /// Print batch items QR
  Future<void> printBatchQR(List<PenerimaanBarangDetail> items) async {
    bool connected = await isConnected;
    if (!connected) {
      connected = await autoConnect();
      if (!connected) {
        throw Exception("Printer belum terkoneksi. Silakan sambungkan di pengaturan.");
      }
    }

    try {
      for (int i = 0; i < items.length; i++) {
        final detail = items[i];
        final item = detail.itemBarang;
        if (item == null) continue;

        final group = detail.itemBarangGroup;
        
        // Build payload for QR
        final payloadMap = {
          "id": item.id,
          "kode": item.kodeBarang,
          "nama": item.namaItemBarang
        };
        final payloadJson = jsonEncode(payloadMap);
        
        final String dimensi = _buildDimensiItem(detail);
        final dateStr = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

        bluetooth.printCustom("PT SURYA LOGAM JAYA", 1, 1);
        bluetooth.printNewLine();

        bluetooth.printQRcode(payloadJson, 250, 250, 1);
        bluetooth.printNewLine();

        bluetooth.printCustom("Kode Barang:", 0, 0);
        bluetooth.printCustom(item.kodeBarang, 1, 0);
        
        bluetooth.printCustom("Nama Item:", 0, 0);
        bluetooth.printCustom(item.namaItemBarang, 1, 0);
        
        bluetooth.printCustom("Jenis:", 0, 0);
        bluetooth.printCustom(group?.jenisBarang?.namaJenis ?? "-", 1, 0);
        
        bluetooth.printCustom("Bentuk:", 0, 0);
        bluetooth.printCustom(group?.bentukBarang?.namaBentuk ?? "-", 1, 0);
        
        bluetooth.printCustom("Grade:", 0, 0);
        bluetooth.printCustom(group?.gradeBarang?.nama ?? "-", 1, 0);
        
        bluetooth.printCustom("Dimensi:", 0, 0);
        bluetooth.printCustom(dimensi, 1, 0);

        bluetooth.printNewLine();
        bluetooth.printCustom("Date Printed:", 0, 0);
        bluetooth.printCustom(dateStr, 0, 0);

        bluetooth.printNewLine();
        bluetooth.printCustom("----------------", 1, 1);
        bluetooth.printCustom("SHN WMS", 0, 1);
        
        // Pemisah antar item batch
        if (i < items.length - 1) {
          bluetooth.printNewLine();
          bluetooth.printCustom("- - - - - - - - -", 1, 1);
          bluetooth.printNewLine();
        } else {
          // Feed paper at the end
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
        }
      }
    } catch (e) {
      print("Error batch printing: $e");
      throw Exception("Gagal mencetak batch: $e");
    }
  }
}
