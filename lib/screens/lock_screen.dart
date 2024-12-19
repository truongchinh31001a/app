import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../services/qr_ticket_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;
  bool _isStartVisible = true;
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(); // Khởi tạo camera
  }

  @override
  void dispose() {
    _cameraController.dispose(); // Dọn dẹp camera
    super.dispose();
  }

  /// Xử lý gọi API và trạng thái
  Future<void> _callApi(String qrCode) async {
    print('[CallAPI] Start processing QR Code: $qrCode');

    setState(() {
      _isProcessing = true;
      _isSuccess = false;
      _isStartVisible = false;
    });

    try {
      // Tắt camera ngay sau khi quét thành công
      _cameraController.stop();
      print('[CallAPI] Camera stopped.');

      // Gọi API xử lý mã QR
      final response = await QRTicketService.scanTicket(qrCode);
      print('[CallAPI] API Response: $response');

      if (response['success']) {
        print('[CallAPI] QR code is valid. Proceeding with data...');
        final data = response['data'];
        final expirationDate = DateTime.parse(data['expiration_date']);
        final visitorId = data['visitor_id'];

        if (mounted) {
          // Lưu trạng thái vào SecurityProvider
          Provider.of<SecurityProvider>(context, listen: false).unlock(
            expirationTime: expirationDate,
            visitorId: visitorId,
          );

          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });

          // Chờ hoạt ảnh success hoàn tất
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // Chuyển màn hình chính
            Navigator.pushReplacementNamed(context, '/main');
          }
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(response['message']);
        }
      }
    } catch (error, stackTrace) {
      print('[CallAPI] Error: $error');
      print('[CallAPI] StackTrace: $stackTrace');
      if (mounted) {
        _showErrorSnackBar('Error processing QR code.');
      }
    } finally {
      if (!_isSuccess && mounted) {
        // Reset trạng thái nếu thất bại
        setState(() {
          _isProcessing = false;
          _isStartVisible = true;
        });
        _cameraController.start(); // Bật lại camera nếu cần
      }
    }
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Hiển thị giao diện quét QR
  Widget _buildQRScannerBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // Bottom sheet chiếm 50% chiều cao
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Scan your QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 250, // Thu nhỏ kích thước vùng quét
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4), // Viền đen
                    borderRadius: BorderRadius.circular(10), // Bo tròn góc
                  ),
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: (BarcodeCapture capture) {
                      final qrCode = capture.barcodes.first.rawValue;
                      print('[QR Scanner] QR code detected: $qrCode');
                      if (qrCode != null) {
                        Navigator.pop(context); // Đóng bottom sheet
                        _callApi(qrCode); // Gọi xử lý mã QR
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Align the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          // Nút đóng (X)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Đóng bottom sheet
              },
              child: const Icon(
                Icons.close,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 60.0, bottom: 30.0),
                  child: Text(
                    'Welcome to the Museum',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C1B0B),
                    ),
                  ),
                ),
                const Spacer(),
                if (_isStartVisible)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          enableDrag: false,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _buildQRScannerBottomSheet(),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 40.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8C1B0B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.navigate_next,
                          color: Color(0xFFF6FDFB),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(), // Hiển thị loading ở giữa
            ),
          if (_isSuccess)
            Center(
              child: Lottie.asset(
                'assets/animations/success.json', // Hiển thị success animation ở giữa
                width: 150,
                height: 150,
              ),
            ),
        ],
      ),
    );
  }
}
