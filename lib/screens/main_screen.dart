
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
  bool isUnlocked = false; // Biến kiểm tra đã mở khóa hay chưa
  bool _isBottomSheetShown = false; // Tránh hiển thị BottomSheet nhiều lần

  final List<Widget> _screens = [
    HomeScreen(),
    StoryScreen(),
    QRScannerScreen(),
    MapScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Đảm bảo BottomSheet được gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isBottomSheetShown) {
        _openLockBottomSheet();
      }
    });
  }

  // Hàm mở BottomSheet yêu cầu mở khóa
  void _openLockBottomSheet() {
    _isBottomSheetShown = true; // Đánh dấu đã hiển thị BottomSheet
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Không cho phép người dùng tắt bằng cách bấm ra ngoài
      enableDrag: false, // Vô hiệu hóa kéo để đóng
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7, // Chiếm 70% chiều cao màn hình
          color: Colors.white, // Nền trắng
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bạn cần mở khóa để tiếp tục',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isUnlocked = true; // Đánh dấu đã mở khóa
                  });
                  Navigator.pop(context); // Đóng BottomSheet
                },
                child: Text('Mở Khóa'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hiển thị màn hình chính khi đã mở khóa
          if (isUnlocked) _screens[_selectedIndex],
          
          // Thanh điều hướng nằm đè lên
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  elevation: 0,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.black,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
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
