import 'package:flutter/material.dart';
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
  int _selectedIndex = 0; // Chỉ số của tab hiện tại

  // Danh sách các màn hình
  final List<Widget> _screens = [
    HomeScreen(),
    StoryScreen(),
    QRScannerScreen(),
    MapScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Màn hình hiện tại
          _screens[_selectedIndex],

          // Thanh điều hướng nằm đè lên
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white, // Nền trắng
                borderRadius: BorderRadius.circular(30), // Bo góc
                border: Border.all(
                  color: Colors.grey.shade300, // Màu viền
                  width: 1, // Độ dày viền
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Bo góc
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex =
                          index; // Cập nhật chỉ số khi người dùng chọn tab
                    });
                  },
                  elevation: 0, // Loại bỏ bóng
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.blue, // Màu mục đã chọn
                  unselectedItemColor: Colors.black, // Màu mục chưa chọn
                  selectedFontSize: 0, // Ẩn nhãn
                  unselectedFontSize: 0, // Ẩn nhãn
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/home.png',
                        width: 24,
                        height: 24,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/story.png',
                        width: 24,
                        height: 24,
                      ),
                      label: 'Story',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedIndex == 2
                              ? Colors.blue
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/icons/qr_code.png',
                            color: Colors.white,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      label: 'Scanner',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/map.png',
                        width: 24,
                        height: 24,
                      ),
                      label: 'Map',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/history.png',
                        width: 24,
                        height: 24,
                      ),
                      label: 'History',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
