import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../services/qr_ticket_service.dart';

enum LockScreenState { idle, processing, success }

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  LockScreenState _state = LockScreenState.idle;
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _callApi(String qrCode) async {
    setState(() {
      _state = LockScreenState.processing;
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
            _state = LockScreenState.success;
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
      if (_state == LockScreenState.processing && mounted) {
        setState(() {
          _state = LockScreenState.idle;
        });
        _cameraController.start();
      }
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
                        Navigator.pop(context); // Đóng bottom sheet
                        _callApi(qrCode); // Gọi API xử lý
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Trạng thái "Idle" luôn hiện giao diện chính
          if (_state == LockScreenState.idle || _state == LockScreenState.processing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 60.0, bottom: 10.0),
                    child: Text(
                      'APOLLO MEDICAL MUSEUM',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C1B0B),
                      ),
                    ),
                  ),
                  Text(
                    'welcome',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 4,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C1B0B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
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
          if (_state == LockScreenState.processing)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_state == LockScreenState.success)
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
                  const Text(
                    'Success',
                    style: TextStyle(
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
