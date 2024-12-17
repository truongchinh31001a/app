import 'package:app/screens/detail_artifact_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/artifact_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isProcessing = false; // Trạng thái xử lý QR Code

  @override
  void initState() {
    super.initState();

    // Controller cho animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animation tuyến tính cho thanh sáng
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR')),
      body: Stack(
        children: [
          // Camera QR Scanner
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              if (_isProcessing) return; // Ngăn gọi lại nhiều lần

              final qrCode = capture.barcodes.first.rawValue;

              if (qrCode != null) {
                setState(() {
                  _isProcessing = true; // Bắt đầu xử lý
                });

                try {
                  await Provider.of<ArtifactProvider>(context, listen: false)
                      .fetchArtifactByQRCode(qrCode);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArtifactDetailScreen(),
                    ),
                  );
                } catch (e) {
                  _showErrorSnackBar(context, 'Lỗi khi tải dữ liệu: $e');
                } finally {
                  setState(() {
                    _isProcessing = false; // Reset trạng thái nếu cần
                  });
                }
              }
            },
          ),

          // Overlay với khung quét và animation
          Center(
            child: Stack(
              children: [
                // Khung quét hình vuông
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Animation thanh sáng di chuyển
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0, _animation.value * 2 - 1),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 3,
                          color: Colors.blueAccent,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Overlay làm mờ xung quanh vùng quét
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 250,
                      color: Colors.transparent, // Vùng khung quét không bị làm mờ
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Indicator khi đang xử lý QR Code
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // Hiển thị thông báo lỗi
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
