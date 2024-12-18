import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay 2 giây để hiển thị Splash Screen
    Future.delayed(const Duration(seconds: 2), () {
      final securityProvider =
          Provider.of<SecurityProvider>(context, listen: false);

      // Kiểm tra trạng thái bảo mật
      if (securityProvider.isUnlocked) {
        Navigator.pushReplacementNamed(context, '/main'); // Chuyển đến MainScreen
      } else {
        Navigator.pushReplacementNamed(context, '/lock'); // Chuyển đến LockScreen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.museum,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Museum App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
