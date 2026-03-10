import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/saran_barang_controller.dart';


class PageSaranBarang extends StatefulWidget {
  const PageSaranBarang({super.key});

  @override
  State<PageSaranBarang> createState() => _PageSaranBarangState();
}

class _PageSaranBarangState extends State<PageSaranBarang> {
  late SaranBarangController _controller;
  final ScrollController _scrollController = ScrollController();

  // Text Controllers
  final TextEditingController _tebalCtrl = TextEditingController();
  final TextEditingController _panjangCtrl = TextEditingController();
  final TextEditingController _lebarCtrl = TextEditingController();
  final TextEditingController _diameterLuarCtrl = TextEditingController();
  final TextEditingController _diameterDalamCtrl = TextEditingController();
  final TextEditingController _diameterCtrl = TextEditingController();
  final TextEditingController _sisi1Ctrl = TextEditingController();
  final TextEditingController _sisi2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = SaranBarangController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadReferenceData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tebalCtrl.dispose();
    _panjangCtrl.dispose();
    _lebarCtrl.dispose();
    _diameterLuarCtrl.dispose();
    _diameterDalamCtrl.dispose();
    _diameterCtrl.dispose();
    _sisi1Ctrl.dispose();
    _sisi2Ctrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreSaran(context);
    }
  }

  Widget _buildDropdownFilter({
    required String label,
    required dynamic value,
    required List<dynamic> items,
    required Function(dynamic) onChanged,
    required String Function(dynamic) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isExpanded: true,
              value: value,
              dropdownColor: Colors.grey[900],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              hint: Text(
                'Semua $label',
                style: TextStyle(color: Colors.grey[500]),
              ),
              items: [
                DropdownMenuItem<dynamic>(
                  value: null,
                  child: Text('Semua $label'),
                ),
                ...items.map((item) {
                  return DropdownMenuItem<dynamic>(
                    value: item.id,
                    child: Text(itemBuilder(item)),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticDropdownFilter({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: Colors.grey[900],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  void _clearAllDimensionFields() {
    _tebalCtrl.clear();
    _panjangCtrl.clear();
    _lebarCtrl.clear();
    _diameterLuarCtrl.clear();
    _diameterDalamCtrl.clear();
    _diameterCtrl.clear();
    _sisi1Ctrl.clear();
    _sisi2Ctrl.clear();
  }

  void _onSearchSaran() async {
    // Collect all inputs, defaulting to 0.0 if empty
    double parseText(String val) {
      final parsed = double.tryParse(val.replaceAll(',', '.'));
      return parsed ?? 0.0;
    }
    
    _controller.updateRequest(
      tebal: parseText(_tebalCtrl.text),
      panjang: parseText(_panjangCtrl.text),
      lebar: parseText(_lebarCtrl.text),
      diameterLuar: parseText(_diameterLuarCtrl.text),
      diameterDalam: parseText(_diameterDalamCtrl.text),
      diameter: parseText(_diameterCtrl.text),
      sisi1: parseText(_sisi1Ctrl.text),
      sisi2: parseText(_sisi2Ctrl.text),
    );

    await _controller.fetchSaranBarang(context, loadMore: false);

    if (mounted && _controller.saranList.isNotEmpty) {
      _showSummaryPopup();
    }
  }

  void _showSummaryPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Hasil Pencarian', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ditemukan ${_controller.total} items yang sesuai dengan kriteria.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Sisa Qty:',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDouble(_controller.totalSisaQuantity),
              style: const TextStyle(
                color: Colors.green,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<SaranBarangController>(
          builder: (context, controller, child) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.grey[900],
                  elevation: 0,
                  title: const Text(
                    'Saran Barang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFilterSection(controller),
                ),
                SliverToBoxAdapter(
                  child: _buildResultCounter(controller),
                ),
                if (controller.isLoading && !controller.isLoadingMore)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (controller.errorMessage.isNotEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          controller.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  _buildSaranList(controller),
                if (controller.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection(SaranBarangController controller) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Jenis Barang Filter
          _buildDropdownFilter(
            label: 'Jenis Barang',
            value: controller.request.jenisBarangId,
            items: controller.jenisBarangList,
            onChanged: (value) => controller.updateRequest(jenisBarangId: value),
            itemBuilder: (item) => '${item.kode} - ${item.namaJenis}',
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Bentuk',
                  value: controller.request.bentukBarangId,
                  items: controller.bentukBarangList,
                  onChanged: (value) {
                    _clearAllDimensionFields();
                    controller.updateRequest(bentukBarangId: value);
                  },
                  itemBuilder: (item) => item.namaBentuk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Grade',
                  value: controller.request.gradeBarangId,
                  items: controller.gradeBarangList,
                  onChanged: (value) => controller.updateRequest(gradeBarangId: value),
                  itemBuilder: (item) => item.nama,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildStaticDropdownFilter(
            label: 'Jenis Potongan',
            value: controller.request.jenisPotongan ?? 'all',
            items: const [
              {'value': 'all', 'label': 'Semua'},
              {'value': 'utuh', 'label': 'Utuh'},
              {'value': 'potongan', 'label': 'Potongan'},
            ],
            onChanged: (value) {
              if (value != null) {
                controller.updateRequest(jenisPotongan: value);
              }
            },
          ),
          const SizedBox(height: 12),

          if (controller.selectedTipeBarang != null) ...[
            const Divider(color: Colors.grey),
            const Text('Dimensi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                if (controller.selectedTipeBarang!.panjang)
                  Expanded(
                    child: _buildTextField(
                      controller: _panjangCtrl,
                      label: 'Panjang',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                if (controller.selectedTipeBarang!.panjang) const SizedBox(width: 8),

                if (controller.selectedTipeBarang!.lebar)
                  Expanded(
                    child: _buildTextField(
                      controller: _lebarCtrl,
                      label: 'Lebar',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                if (controller.selectedTipeBarang!.lebar) const SizedBox(width: 8),

                if (controller.selectedTipeBarang!.tebal)
                  Expanded(
                    child: _buildTextField(
                      controller: _tebalCtrl,
                      label: 'Tebal',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
              ],
            ),
            
            if (controller.selectedTipeBarang!.diameter || controller.selectedTipeBarang!.diameterLuar || controller.selectedTipeBarang!.diameterDalam)
              const SizedBox(height: 12),
            
            Row(
              children: [
                if (controller.selectedTipeBarang!.diameter)
                  Expanded(
                    child: _buildTextField(
                      controller: _diameterCtrl,
                      label: 'Diameter',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                if (controller.selectedTipeBarang!.diameter) const SizedBox(width: 8),

                if (controller.selectedTipeBarang!.diameterLuar)
                  Expanded(
                    child: _buildTextField(
                      controller: _diameterLuarCtrl,
                      label: 'D. Luar',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                if (controller.selectedTipeBarang!.diameterLuar) const SizedBox(width: 8),

                if (controller.selectedTipeBarang!.diameterDalam)
                  Expanded(
                    child: _buildTextField(
                      controller: _diameterDalamCtrl,
                      label: 'D. Dalam',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
              ],
            ),
            
            if (controller.selectedTipeBarang!.sisi1 || controller.selectedTipeBarang!.sisi2)
              const SizedBox(height: 12),

            Row(
              children: [
                if (controller.selectedTipeBarang!.sisi1)
                  Expanded(
                    child: _buildTextField(
                      controller: _sisi1Ctrl,
                      label: 'Sisi 1',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                if (controller.selectedTipeBarang!.sisi1) const SizedBox(width: 8),

                if (controller.selectedTipeBarang!.sisi2)
                  Expanded(
                    child: _buildTextField(
                      controller: _sisi2Ctrl,
                      label: 'Sisi 2',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              _onSearchSaran();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cari Saran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCounter(SaranBarangController controller) {
    if (controller.isLoading && !controller.isLoadingMore) return const SizedBox.shrink();
    if (controller.saranList.isEmpty && controller.errorMessage.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Silakan pilih filter dan tekan Cari untuk menemukan saran barang.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${controller.saranList.length} dari ${controller.total} items',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDouble(double value) {
    return value.toStringAsFixed(0);
  }

  String _formatUkuran(String ukuran) {
    // Membulatkan angka yang ada dalam string ukuran, misal '1592.00 x 1542.00 x 88.00' -> '1592 x 1542 x 88'
    return ukuran.replaceAllMapped(RegExp(r'(\d+)\.\d+'), (match) {
      return match.group(1) ?? '';
    });
  }

  Widget _buildSaranList(SaranBarangController controller) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = controller.saranList[index];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[800]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDetailRow('Ukuran', _formatUkuran(item.ukuran))),
                        Expanded(child: _buildDetailRow('Selisih / Sisa Luas', _formatDouble(item.sisaLuas))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildDetailRow('Gudang', item.gudang)),
                        Expanded(child: _buildDetailRow('Rak', item.rak)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Sisa Qty', _formatDouble(item.sisaQuantity), isImportant: true),
                  ],
                ),
              ),
            );
          },
          childCount: controller.saranList.length,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isImportant = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isImportant ? Colors.green[400] : Colors.white,
            fontSize: 14,
            fontWeight: isImportant ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
