import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:io';
import 'dart:convert';

class QRScanPage extends StatefulWidget {
  final bool isRack;
  final Function(String) onScanResult;

  const QRScanPage({
    super.key,
    required this.isRack,
    required this.onScanResult,
  });

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isScanning = true;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  int _scanAttempts = 0;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high, // Use high resolution for better detection
        enableAudio: false,
      );

      try {
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
        _startScanning();
      } catch (e) {
        _showErrorDialog('Gagal menginisialisasi kamera: $e');
      }
    } else {
      _showErrorDialog('Tidak ada kamera yang tersedia');
    }
  }

  void _startScanning() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.startImageStream((image) {
        if (_isScanning && !_isProcessing) {
          _processImageStream(image);
        }
      });
    }
  }

  Future<void> _processImageStream(CameraImage image) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _scanAttempts++;
      _debugInfo = 'Processing frame ${_scanAttempts}...';
    });

    try {
      final InputImage inputImage = _convertCameraImage(image);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      setState(() {
        _debugInfo = 'Found ${barcodes.length} barcodes';
      });

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null) {
          setState(() {
            _isScanning = false;
          });
          
          // Parse the result based on whether it's a rack or item scan
          String resultToReturn = barcode.rawValue!;
          
          try {
            // Try to parse as JSON first
            final jsonData = json.decode(barcode.rawValue!);
            
            if (jsonData is Map<String, dynamic>) {
              if (widget.isRack) {
                // For RAK: extract kode_rak
                if (jsonData.containsKey('kode_rak')) {
                  resultToReturn = jsonData['kode_rak'];
                  setState(() {
                    _debugInfo = 'Kode rak: $resultToReturn';
                  });
                } else {
                  setState(() {
                    _debugInfo = 'QR Code detected (no kode_rak): ${barcode.rawValue}';
                  });
                }
              } else {
                // For BARANG: extract kode
                if (jsonData.containsKey('kode')) {
                  resultToReturn = jsonData['kode'];
                  setState(() {
                    _debugInfo = 'Kode barang: $resultToReturn';
                  });
                } else {
                  setState(() {
                    _debugInfo = 'QR Code detected (no kode): ${barcode.rawValue}';
                  });
                }
              }
            } else {
              // Not a JSON object, use raw value
              setState(() {
                final displayValue = resultToReturn.length > 10 
                    ? '${resultToReturn.substring(0, 10)}...' 
                    : resultToReturn;
                _debugInfo = 'QR Code detected: $displayValue';
              });
            }
          } catch (e) {
            // If JSON parsing fails, use the raw value as-is
            setState(() {
              final displayValue = resultToReturn.length > 10 
                  ? '${resultToReturn.substring(0, 10)}...' 
                  : resultToReturn;
              _debugInfo = 'Using raw value: $displayValue';
            });
          }
          
          _showSuccessDialog(resultToReturn);
        }
      }
    } catch (e) {
      setState(() {
        _debugInfo = 'Error: $e';
      });
      // Don't show error dialog for processing errors during live scanning
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    // Get the rotation based on device orientation
    final rotation = _getImageRotation();
    
    // Handle different image formats
    final format = _getInputImageFormat(image.format.group);
    
    // For NV21 format (common on Android), we need to handle it properly
    if (Platform.isAndroid && image.format.group == ImageFormatGroup.yuv420) {
      // NV21 format - concatenate all plane bytes
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21, // Use NV21 for Android YUV420
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } else if (Platform.isIOS && image.format.group == ImageFormatGroup.bgra8888) {
      // BGRA8888 format (common on iOS)
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } else {
      // Generic fallback
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }
  }

  InputImageRotation _getImageRotation() {
    // Get the device orientation
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    
    // For Android, we need to account for sensor orientation
    if (Platform.isAndroid) {
      // Portrait mode is default
      switch (sensorOrientation) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    } else {
      // For iOS
      return InputImageRotation.rotation0deg;
    }
  }

  InputImageFormat _getInputImageFormat(ImageFormatGroup formatGroup) {
    switch (formatGroup) {
      case ImageFormatGroup.yuv420:
        return Platform.isAndroid 
            ? InputImageFormat.nv21 
            : InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return InputImageFormat.nv21; // Default to NV21 for Android
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            widget.isRack ? 'Scan QR Rak' : 'Scan QR Label Barang',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.isRack ? 'Scan QR Rak' : 'Scan QR Label Barang',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),
          
          // QR Scan Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.isRack ? Colors.green : Colors.orange,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                            left: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                            right: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                            left: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                            right: BorderSide(
                              color: widget.isRack ? Colors.green : Colors.orange,
                              width: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isRack 
                      ? 'Arahkan kamera ke QR Code rak'
                      : 'Arahkan kamera ke QR Code label barang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Debug Info
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _debugInfo,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Scanning indicator
          if (_isScanning)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isRack ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Memindai QR Code...',
                        style: TextStyle(
                          color: widget.isRack ? Colors.green : Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Cancel Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Batal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setFlashMode(
          _cameraController!.value.flashMode == FlashMode.off
              ? FlashMode.torch
              : FlashMode.off,
        );
      } catch (e) {
        _showErrorDialog('Gagal mengatur flash: $e');
      }
    }
  }

  void _showSuccessDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[400],
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'QR Code Terdeteksi!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isRack ? 'QR Code Rak:' : 'QR Code Label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isScanning = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Scan Ulang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onScanResult(result);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Gunakan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red[400],
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }
} 