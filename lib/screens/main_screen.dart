import 'package:app/providers/artifact_provider.dart';
import 'package:app/providers/story_provider.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/map_screen.dart';
import 'package:app/screens/qr_scanner_screen.dart';
import 'package:app/screens/story_screen.dart';
import 'package:app/widgets/bottom_navbar_widget.dart';
import 'package:app/widgets/mini_control_widget.dart';
import 'package:app/widgets/right_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
    Future.microtask(() {
      final artifactProvider = Provider.of<ArtifactProvider>(context, listen: false);
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      artifactProvider.fetchAllArtifacts(); // Gọi API tải tất cả Artifact
      storyProvider.fetchStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final artifactProvider = Provider.of<ArtifactProvider>(context);

    return Scaffold(
      body: artifactProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị khi đang tải dữ liệu
          : Stack(
              children: [
                // Hiển thị màn hình hiện tại
                _screens[_selectedIndex],

                // MiniControl hiển thị trên BottomNavBar
                Positioned(
                  bottom: 70,
                  left: 16,
                  right: 16,
                  child: MiniControl(),
                ),

                // Thanh điều hướng dưới cùng
                CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onTap: (index) {
                    if (index == 4) {
                      _showRightSheet(context); // Mở RightSheet
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
