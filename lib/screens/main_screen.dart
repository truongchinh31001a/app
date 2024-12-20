import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/right_sheet.dart';
import '../providers/security_provider.dart';
import '../widgets/bottom_navbar_widget.dart';
import '../screens/home_screen.dart';
import '../screens/story_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/map_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    StoryScreen(),
    QRScannerScreen(),
    MapScreen(),
    Placeholder(), // RightSheet sẽ được mở thay vì màn hình này
  ];

  void _showRightSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.centerRight,
          child: RightSheet(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // Thanh điều hướng dưới cùng
          CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              if (index == 4) {
                _showRightSheet(context); // Mở Right Sheet
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
