import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/stock_check_model.dart';
import '../controllers/stock_check_controller.dart';
import 'package:provider/provider.dart';

class StockCheckDetailPage extends StatefulWidget {
  final StockCheckItem item;

  const StockCheckDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<StockCheckDetailPage> createState() => _StockCheckDetailPageState();
}

class _StockCheckDetailPageState extends State<StockCheckDetailPage> {
  String? _canvasImage;
  bool _isLoadingImage = true;
  String? _imageError;
  late StockCheckController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StockCheckController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCanvasImage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCanvasImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingImage = true;
      _imageError = null;
    });

    try {
      final canvasImage = await _controller.fetchCanvasImage(widget.item.id);
      
      if (!mounted) return;
      
      setState(() {
        _canvasImage = canvasImage;
        _isLoadingImage = false;
        if (canvasImage == null) {
          _imageError = 'Canvas image tidak tersedia';
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingImage = false;
        _imageError = 'Gagal memuat canvas image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Item',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Information Card
            _buildItemInfoCard(),
            const SizedBox(height: 20),
            
            // Canvas Image Section
            _buildCanvasImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfoCard() {
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.kodeBarang,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
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
                  'Qty: ${widget.item.quantity}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Nama Item
          Text(
            widget.item.namaItemBarang,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Gudang', widget.item.gudang.namaGudang),
              ),
              Expanded(
                child: _buildDetailItem('Jenis', widget.item.jenisBarang.namaJenis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Bentuk', widget.item.bentukBarang.namaBentuk),
              ),
              Expanded(
                child: _buildDetailItem('Grade', widget.item.gradeBarang.nama),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Panjang', '${widget.item.panjang}'),
              ),
              Expanded(
                child: _buildDetailItem('Lebar', '${widget.item.lebar}'),
              ),
              Expanded(
                child: _buildDetailItem('Tebal', '${widget.item.tebal}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Sisa Luas', '${widget.item.sisaLuas}'),
              ),
              Expanded(
                child: _buildDetailItem('Potongan', widget.item.jenisPotongan),
              ),
            ],
          ),
        ],
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
        const SizedBox(height: 4),
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

  Widget _buildCanvasImageSection() {
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
          const Text(
            'Canvas Image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingImage)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_imageError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[400],
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _imageError!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_canvasImage != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(_canvasImage!.split(',')[1]),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.red[400],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat gambar',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Canvas image tidak tersedia',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

