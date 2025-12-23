import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stock_check_controller.dart';
import '../models/stock_check_model.dart';
import 'stock_check_detail_page.dart';

class StockCheckPage extends StatefulWidget {
  const StockCheckPage({super.key});

  @override
  State<StockCheckPage> createState() => _StockCheckPageState();
}

class _StockCheckPageState extends State<StockCheckPage> 
    with SingleTickerProviderStateMixin {
  final _panjangController = TextEditingController();
  final _lebarController = TextEditingController();
  final _tebalController = TextEditingController();
  bool _isFilterExpanded = false; // Default collapsed
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockCheckController>().loadReferenceData();
    });
  }

  @override
  void dispose() {
    _panjangController.dispose();
    _lebarController.dispose();
    _tebalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<StockCheckController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Filter Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header dengan toggle button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isFilterExpanded = !_isFilterExpanded;
                            if (_isFilterExpanded) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Filter Pencarian',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _isFilterExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Collapsible content dengan animasi expand/collapse (atas ke bawah)
                      SizeTransition(
                        sizeFactor: _sizeAnimation,
                        axis: Axis.vertical,
                        axisAlignment: -1.0,
                        child: _isFilterExpanded
                            ? Container(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFilterSection(controller),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: controller.isLoading
                                                ? null
                                                : () => controller.checkStock(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: controller.isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : const Text('Cari Stok'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.clearFilters();
                                            _panjangController.clear();
                                            _lebarController.clear();
                                            _tebalController.clear();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[700],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text('Reset'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                // Results Section
                _buildResultsSection(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(StockCheckController controller) {
    return Column(
      children: [
        // Gudang Filter
        _buildDropdownFilter(
          label: 'Gudang',
          value: controller.selectedGudangId,
          items: controller.gudangList,
          onChanged: (value) => controller.setSelectedGudangId(value),
          itemBuilder: (item) => '${item.kode} - ${item.namaGudang}',
        ),
        const SizedBox(height: 12),
        
        // Jenis Barang Filter
        _buildDropdownFilter(
          label: 'Jenis Barang',
          value: controller.selectedJenisBarangId,
          items: controller.jenisBarangList,
          onChanged: (value) => controller.setSelectedJenisBarangId(value),
          itemBuilder: (item) => '${item.kode} - ${item.namaJenis}',
        ),
        const SizedBox(height: 12),
        
        // Bentuk Barang Filter
        _buildDropdownFilter(
          label: 'Bentuk Barang',
          value: controller.selectedBentukBarangId,
          items: controller.bentukBarangList,
          onChanged: (value) => controller.setSelectedBentukBarangId(value),
          itemBuilder: (item) => '${item.kode} - ${item.namaBentuk}',
        ),
        const SizedBox(height: 12),
        
        // Grade Barang Filter
        _buildDropdownFilter(
          label: 'Grade Barang',
          value: controller.selectedGradeBarangId,
          items: controller.gradeBarangList,
          onChanged: (value) => controller.setSelectedGradeBarangId(value),
          itemBuilder: (item) => '${item.kode} - ${item.nama}',
        ),
        const SizedBox(height: 12),
        
        // Dimensi Filters
        Row(
          children: [
            Expanded(
              child: _buildTextInputFilter(
                label: 'Panjang',
                controller: _panjangController,
                onChanged: (value) {
                  final doubleValue = double.tryParse(value);
                  controller.setPanjang(doubleValue);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextInputFilter(
                label: 'Lebar',
                controller: _lebarController,
                onChanged: (value) {
                  final doubleValue = double.tryParse(value);
                  controller.setLebar(doubleValue);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextInputFilter(
                label: 'Tebal',
                controller: _tebalController,
                onChanged: (value) {
                  final doubleValue = double.tryParse(value);
                  controller.setTebal(doubleValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required dynamic value,
    required List<T> items,
    required Function(dynamic) onChanged,
    required String Function(T) itemBuilder,
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
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value != null ? items.firstWhere((item) => 
                (item as dynamic).id == value, orElse: () => items.first) : null,
              isExpanded: true,
              hint: Text(
                'Pilih $label',
                style: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey[800],
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text(
                    'Semua $label',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
              ],
              onChanged: (T? newValue) {
                onChanged(newValue != null ? (newValue as dynamic).id : null);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputFilter({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
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
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
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
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultsSection(StockCheckController controller) {
    if (controller.isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.stockItems.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Tidak ada data stok yang ditemukan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
              bottom: BorderSide(color: Colors.grey[800]!),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Hasil Pencarian (${controller.stockItems.length} item)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: controller.stockItems.length,
          itemBuilder: (context, index) {
            final item = controller.stockItems[index];
            return _buildStockItemCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildStockItemCard(StockCheckItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockCheckDetailPage(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with kode barang
          Row(
            children: [
              Expanded(
                child: Text(
                  item.kodeBarang,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Nama item
          Text(
            item.namaItemBarang,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // Details grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Gudang', item.gudang.namaGudang),
              ),
              Expanded(
                child: _buildDetailItem('Jenis', item.jenisBarang.namaJenis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Bentuk', item.bentukBarang.namaBentuk),
              ),
              Expanded(
                child: _buildDetailItem('Grade', item.gradeBarang.nama),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Panjang', '${item.panjang}'),
              ),
              Expanded(
                child: _buildDetailItem('Lebar', '${item.lebar}'),
              ),
              Expanded(
                child: _buildDetailItem('Tebal', '${item.tebal}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Sisa Luas', '${item.sisaLuas}'),
              ),
              Expanded(
                child: _buildDetailItem('Potongan', item.jenisPotongan),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
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
        const SizedBox(height: 2),
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
  }
}
