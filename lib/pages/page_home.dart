import 'package:flutter/material.dart';
import 'package:shn_mobile/controllers/home_controller.dart';
import 'package:shn_mobile/pages/terima_barang_main_page.dart';
import 'package:shn_mobile/pages/page_stock_opname.dart';
import 'package:shn_mobile/pages/stock_opname_list_page.dart';
import 'package:shn_mobile/pages/page_work_order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TerimaBarangMainPage(),
    const StockOpnameListPage(),
    const WorkOrderPage(),
  ];

  final List<String> _menuItems = [
    'Terima Barang',
    'Stock Opname',
    'Work Order',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex]),
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
                      selected: _selectedIndex == index,
                      selectedTileColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        _getIconForIndex(index),
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                      title: Text(
                        _menuItems[index],
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
      body: _pages[_selectedIndex],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.inventory;
      case 1:
        return Icons.assessment;
      case 2:
        return Icons.work;
      default:
        return Icons.home;
    }
  }
} 