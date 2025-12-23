import 'package:flutter/material.dart';
import 'penerimaan_barang_list_page.dart';
import 'input_penerimaan_barang_page.dart';
import '../services/permission_service.dart';

class TerimaBarangMainPage extends StatefulWidget {
  const TerimaBarangMainPage({super.key});

  @override
  State<TerimaBarangMainPage> createState() => _TerimaBarangMainPageState();
}

class _TerimaBarangMainPageState extends State<TerimaBarangMainPage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasCreatePermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasCreate = await PermissionService.hasPermission('TERIMA_BARANG', 'Create');
    setState(() {
      _hasCreatePermission = hasCreate;
      _isLoading = false;
    });
  }

  List<Widget> get _pages => _hasCreatePermission
      ? [
          const PenerimaanBarangListPage(),
          InputPenerimaanBarangPage(
            onSuccess: () {
              setState(() {
                _currentIndex = 0; // Switch to list page
              });
            },
          ),
        ]
      : [
          const PenerimaanBarangListPage(),
        ];

  List<BottomNavigationBarItem> get _navItems => _hasCreatePermission
      ? const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Input',
          ),
        ]
      : const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Daftar',
          ),
        ];

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _navItems.length > 1
          ? BottomNavigationBar(
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.blue[400],
              unselectedItemColor: Colors.grey[400],
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: _navItems,
            )
          : null, // Hide navigation bar if only one tab
    );
  }
}
