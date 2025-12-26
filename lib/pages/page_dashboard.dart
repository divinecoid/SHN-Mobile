import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'page_login.dart';
import 'terima_barang_main_page.dart';
import 'page_stock_opname.dart';
import 'stock_opname_list_page.dart';
import 'page_work_order.dart';
import 'page_stock_check.dart';
import '../utils/auth_helper.dart';
import '../controllers/stock_check_controller.dart';
import '../services/permission_service.dart';

class DashboardMenuItem {
  final String title;
  final String menuCode;
  final IconData icon;
  final Widget page;

  DashboardMenuItem({
    required this.title,
    required this.menuCode,
    required this.icon,
    required this.page,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = 'Admin';
  int selectedIndex = 0;
  bool _isLoading = true;
  List<DashboardMenuItem> _availableMenuItems = [];

  // Semua menu yang tersedia di dashboard
  final List<DashboardMenuItem> _allMenuItems = [
    DashboardMenuItem(
      title: 'Dashboard',
      menuCode: 'DASHBOARD',
      icon: Icons.dashboard,
      page: const DashboardContent(),
    ),
    DashboardMenuItem(
      title: 'Cek Stok',
      menuCode: 'CEK_STOK',
      icon: Icons.search,
      page: const StockCheckPage(),
    ),
    DashboardMenuItem(
      title: 'Terima Barang',
      menuCode: 'TERIMA_BARANG',
      icon: Icons.inventory,
      page: const TerimaBarangMainPage(),
    ),
    DashboardMenuItem(
      title: 'Stock Opname',
      menuCode: 'STOCK_OPNAME',
      icon: Icons.assessment,
      page: const StockOpnameListPage(),
    ),
    DashboardMenuItem(
      title: 'Work Order',
      menuCode: 'WORK_ORDER',
      icon: Icons.work,
      page: const WorkOrderPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvailableMenus();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Admin';
    });
  }

  Future<void> _loadAvailableMenus() async {
    setState(() => _isLoading = true);

    List<DashboardMenuItem> availableMenus = [];

    // Check setiap menu apakah user punya akses
    for (var menuItem in _allMenuItems) {
      final hasAccess = await PermissionService.hasMenuAccess(menuItem.menuCode);
      if (hasAccess) {
        availableMenus.add(menuItem);
      }
    }

    setState(() {
      _availableMenuItems = availableMenus;
      _isLoading = false;
    });

    // Jika tidak ada menu yang tersedia, tampilkan pesan
    if (_availableMenuItems.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak memiliki akses ke menu apapun'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user confirms logout
    if (shouldLogout == true) {
      await PermissionService.clearPermissions(); // Clear permissions
      await AuthHelper.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_availableMenuItems.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('SHN Mobile'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'Tidak ada menu yang tersedia',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_availableMenuItems[selectedIndex].title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'SHN Mobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inventory Management System',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, $username',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items - Hanya tampilkan menu yang user punya akses
            Expanded(
              child: ListView.builder(
                itemCount: _availableMenuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = _availableMenuItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      selected: selectedIndex == index,
                      selectedTileColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        menuItem.icon,
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                      title: Text(
                        menuItem.title,
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.grey[400],
                          fontWeight: selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: _availableMenuItems[selectedIndex].page,
    );
  }
}

// Dashboard Content Widget
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isLoading = false;
  String? _errorMessage;

  // General stats
  int _totalJumlahPo = 0;
  double _totalRupiahPo = 0.0;
  double _totalAr = 0.0;
  double _totalAp = 0.0;

  // Daily data
  List<Map<String, dynamic>> _salesOrderData = [];
  List<Map<String, dynamic>> _workOrderPlanningData = [];
  List<Map<String, dynamic>> _workOrderActualData = [];
  List<Map<String, dynamic>> _purchaseOrderData = [];

  // Date range
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, 1);
    _dateTo = now;
    _loadDashboardData();
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (_dateFrom != null) {
        queryParams['date_from'] = _formatDate(_dateFrom);
      }
      if (_dateTo != null) {
        queryParams['date_to'] = _formatDate(_dateTo);
      }

      // Fetch all dashboard data in parallel
      await Future.wait([
        _fetchGeneralStats(baseUrl, token, queryParams),
        _fetchSalesOrder(baseUrl, token, queryParams),
        _fetchWorkOrderPlanning(baseUrl, token, queryParams),
        _fetchWorkOrderActual(baseUrl, token, queryParams),
        _fetchPurchaseOrder(baseUrl, token, queryParams),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      
      if (mounted && _errorMessage?.contains('401') == true) {
        await AuthHelper.handleUnauthorized(context, null);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchGeneralStats(String baseUrl, String token, Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/api/dashboard/general').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final data = jsonData['data'] as Map<String, dynamic>;
        setState(() {
          _totalJumlahPo = _parseToInt(data['total_jumlah_po']);
          _totalRupiahPo = _parseToDouble(data['total_rupiah_po']);
          _totalAr = _parseToDouble(data['total_ar']);
          _totalAp = _parseToDouble(data['total_ap']);
        });
      }
    } else if (response.statusCode == 401) {
      throw Exception('401');
    }
  }

  Future<void> _fetchSalesOrder(String baseUrl, String token, Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/api/dashboard/sales-order').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;
      setState(() {
        _salesOrderData = jsonData.map((item) => item as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 401) {
      throw Exception('401');
    }
  }

  Future<void> _fetchWorkOrderPlanning(String baseUrl, String token, Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/api/dashboard/work-order-planning').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;
      setState(() {
        _workOrderPlanningData = jsonData.map((item) => item as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 401) {
      throw Exception('401');
    }
  }

  Future<void> _fetchWorkOrderActual(String baseUrl, String token, Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/api/dashboard/work-order-actual').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;
      setState(() {
        _workOrderActualData = jsonData.map((item) => item as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 401) {
      throw Exception('401');
    }
  }

  Future<void> _fetchPurchaseOrder(String baseUrl, String token, Map<String, String> queryParams) async {
    final uri = Uri.parse('$baseUrl/api/dashboard/purchase-order').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;
      setState(() {
        _purchaseOrderData = jsonData.map((item) => item as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 401) {
      throw Exception('401');
    }
  }

  String _formatCurrency(double value) {
    // Format with Indonesian locale (dot as thousand separator)
    final formatter = NumberFormat('#,##0', 'id_ID');
    
    if (value >= 1000000000) {
      final billions = value / 1000000000;
      // For billions, show with 1 decimal if < 10, otherwise no decimal
      final formatted = billions >= 10 
          ? billions.toStringAsFixed(0)
          : billions.toStringAsFixed(1);
      return '$formatted M';
    } else if (value >= 1000000) {
      final millions = value / 1000000;
      // For millions, show with 1 decimal if < 10, otherwise no decimal
      final formatted = millions >= 10
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1);
      return '$formatted JT';
    } else if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(1)} RB';
    }
    return formatter.format(value.toInt());
  }
  
  String _formatNumber(int value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(value);
  }

  // Helper methods to safely parse values that might be String or num
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _totalJumlahPo == 0) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _totalJumlahPo == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Statistik Umum & Aktivitas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Range Picker
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
                  'Periode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Dari Tanggal',
                        value: _dateFrom,
                        onDateSelected: (date) {
                          setState(() {
                            _dateFrom = date;
                          });
                          if (date != null) {
                            _loadDashboardData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Sampai Tanggal',
                        value: _dateTo,
                        onDateSelected: (date) {
                          setState(() {
                            _dateTo = date;
                          });
                          if (date != null) {
                            _loadDashboardData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Memuat data...',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // General Stats
          const Text(
            'Statistik Umum',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // Grid layout for better spacing
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Jumlah PO',
                      _formatNumber(_totalJumlahPo),
                      Icons.shopping_cart_outlined,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Rupiah PO',
                      'Rp ${_formatCurrency(_totalRupiahPo)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Accounts Receivable',
                      'Rp ${_formatCurrency(_totalAr)}',
                      Icons.account_balance_wallet_outlined,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Accounts Payable',
                      'Rp ${_formatCurrency(_totalAp)}',
                      Icons.payment_outlined,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sales Order Chart
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
                  'Sales Order per Hari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDailyChart(_salesOrderData, 'Sales Order', Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Purchase Order Chart
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
                  'Purchase Order per Hari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDailyChart(_purchaseOrderData, 'Purchase Order', Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Work Order Planning Chart
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
                  'Work Order Planning per Hari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDailyChart(_workOrderPlanningData, 'Work Order Planning', Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Work Order Actual Chart
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
                  'Work Order Actual per Hari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDailyChart(_workOrderActualData, 'Work Order Actual', Colors.purple),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onDateSelected,
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
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      surface: Colors.grey[900]!,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.grey[900],
                  ),
                  child: child!,
                );
              },
            );
            onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Pilih tanggal',
                  style: TextStyle(
                    color: value != null ? Colors.white : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }



  Widget _buildDailyChart(List<Map<String, dynamic>> data, String title, Color color) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data untuk ditampilkan',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      );
    }

    // Calculate max value for Y axis
    double maxValue = 0;
    for (var item in data) {
      final total = _parseToDouble(item['total']);
      maxValue = maxValue < total ? total : maxValue;
    }
    maxValue = maxValue * 1.2; // Add 20% padding
    if (maxValue == 0) maxValue = 10; // Minimum max value

    // Sort data by date to ensure proper ordering
    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      final dateA = _parseDate(a);
      final dateB = _parseDate(b);
      return dateA.compareTo(dateB);
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey[900]!,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = sortedData[group.x.toInt()]['day'] ?? '';
              final month = sortedData[group.x.toInt()]['month'] ?? '';
              final total = _parseToInt(sortedData[group.x.toInt()]['total']);
              return BarTooltipItem(
                '$day $month: $total',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedData.length) {
                  final day = sortedData[index]['day'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      day,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final intValue = value.toInt();
                if (intValue.isFinite && intValue >= 0) {
                  return Text(
                    intValue.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < sortedData.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: _parseToDouble(sortedData[i]['total']),
                  color: color,
                  width: sortedData.length > 30 ? 4 : 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[800]!,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  DateTime _parseDate(Map<String, dynamic> item) {
    try {
      final year = item['year'] as int? ?? DateTime.now().year;
      final monthName = item['month'] as String? ?? 'January';
      final day = int.tryParse(item['day'] as String? ?? '1') ?? 1;
      
      final monthMap = {
        'January': 1, 'February': 2, 'March': 3, 'April': 4,
        'May': 5, 'June': 6, 'July': 7, 'August': 8,
        'September': 9, 'October': 10, 'November': 11, 'December': 12,
      };
      
      final month = monthMap[monthName] ?? 1;
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now();
    }
  }
} 