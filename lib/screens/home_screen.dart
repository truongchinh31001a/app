// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                // Đặt một container để đảm bảo kích thước
                constraints: const BoxConstraints(
                  maxWidth: 400, // Giới hạn kích thước nếu cần
                ),
                child: Text(
                  'Bảo tàng y khoa Phan Châu Trinh',
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
