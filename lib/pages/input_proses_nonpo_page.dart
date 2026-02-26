import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/penerimaan_barang_model.dart';
import '../controllers/proses_nonpo_controller.dart';
import 'package:provider/provider.dart';

class InputProsesNonPoPage extends StatefulWidget {
  final PenerimaanBarangDetail detail;

  const InputProsesNonPoPage({
    super.key,
    required this.detail,
  });

  @override
  State<InputProsesNonPoPage> createState() => _InputProsesNonPoPageState();
}

class _InputProsesNonPoPageState extends State<InputProsesNonPoPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _hargaModalController = TextEditingController();
  final _beratController = TextEditingController();

  @override
  void dispose() {
    _hargaModalController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  void _submitData(ProsesNonPoController controller) async {
    if (!_formKey.currentState!.validate()) return;

    // Convert comma to dot for parsing
    final hargaModalStr = _hargaModalController.text.replaceAll(',', '.');
    final beratStr = _beratController.text.replaceAll(',', '.');

    final hargaModal = double.tryParse(hargaModalStr) ?? 0.0;
    final berat = double.tryParse(beratStr) ?? 0.0;

    final success = await controller.submitProcessNonPo(
      widget.detail.id,
      hargaModal,
      berat,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memproses item.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to trigger refresh on list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorSubmit ?? 'Gagal memproses item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.detail.itemBarangGroup;
    final namaItem = group?.namaGroupBarang ?? 'Unknown Item';
    final rakName = widget.detail.rak?.namaRak ?? '-';
    
    // Safety check: depending on structure it might be `penerimaanBarang.gudang`
    // but in PenerimaanBarangDetail we don't have direct access to gudang unless nested,
    // we'll handle gracefully.
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Input Harga Non-PO'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[800],
            height: 1.0,
          ),
        ),
      ),
      body: Consumer<ProsesNonPoController>(
        builder: (context, controller, child) {
          // Set context just in case
          controller.setContext(context);
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Barang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Nama Item', namaItem, Icons.inventory),
                            _buildInfoRow('QTY', '${widget.detail.qty}', Icons.numbers),
                            _buildInfoRow('Tipe Terima', widget.detail.tipeTerima ?? '-', Icons.category),
                            _buildInfoRow('Rak', rakName, Icons.shelves),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Harga Modal
                      const Text(
                        'Harga Modal (Rp)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _hargaModalController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d*')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan harga modal',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[900],
                          prefixIcon: Icon(Icons.attach_money, color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga modal harus diisi';
                          }
                          final valStr = value.replaceAll(',', '.');
                          if (double.tryParse(valStr) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Input Berat
                      const Text(
                        'Berat (kg)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _beratController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d*')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan berat (kg)',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[900],
                          prefixIcon: Icon(Icons.scale, color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[800]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Berat harus diisi';
                          }
                          final valStr = value.replaceAll(',', '.');
                          if (double.tryParse(valStr) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitLoading
                              ? null
                              : () => _submitData(controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isSubmitLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Proses Barang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (controller.isSubmitLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
