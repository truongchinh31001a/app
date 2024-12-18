import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../widgets/bottom_navbar_widget.dart';
import 'home_screen.dart';
import 'story_screen.dart';
import 'qr_scanner_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Chỉ số màn hình hiện tại

  final List<Widget> _screens = [
    HomeScreen(),
    StoryScreen(),
    QRScannerScreen(),
    MapScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    print('MainScreen: isUnlocked=${securityProvider.isUnlocked}, visitorId=${securityProvider.visitorId}');

    return Scaffold(
      body: Stack(
        children: [
          // Nội dung của màn hình được chọn
          _screens[_selectedIndex],

          // Thanh điều hướng dưới cùng
          CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
