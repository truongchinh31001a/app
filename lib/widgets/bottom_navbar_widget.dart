import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0, // Đặt thanh điều hướng sát đáy nhưng SafeArea sẽ tự thêm padding
      child: SafeArea(
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
              currentIndex: selectedIndex,
              onTap: onTap,
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
                      color: selectedIndex == 2
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
    );
  }
}
