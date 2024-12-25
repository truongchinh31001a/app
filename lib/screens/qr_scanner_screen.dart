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
      body: Stack(
        children: [
          // Camera QR Scanner
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              if (_isProcessing) return;

              final qrCode = capture.barcodes.first.rawValue;
              if (qrCode != null) {
                setState(() => _isProcessing = true);
                print('[QR Scanner] Detected QR Code: $qrCode');

                try {
                  // Lưu QR Code vào ArtifactProvider
                  final artifactProvider =
                      Provider.of<ArtifactProvider>(context, listen: false);
                  artifactProvider.setCurrentQrCode(qrCode);

                  // Điều hướng đến ArtifactDetailScreen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArtifactDetailScreen(),
                    ),
                  );
                } catch (e) {
                  print('[QR Scanner] Error: $e');
                  _showErrorSnackBar(context, 'Lỗi khi quét mã: $e');
                } finally {
                  // Reset trạng thái để cho phép quét lần sau
                  if (mounted) {
                    setState(() => _isProcessing = false);
                  }
                }
              } else {
                print('[QR Scanner] QR Code is null.');
              }
            },
          ),

          // Overlay làm mờ xung quanh vùng quét
          Positioned.fill(
            child: Stack(
              children: [
                _buildScanOverlay(),
                Center(
                  child: Stack(
                    children: [
                      // Animation thanh sáng di chuyển
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, _animation.value * 2 - 1),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 3,
                                color: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ),
                      // 4 góc của khung quét
                      _buildCornerDecorations(),
                    ],
                  ),
                ),
              ],
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

  // Tạo overlay làm mờ xung quanh khung quét
  Widget _buildScanOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          color: Colors.transparent, // Vùng khung quét không bị làm mờ
        ),
      ),
    );
  }

  // Tạo 4 góc cho khung quét
  Widget _buildCornerDecorations() {
    const double cornerSize = 20;
    const double borderWidth = 4;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.transparent), // Không hiển thị border tổng thể
      ),
      child: Stack(
        children: [
          // Góc trên trái
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: cornerSize,
              height: borderWidth,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: borderWidth,
              height: cornerSize,
              color: Colors.white,
            ),
          ),
          // Góc trên phải
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerSize,
              height: borderWidth,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: borderWidth,
              height: cornerSize,
              color: Colors.white,
            ),
          ),
          // Góc dưới trái
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerSize,
              height: borderWidth,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: borderWidth,
              height: cornerSize,
              color: Colors.white,
            ),
          ),
          // Góc dưới phải
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: cornerSize,
              height: borderWidth,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: borderWidth,
              height: cornerSize,
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
