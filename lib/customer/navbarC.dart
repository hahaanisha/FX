import 'package:flutter/material.dart';
import 'AddDriver.dart';
import 'AddVehiclePage.dart';
import 'AddRoutePage.dart';
// import 'ViewOrdersPage.dart';

class Bottomnavbar extends StatefulWidget {
  final dynamic UID;

  const Bottomnavbar({super.key, required this.UID});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      AddVehiclePage(UID: widget.UID),
      AddRoutePage(UID: widget.UID),
      AddDriverPage(UID: widget.UID),
      AddRoutePage(UID: widget.UID),
      // AddDriverPage(),
      // ViewOrdersPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Welcome Team Mastek!',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car, color: Colors.white),
            label: 'Add Vehicle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Colors.white),
            label: 'Add Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add, color: Colors.white),
            label: 'Add Driver',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, color: Colors.white),
            label: 'Dispatched Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }
}
