import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/printer_service.dart';

class PageSettingsPrinter extends StatefulWidget {
  const PageSettingsPrinter({Key? key}) : super(key: key);

  @override
  State<PageSettingsPrinter> createState() => _PageSettingsPrinterState();
}

class _PageSettingsPrinterState extends State<PageSettingsPrinter> {
  final PrinterService _printerService = PrinterService();
  
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    // Request permissions for Android 12+
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    _printerService.bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() => _isScanning = true);
    try {
      List<BluetoothDevice> devices = await _printerService.getDevices();
      setState(() {
        _devices = devices;
      });
      
      // Check current connection status
      bool isConnected = await _printerService.isConnected;
      setState(() {
        _connected = isConnected;
      });
    } catch (e) {
      print("Error scanning devices: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() => _isScanning = true); // use scanning as loading indicator
    bool connected = await _printerService.connect(device);
    if (connected) {
      setState(() {
        _selectedDevice = device;
        _connected = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terhubung ke ${device.name}')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal terhubung ke ${device.name}')),
        );
      }
    }
    setState(() => _isScanning = false);
  }

  void _disconnect() async {
    await _printerService.disconnect();
    setState(() {
      _connected = false;
      _selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!_isScanning) {
                _scanDevices();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(
                  _connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _connected ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Printer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _connected 
                          ? 'Terhubung ${_selectedDevice != null ? 'ke ${_selectedDevice!.name}' : ''}'
                          : 'Tidak Terhubung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _connected ? Colors.green[700] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_connected)
                  ElevatedButton(
                    onPressed: _disconnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    child: const Text('Putuskan'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perangkat Tersedia (Bonded):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isScanning)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _devices.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada perangkat Bluetooth ditemukan.\nPastikan Anda sudah pairing printer ke HP ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(device.name ?? 'Unknown Device'),
                        subtitle: Text(device.address ?? ''),
                        trailing: ElevatedButton(
                          onPressed: _isScanning
                              ? null
                              : () => _connectToDevice(device),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Hubungkan'),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
