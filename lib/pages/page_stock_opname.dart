import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/stock_opname_controller.dart';

class StockOpnamePage extends StatefulWidget {
  const StockOpnamePage({super.key});

  @override
  State<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends State<StockOpnamePage> {
  late StockOpnameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StockOpnameController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showWarehouseSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Pilih Lokasi Gudang',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _controller.warehouses.length,
            itemBuilder: (context, index) {
              final warehouse = _controller.warehouses[index];
              
              return ListTile(
                title: Text(
                  warehouse.namaGudang,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (warehouse.alamat != null && warehouse.alamat!.isNotEmpty)
                      Text(
                        warehouse.alamat!,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    if (warehouse.kode.isNotEmpty)
                      Text(
                        'Kode: ${warehouse.kode}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
                onTap: () {
                  // Update warehouse first, then close dialog
                  _controller.updateSelectedWarehouse(warehouse.namaGudang);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set context for session handling
    _controller.setContext(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationSection(),
                  const SizedBox(height: 16),
                  _buildFreezeStockSection(),
                  if (_controller.selectedWarehouse.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildItemBarangSection(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
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
                    'Lokasi Gudang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_controller.isLoadingLocation)
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mendeteksi lokasi...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.green[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Terdeteksi:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _controller.detectedLocation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: _showWarehouseSelector,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warehouse, color: Colors.orange[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gudang Dipilih:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _controller.selectedWarehouse.isEmpty
                                  ? 'Pilih gudang'
                                  : _controller.selectedWarehouse,
                              style: TextStyle(
                                color: _controller.selectedWarehouse.isEmpty
                                    ? Colors.grey[400]
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Only show location-related errors in this section
              if (_controller.errorMessage.isNotEmpty && 
                  (_controller.errorMessage.contains('lokasi') || 
                   _controller.errorMessage.contains('Lokasi') ||
                   _controller.errorMessage.contains('gudang') ||
                   _controller.errorMessage.contains('Gudang')))
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[300], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _controller.errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreezeStockSection() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
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
                  Icon(
                    _controller.stockFrozen 
                        ? Icons.lock 
                        : _controller.opnameStarted 
                            ? Icons.play_arrow 
                            : Icons.lock_open,
                    color: _controller.stockFrozen 
                        ? Colors.red[400] 
                        : _controller.opnameStarted 
                            ? Colors.blue[400] 
                            : Colors.green[400],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _controller.stockFrozen 
                        ? 'Stok Telah Dibekukan' 
                        : _controller.opnameStarted 
                            ? 'Opname Telah Dimulai' 
                            : 'Mulai Stock Opname',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_controller.stockFrozen)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[300], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stok telah dibekukan. Mulai melakukan stock opname sekarang.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_controller.opnameStarted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[300], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stock opname telah dimulai tanpa membekukan stok.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Pilih salah satu opsi untuk memulai stock opname.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              
              // Show stock opname-related errors
              if (_controller.errorMessage.isNotEmpty && 
                  !_controller.errorMessage.contains('lokasi') && 
                  !_controller.errorMessage.contains('Lokasi') &&
                  !_controller.errorMessage.contains('gudang') &&
                  !_controller.errorMessage.contains('Gudang') &&
                  !_controller.errorMessage.contains('item barang') &&
                  !_controller.errorMessage.contains('Item Barang'))
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[300], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _controller.errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Button 1: Bekukan Stok & Mulai Opname
              if (!_controller.opnameStarted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.selectedWarehouse.isEmpty || _controller.isFreezingStock || _controller.isStartingOpname
                        ? null
                        : _controller.freezeStockAndStartOpname,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _controller.stockFrozen ? Colors.grey[700] : Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _controller.isFreezingStock
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
                                'Membekukan Stok...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _controller.stockFrozen ? Icons.check : Icons.lock,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _controller.stockFrozen ? 'Stok Telah Dibekukan' : 'Bekukan Stok & Mulai Opname',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              
              // Button 2: Mulai Opname Tanpa Bekukan Stok
              if (!_controller.opnameStarted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.selectedWarehouse.isEmpty || _controller.isFreezingStock || _controller.isStartingOpname
                        ? null
                        : _controller.startOpnameWithoutFreeze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _controller.isStartingOpname
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
                                'Memulai Opname...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Mulai Opname Tanpa Bekukan Stok',
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
              
              if (_controller.opnameStarted || _controller.stockFrozen) ...[
                // Unfreeze button - shown when stock is frozen (with or without opname started)
                if (_controller.stockFrozen)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.selectedWarehouse.isEmpty || _controller.isUnfreezingStock
                          ? null
                          : _controller.unfreezeStock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _controller.isUnfreezingStock
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
                                  'Membuka Stok...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Buka Stok (Unfreeze)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                
                // Reset button
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.resetOpname,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Reset Opname'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _buildItemBarangSection() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        // Debug info
        debugPrint('Build ItemBarangSection - isLoading: ${_controller.isLoadingItems}, listLength: ${_controller.itemBarangList.length}, error: ${_controller.itemBarangError}');
        
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
                  Icon(Icons.inventory_2, color: Colors.blue[400], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Item Barang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_controller.isLoadingItems)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_controller.itemBarangError.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[300], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _controller.itemBarangError,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_controller.itemBarangList.isEmpty && !_controller.isLoadingItems)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tidak ada item barang di gudang ini.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_controller.itemBarangList.isNotEmpty)
                // Show items if list is not empty
                Column(
                  children: [
                    Text(
                      'Total: ${_controller.itemBarangList.length} item',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.itemBarangList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _controller.itemBarangList[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kode Barang (Title) with Frozen Badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.kodeBarang.isNotEmpty ? item.kodeBarang : item.namaItemBarang,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (item.frozenAt != null && item.frozenAt!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red[600],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'FROZEN',
                                            style: const TextStyle(
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
                              const SizedBox(height: 8),
                              
                              // Bentuk, Jenis, Grade
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (item.bentukBarang != null)
                                    _buildInfoChip(
                                      item.bentukBarang!.namaBentuk,
                                      Colors.green[300]!,
                                    ),
                                  if (item.jenisBarang != null)
                                    _buildInfoChip(
                                      item.jenisBarang!.namaJenis,
                                      Colors.blue[300]!,
                                    ),
                                  if (item.gradeBarang != null)
                                    _buildInfoChip(
                                      item.gradeBarang!.nama,
                                      Colors.orange[300]!,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Dimensi dan Quantity
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDetailRow(
                                      Icons.straighten,
                                      'Panjang',
                                      _formatNumber(item.panjang),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDetailRow(
                                      Icons.height,
                                      'Lebar',
                                      _formatNumber(item.lebar),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDetailRow(
                                      Icons.layers,
                                      'Tebal',
                                      _formatNumber(item.tebal),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Quantity
                              Row(
                                children: [
                                  Icon(Icons.inventory, color: Colors.amber[400], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Quantity: ${_formatNumber(item.quantity)}',
                                    style: TextStyle(
                                      color: Colors.amber[400],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    // Convert to integer (remove decimals)
    final intValue = value.round();
    // Format with thousand separator using Indonesian format (using dot)
    // Use NumberFormat.decimalPattern for locale-aware formatting
    final formatter = NumberFormat.decimalPattern('id_ID');
    return formatter.format(intValue);
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[400], size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 