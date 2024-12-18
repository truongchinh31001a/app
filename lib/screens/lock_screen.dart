import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/security_provider.dart';
import '../services/qr_ticket_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false; // Trạng thái xử lý API
  bool _isSuccess = false; // Trạng thái quét thành công
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _callApi(String qrCode) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await QRTicketService.scanTicket(qrCode);

      if (response['success']) {
        final data = response['data'];
        final expirationDate = DateTime.parse(data['expiration_date']);
        final visitorId = data['visitor_id'];

        // Cập nhật trạng thái thành công
        setState(() {
          _isSuccess = true;
        });

        // Bắt đầu animation
        _animationController.forward();

        // Cập nhật SecurityProvider
        Provider.of<SecurityProvider>(context, listen: false).unlock(
          expirationTime: expirationDate,
          visitorId: visitorId,
        );

        // Chờ 1 giây để hoàn tất animation rồi điều hướng
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _showErrorSnackBar(response['message']);
      }
    } catch (error) {
      _showErrorSnackBar('Error scanning QR code');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Camera QR Scanner
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (_isProcessing || _isSuccess) return;
              final qrCode = capture.barcodes.first.rawValue;

              if (qrCode != null) {
                _callApi(qrCode);
              }
            },
          ),

          // Overlay làm mờ xung quanh vùng quét và khung quét
          Positioned.fill(
            child: Stack(
              children: [
                // Làm mờ bên ngoài khung quét
                _buildScanOverlay(),
                // Khung quét với 4 góc màu trắng
                Center(
                  child: Stack(
                    children: [
                      // 4 góc của khung quét
                      _buildCornerDecorations(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator khi đang xử lý
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Dấu tick thành công
          if (_isSuccess)
            Center(
              child: ScaleTransition(
                scale: _animationController.drive(
                  Tween<double>(begin: 0.0, end: 1.0),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 120,
                  color: Colors.green,
                ),
              ),
            ),

          // Hướng dẫn sử dụng
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Text(
              'Di chuyển mã QR vào khung để quét',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
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
        border: Border.all(color: Colors.transparent), // Không hiển thị border tổng thể
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
}
