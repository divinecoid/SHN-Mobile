import 'package:flutter/material.dart';
import 'package:shn_mobile/controllers/home_controller.dart';
import 'package:shn_mobile/pages/terima_barang_main_page.dart';
import 'package:shn_mobile/pages/page_stock_opname.dart';
import 'package:shn_mobile/pages/stock_opname_list_page.dart';
import 'package:shn_mobile/pages/page_work_order.dart';
import 'package:shn_mobile/services/permission_service.dart';

class MenuItem {
  final String title;
  final String menuCode;
  final IconData icon;
  final Widget page;

  MenuItem({
    required this.title,
    required this.menuCode,
    required this.icon,
    required this.page,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<MenuItem> _availableMenuItems = [];

  // Semua menu yang tersedia di mobile app
  final List<MenuItem> _allMenuItems = [
    MenuItem(
      title: 'Terima Barang',
      menuCode: 'TERIMA_BARANG',
      icon: Icons.inventory,
      page: const TerimaBarangMainPage(),
    ),
    MenuItem(
      title: 'Stock Opname',
      menuCode: 'STOCK_OPNAME',
      icon: Icons.assessment,
      page: const StockOpnameListPage(),
    ),
    MenuItem(
      title: 'Work Order',
      menuCode: 'WORK_ORDER',
      icon: Icons.work,
      page: const WorkOrderPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableMenus();
  }

  Future<void> _loadAvailableMenus() async {
    setState(() => _isLoading = true);

    List<MenuItem> availableMenus = [];

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
        title: Text(_availableMenuItems[_selectedIndex].title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'SHN Mobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Inventory Management System',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
                      selected: _selectedIndex == index,
                      selectedTileColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        menuItem.icon,
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                      title: Text(
                        menuItem.title,
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.grey[400],
                          fontWeight: _selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
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
      body: _availableMenuItems[_selectedIndex].page,
    );
  }
}
 