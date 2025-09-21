import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page_login.dart';
import 'page_terima_barang.dart';
import 'page_mutasi_barang.dart';
import 'page_stock_opname.dart';
import 'page_work_order.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = 'Admin';
  int selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const TerimaBarangPage(),
    const MutasiBarangPage(),
    const StockOpnamePage(),
    const WorkOrderPage(),
  ];

  final List<String> _menuItems = [
    'Dashboard',
    'Terima Barang',
    'Mutasi Barang',
    'Stock Opname',
    'Work Order',
  ];



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Admin';
    });
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[selectedIndex]),
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
            // Menu Items
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
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
                        _getIconForIndex(index),
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                      title: Text(
                        _menuItems[index],
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
      body: _pages[selectedIndex],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.inventory;
      case 2:
        return Icons.swap_horiz;
      case 3:
        return Icons.assessment;
      case 4:
        return Icons.work;
      default:
        return Icons.home;
    }
  }


}

// Dashboard Content Widget
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for charts
    final List<Map<String, dynamic>> monthlyData = [
      {'month': 'Jan', 'in': 850, 'out': 720},
      {'month': 'Feb', 'in': 920, 'out': 780},
      {'month': 'Mar', 'in': 1100, 'out': 950},
      {'month': 'Apr', 'in': 1250, 'out': 1100},
      {'month': 'May', 'in': 1350, 'out': 1200},
      {'month': 'Jun', 'in': 1450, 'out': 1300},
    ];

    final List<Map<String, dynamic>> categoryData = [
      {'category': 'Plat Aluminium', 'value': 40, 'color': Colors.blue},
      {'category': 'Pipa Aluminium', 'value': 25, 'color': Colors.green},
      {'category': 'As Aluminium', 'value': 20, 'color': Colors.orange},
      {'category': 'Holo Aluminium', 'value': 10, 'color': Colors.purple},
      {'category': 'Lainnya', 'value': 5, 'color': Colors.red},
    ];

    final List<Map<String, dynamic>> recentActivities = [
      {
        'type': 'Masuk',
        'item': 'Plat Aluminium A1100 - 2mm x 1200mm x 2400mm',
        'quantity': 50,
        'time': '2 jam yang lalu',
        'icon': Icons.arrow_downward,
        'color': Colors.green,
      },
      {
        'type': 'Keluar',
        'item': 'Pipa Aluminium 6061 - Ø50mm x 3m',
        'quantity': 25,
        'time': '4 jam yang lalu',
        'icon': Icons.arrow_upward,
        'color': Colors.red,
      },
      {
        'type': 'Buang',
        'item': 'Plat Aluminium A3003 - 1mm x 1000mm x 2000mm',
        'quantity': 3,
        'time': '5 jam yang lalu',
        'icon': Icons.delete,
        'color': Colors.orange,
      },
      {
        'type': 'Masuk',
        'item': 'As Aluminium 7075 - Ø30mm x 2m',
        'quantity': 30,
        'time': '6 jam yang lalu',
        'icon': Icons.arrow_downward,
        'color': Colors.green,
      },
      {
        'type': 'Keluar',
        'item': 'Holo Aluminium 6063 - 40x40mm x 6m',
        'quantity': 15,
        'time': '1 hari yang lalu',
        'icon': Icons.arrow_upward,
        'color': Colors.red,
      },
    ];

    final List<Map<String, dynamic>> lowStockItems = [
      {'item': 'Plat Aluminium A1100 - 1mm x 1000mm x 2000mm', 'stock': 8, 'min': 20},
      {'item': 'Pipa Aluminium 6061 - Ø25mm x 3m', 'stock': 12, 'min': 15},
      {'item': 'As Aluminium 7075 - Ø20mm x 1.5m', 'stock': 3, 'min': 10},
      {'item': 'Holo Aluminium 6063 - 30x30mm x 6m', 'stock': 6, 'min': 8},
      {'item': 'Plat Aluminium A3003 - 2mm x 1200mm x 2400mm', 'stock': 9, 'min': 12},
      {'item': 'Pipa Aluminium 6063 - Ø40mm x 3m', 'stock': 10, 'min': 12},
      {'item': 'As Aluminium 6061 - Ø25mm x 2m', 'stock': 7, 'min': 10},
      {'item': 'Plat Aluminium A5052 - 1.5mm x 1000mm x 2000mm', 'stock': 25, 'min': 20},
      {'item': 'Pipa Aluminium 6061 - Ø60mm x 3m', 'stock': 18, 'min': 15},
      {'item': 'As Aluminium 7075 - Ø40mm x 2m', 'stock': 12, 'min': 10},
    ];

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
                  'Selamat datang!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sistem Manajemen Inventori Aluminium',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Items',
                  '1,234',
                  Icons.inventory,
                  Colors.grey[400]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  '${lowStockItems.where((item) {
                    final percentage = (item['stock'] / item['min']) * 100;
                    return percentage < 80;
                  }).length}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Month In',
                  '1,450',
                  Icons.arrow_downward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'This Month Out',
                  '1,300',
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Discarded',
                  '6',
                  Icons.delete,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Damage Rate',
                  '0.4%',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Chart
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
                  'Aktivitas Bulanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildMonthlyChart(monthlyData),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Distribution
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
                  'Distribusi Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildDonutChart(categoryData),
                ),
                const SizedBox(height: 16),
                _buildCategoryLegend(categoryData),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activities
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
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivitiesList(recentActivities),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Low Stock Items
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
                  'Stok Menipis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLowStockList(lowStockItems),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMonthlyChart(List<Map<String, dynamic>> monthlyData) {
    // Calculate max value for Y axis
    double maxValue = 0;
    for (var data in monthlyData) {
      maxValue = maxValue < data['in'] ? data['in'].toDouble() : maxValue;
      maxValue = maxValue < data['out'] ? data['out'].toDouble() : maxValue;
    }
    maxValue = maxValue * 1.2; // Add 20% padding

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  return Text(
                    monthlyData[index]['month'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final intValue = value.toInt();
                if (intValue.isFinite) {
                  return Text(
                    intValue.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < monthlyData.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthlyData[i]['in'].toDouble(),
                  color: Colors.green,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: monthlyData[i]['out'].toDouble(),
                  color: Colors.red,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(List<Map<String, dynamic>> categoryData) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryData.map((data) {
          return PieChartSectionData(
            color: data['color'],
            value: data['value'].toDouble(),
            title: '${data['value']}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryLegend(List<Map<String, dynamic>> categoryData) {
    return Column(
      children: categoryData.map((data) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: data['color'],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['category'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${data['value']}%',
                style: TextStyle(
                  color: data['color'],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitiesList(List<Map<String, dynamic>> recentActivities) {
    return Column(
      children: recentActivities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['item'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${activity['quantity']} unit - ${activity['time']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity['type'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activity['color'],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockList(List<Map<String, dynamic>> lowStockItems) {
    return Column(
      children: lowStockItems.where((item) {
        final percentage = (item['stock'] / item['min']) * 100;
        return percentage < 80; // Hanya tampilkan item dengan status LOW atau KRITIS
      }).map((item) {
        final percentage = (item['stock'] / item['min']) * 100;
        Color statusColor = Colors.orange;
        String statusText = 'LOW';
        
        if (percentage < 50) {
          statusColor = Colors.red;
          statusText = 'KRITIS';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Stok: ${item['stock']} / Min: ${item['min']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 