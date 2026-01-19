import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../controllers/input_penerimaan_barang_controller.dart';
import '../models/gudang_model.dart';
import 'scan_barang_page.dart';
import 'scan_rak_page.dart';
import 'qr_scan_page.dart';

class InputPenerimaanBarangPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  
  const InputPenerimaanBarangPage({super.key, this.onSuccess});

  @override
  State<InputPenerimaanBarangPage> createState() => _InputPenerimaanBarangPageState();
}

class _InputPenerimaanBarangPageState extends State<InputPenerimaanBarangPage> {
  final _formKey = GlobalKey<FormState>();
  late final InputPenerimaanBarangController _controller;
  late final TextEditingController _numberController;
  late final TextEditingController _rakController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = InputPenerimaanBarangController();
    _numberController = TextEditingController(text: _controller.scannedNumber);
    _rakController = _controller.rakController;
    // Load gudang list when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGudangList();
    });
  }

  Future<void> _loadGudangList() async {
    await _controller.loadGudangList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _numberController.dispose();
    _controller.dispose();
    super.dispose();
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _showIncompleteScanDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[400],
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Peringatan',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
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
              'Belum semua barang terscan!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress scan: ${_controller.getScanProgress()}',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Apakah Anda yakin ingin melanjutkan tanpa menyelesaikan scan semua barang?',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
  }

  void _showGudangSelector() {
    if (_controller.gudangList.isEmpty && !_controller.isLoadingGudang) {
      _showSnackBar('Tidak ada data gudang yang tersedia');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Pilih Gudang',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _controller.isLoadingGudang
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Memuat data gudang...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : _controller.gudangList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada data gudang',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _controller.gudangList.length,
                      itemBuilder: (context, index) {
                        final gudang = _controller.gudangList[index];
                        return ListTile(
                          title: Text(
                            gudang.namaGudang,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${gudang.kode}${gudang.teleponHp != null ? ' • ${gudang.teleponHp}' : ''}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          onTap: () {
                            setState(() {
                              _controller.selectGudang(gudang);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
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
          if (_controller.gudangError != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadGudangList();
              },
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Pilih Sumber Gambar',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text(
                'Kamera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _controller.pickImage(ImageSource.camera);
                  setState(() {});
                } catch (e) {
                  _showSnackBar('Gagal mengambil gambar: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text(
                'Galeri',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _controller.pickImage(ImageSource.gallery);
                  setState(() {});
                } catch (e) {
                  _showSnackBar('Gagal mengambil gambar: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScanNumber() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: false, // Not scanning rack, scanning PO/Mutation number
          onScanResult: (scannedData) {
            setState(() {
              _controller.setScannedNumber(scannedData);
              _numberController.text = scannedData;
            });
            // Trigger immediate fetch after successful scan
            _controller.fetchDokumenByNumber().then((_) {
              if (mounted) setState(() {});
            }).catchError((e) {
              if (mounted) _showSnackBar('$e');
            });
          },
        ),
      ),
    );
  }

  void _navigateToScanBarang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: false, // Scanning barang barcode
          onScanResult: (scannedBarcode) {
            // Check if the scanned barcode matches any item in the list
            bool found = false;
            for (var item in _controller.scannedItems) {
              if (item.kodeBarang == scannedBarcode) {
                setState(() {
                  _controller.addScannedBarcode(scannedBarcode);
                });
                found = true;
                _showSnackBar('Barang dengan kode $scannedBarcode berhasil di-scan!');
                break;
              }
            }
            
            if (!found) {
              _showSnackBar('Kode barang $scannedBarcode tidak ditemukan dalam daftar');
            }
          },
        ),
      ),
    );
  }

  void _navigateToScanRak(int idItemBarang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanRakPage(
          idItemBarang: idItemBarang,
          onRakScanned: (idRak, qty) {
            setState(() {
              _controller.addDetail(idItemBarang, idRak, qty);
            });
          },
        ),
      ),
    );
  }

  void _navigateToScanRakBatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(
          isRack: true, // Scanning RAK
          onScanResult: (scannedData) async {
            // Update text field immediately
            setState(() {
              _rakController.text = scannedData;
            });
            
            // Fetch RAK details from API
            try {
              await _controller.fetchRakByCode(scannedData);
              if (mounted) {
                setState(() {});
                _showSnackBar('RAK ${_controller.selectedRakKode} berhasil dipilih');
              }
            } catch (e) {
              if (mounted) {
                _showSnackBar('$e');
              }
            }
          },
        ),
      ),
    );
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if all items are scanned
    if (!_controller.areAllItemsScanned()) {
      final shouldContinue = await _showIncompleteScanDialog();
      if (!shouldContinue) {
        return;
      }
    }

    try {
      setState(() {
        // Trigger UI update for loading state
      });
      final success = await _controller.submitForm();
      
      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[400],
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Berhasil!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Data penerimaan barang berhasil disimpan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            actions: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the success dialog
                    
                    // Call the success callback if provided
                    if (widget.onSuccess != null) {
                      widget.onSuccess!();
                    } else {
                      // Fallback to normal navigation
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Input Penerimaan Barang',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin Selection
                _buildOriginSection(),
                const SizedBox(height: 16),

                // Scan Number Section
                _buildScanNumberSection(),
                const SizedBox(height: 16),

                // Gudang Selection
                _buildGudangSection(),
                const SizedBox(height: 16),

                // RAK Selection
                _buildRakSection(),
                const SizedBox(height: 16),

                // Details List (moved above Catatan)
                _buildDetailsSection(),
                const SizedBox(height: 16),

                // Catatan
                _buildCatatanSection(),
                const SizedBox(height: 16),

                // Image Upload
                _buildImageSection(),
                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOriginSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: Colors.cyan[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Asal Penerimaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.selectedOrigin,
                isExpanded: true,
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'purchaseorder',
                    child: Text('Purchase Order'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'stockmutation',
                    child: Text('Stock Mutation'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _controller.setSelectedOrigin(newValue);
                      _numberController.clear();
                      _debounce?.cancel();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNumberSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.purple[400], size: 24),
              const SizedBox(width: 8),
              Text(
                _controller.selectedOrigin == 'purchaseorder' ? 'Nomor PO' : 'Nomor Mutasi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numberController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _controller.setScannedNumber(value.trim());
              });
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 1000), () async {
                final text = _numberController.text.trim();
                if (text.isEmpty) return;
                try {
                  await _controller.fetchDokumenByNumber();
                  if (mounted) setState(() {});
                } catch (e) {
                  if (mounted) _showSnackBar('$e');
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Masukkan atau scan ${_controller.selectedOrigin == 'purchaseorder' ? 'Nomor PO' : "Nomor Mutasi"}',
              hintStyle: TextStyle(color: Colors.grey[400]),
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
                borderSide: BorderSide(color: Colors.purple[400]!),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_numberController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Bersihkan',
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _numberController.clear();
                          _controller.setScannedNumber('');
                          // also clear fetched items
                          _controller.setSelectedOrigin(_controller.selectedOrigin);
                        });
                      },
                    ),
                  IconButton(
                    tooltip: 'Scan',
                    icon: Icon(Icons.qr_code_scanner, color: Colors.purple[400]),
                    onPressed: _navigateToScanNumber,
                  ),
                ],
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _controller.selectedOrigin == 'purchaseorder' 
                  ? 'Nomor PO harus diisi'
                  : 'Nomor Mutasi harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGudangSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Gudang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_controller.isLoadingGudang) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (_controller.gudangError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.gudangError!,
                      style: TextStyle(
                        color: Colors.red[200],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadGudangList,
                    child: Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: _controller.isLoadingGudang ? null : _showGudangSelector,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.selectedGudangName.isEmpty ? 'Pilih Gudang' : _controller.selectedGudangName,
                          style: TextStyle(
                            color: _controller.selectedGudangName.isEmpty ? Colors.grey[400] : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _controller.isLoadingGudang 
                            ? 'Memuat data gudang...' 
                            : 'Tap untuk memilih gudang',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _controller.isLoadingGudang ? Icons.hourglass_empty : Icons.edit, 
                    color: Colors.grey[400], 
                    size: 20
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRakSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warehouse, color: Colors.purple[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Rak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rakController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {});
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 1000), () async {
                final text = _rakController.text.trim();
                if (text.isEmpty) return;
                try {
                  await _controller.fetchRakByCode(text);
                  if (mounted) setState(() {});
                } catch (e) {
                  if (mounted) _showSnackBar('$e');
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Masukkan atau scan kode rak',
              hintStyle: TextStyle(color: Colors.grey[400]),
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
                borderSide: BorderSide(color: Colors.purple[400]!),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_rakController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Bersihkan',
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _controller.clearRak();
                        });
                      },
                    ),
                  IconButton(
                    tooltip: 'Scan RAK',
                    icon: Icon(Icons.qr_code_scanner, color: Colors.purple[400]),
                    onPressed: _navigateToScanRakBatch,
                  ),
                ],
              ),
            ),
            validator: (value) {
              if (_controller.selectedRakId == null) {
                return 'RAK harus dipilih';
              }
              return null;
            },
          ),
          if (_controller.selectedRakId != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warehouse, color: Colors.purple[400], size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _controller.selectedRakNama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Valid',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCatatanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: Colors.yellow[400], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Catatan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller.catatanController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan...',
              hintStyle: TextStyle(color: Colors.grey[400]),
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
                borderSide: BorderSide(color: Colors.yellow[400]!),
              ),
            ),
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
              ],
            ),
            const SizedBox(height: 16),
            if (_controller.selectedImage == null)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk memilih foto',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.file(
                        _controller.selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Ganti Foto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _controller.removeImage();
                                });
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory, color: Colors.orange[400], size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Detail Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_controller.scannedItems.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _controller.areAllItemsScanned() ? Colors.green[800] : Colors.blue[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _controller.getScanProgress(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToScanBarang,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Scan Barang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const SizedBox(height: 12),
          if (_controller.scannedItems.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.scannedItems.length,
              itemBuilder: (context, index) {
                final item = _controller.scannedItems[index];
                final isScanned = _controller.isItemScanned(item.kodeBarang);
                return Card(
                  color: isScanned ? Colors.green[900] : Colors.grey[850],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Small icon in upper left
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isScanned ? Colors.green[600] : Colors.grey[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isScanned ? Icons.check_circle : Icons.inventory_2,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Content area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 'ID: ${item.itemBarangId ?? '-'} • Qty: ${item.qty ?? item.quantity ?? '-'}',
                                'Qty: ${item.qty ?? item.quantity ?? '-'}',
                                style: TextStyle(
                                  color: isScanned ? Colors.green[100] : Colors.white,
                                  fontWeight: isScanned ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (item.kodeBarang != null && item.kodeBarang!.isNotEmpty) ...[
                                Text(
                                  'Kode:',
                                  style: TextStyle(
                                    color: isScanned ? Colors.green[200] : Colors.grey[400],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  item.kodeBarang!,
                                  style: TextStyle(
                                    color: isScanned ? Colors.green[200] : Colors.grey[400],
                                    fontWeight: isScanned ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                'Ukuran:',
                                style: TextStyle(
                                  color: isScanned ? Colors.green[200] : Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${item.panjang ?? '-'} x ${item.lebar ?? '-'} x ${item.tebal ?? '-'}',
                                style: TextStyle(
                                  color: isScanned ? Colors.green[200] : Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              if (isScanned) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'TERSCAN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isScanned)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.removeScannedBarcode(item.kodeBarang!);
                                  });
                                },
                                icon: const Icon(Icons.undo, color: Colors.orange, size: 20),
                                tooltip: 'Batalkan scan',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _controller.scannedItems.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          else if (_controller.details.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada detail barang',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Input Nomor PO/Mutation untuk melihat detail barang',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.details.length,
              itemBuilder: (context, index) {
                final detail = _controller.details[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      'Item ID: ${detail.idItemBarang}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Rak ID: ${detail.idRak} • Qty: ${detail.qty}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _controller.removeDetail(index);
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _controller.isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _controller.isSubmitting ? Colors.grey[600] : Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _controller.isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Simpan Penerimaan Barang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
