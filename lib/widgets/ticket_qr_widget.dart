import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../services/qr_ticket_service.dart';

class SecurityBottomSheet extends StatefulWidget {
  const SecurityBottomSheet({Key? key}) : super(key: key);

  @override
  _SecurityBottomSheetState createState() => _SecurityBottomSheetState();
}

class _SecurityBottomSheetState extends State<SecurityBottomSheet> {
  bool _isProcessing = false;

  Future<void> _callApi(String qrCode) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await QRTicketService.scanTicket(qrCode);

      if (response['success']) {
        final data = response['data'];
        final visitorId = data['visitor_id'];
        final expirationDate = DateTime.parse(data['expiration_date']);

        // Mở khóa thông qua SecurityProvider
        Provider.of<SecurityProvider>(context, listen: false).unlock(
          expirationTime: expirationDate,
          visitorId: visitorId,
        );

        print('Unlock successful, closing BottomSheet.');
        Navigator.pop(context); // Đóng BottomSheet
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quét QR để mở khóa',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    if (_isProcessing) return;
                    final qrCode = capture.barcodes.first.rawValue;
                    if (qrCode != null) {
                      _callApi(qrCode);
                    }
                  },
                ),
                if (_isProcessing)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
