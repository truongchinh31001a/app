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
  bool _isLogout = false;
  bool _isStartVisible = true;
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(); // Khởi tạo camera
  }

  /// Sử dụng phương thức didChangeDependencies để xử lý logic liên quan đến Provider
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Nếu cần xử lý logic đặc biệt khi logout, sử dụng arguments
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args == 'logout') {
      handleLogout(); // Gọi hàm xử lý logout
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  /// Xử lý trạng thái logout
  Future<void> handleLogout() async {
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
      _isLogout = true; // Đặt trạng thái logout
      _isStartVisible = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLogout = false;
        _isSuccess = false;
        _isStartVisible = true; // Hiển thị lại giao diện ban đầu
      });
    }
  }

  /// Xử lý gọi API và trạng thái
  Future<void> _callApi(String qrCode) async {
    setState(() {
      _isProcessing = true;
      _isSuccess = false;
      _isStartVisible = false;
      _isLogout = false;
    });

    try {
      _cameraController.stop();

      final response = await QRTicketService.scanTicket(qrCode);
      if (response['success']) {
        final data = response['data'];
        final expirationDate = DateTime.parse(data['expiration_date']);
        final visitorId = data['visitor_id'];
        final language = data['language'];

        if (mounted) {
          Provider.of<SecurityProvider>(context, listen: false).unlock(
            expirationTime: expirationDate,
            visitorId: visitorId,
            language: language,
          );

          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/main');
          }
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(response['message']);
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('Error processing QR code.');
      }
    } finally {
      if (!_isSuccess && mounted) {
        setState(() {
          _isProcessing = false;
          _isStartVisible = true;
        });
        _cameraController.start();
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
      height: MediaQuery.of(context).size.height * 0.5,
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
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: (BarcodeCapture capture) {
                      final qrCode = capture.barcodes.first.rawValue;
                      if (qrCode != null) {
                        Navigator.pop(context);
                        _callApi(qrCode);
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
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
          if (_isStartVisible || _isProcessing || !_isLogout)
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
              child: CircularProgressIndicator(),
            ),
          if (_isSuccess)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/success.json',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogout ? 'Thank you!' : 'Success',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
