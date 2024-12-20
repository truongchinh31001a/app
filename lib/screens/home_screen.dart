import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  /// Ánh xạ ngôn ngữ từ `SecurityProvider`
  String _getTextBasedOnLanguage(String? language) {
    switch (language) {
      case 'English':
        return 'Phan Chau Trinh Medical Museum';
      case 'Vietnamese':
        return 'Bảo tàng y khoa Phan Châu Trinh';
      default:
        return 'Bảo tàng y khoa Phan Châu Trinh'; // Mặc định là tiếng Việt
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ngôn ngữ từ `SecurityProvider`
    final securityProvider = Provider.of<SecurityProvider>(context);
    final String displayText = _getTextBasedOnLanguage(securityProvider.language);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background.jpg',
              fit: BoxFit.cover, // Đảm bảo ảnh chiếm toàn bộ màn hình
            ),
          ),
          // Text on top of the background image
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.center, // Căn chỉnh văn bản vào giữa
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400, // Giới hạn kích thước nếu cần
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'RibeyeMarrow', // Sử dụng font tùy chỉnh
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
