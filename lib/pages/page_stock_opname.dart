import 'package:flutter/material.dart';

class StockOpnamePage extends StatelessWidget {
  const StockOpnamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Stock Opname',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Stock Opname',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Halaman ini digunakan untuk melakukan penghitungan fisik stok barang.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Placeholder for future content
                    Row(
                      children: [
                        const Icon(
                          Icons.assessment,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Sistem stock opname akan memungkinkan Anda untuk:\n'
                            '• Hitung fisik stok\n'
                            '• Bandingkan dengan sistem\n'
                            '• Generate laporan selisih\n'
                            '• Update stok otomatis',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 