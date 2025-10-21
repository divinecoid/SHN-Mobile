import 'package:flutter/material.dart';
import 'penerimaan_barang_list_page.dart';
import 'input_penerimaan_barang_page.dart';

class TerimaBarangMainPage extends StatefulWidget {
  const TerimaBarangMainPage({super.key});

  @override
  State<TerimaBarangMainPage> createState() => _TerimaBarangMainPageState();
}

class _TerimaBarangMainPageState extends State<TerimaBarangMainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const PenerimaanBarangListPage(),
    InputPenerimaanBarangPage(
      onSuccess: () {
        setState(() {
          _currentIndex = 0; // Switch to list page
        });
      },
    ),
  ];

  final List<String> _titles = [
    'Daftar Penerimaan',
    'Input Penerimaan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blue[400],
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Input',
          ),
        ],
      ),
    );
  }
}
