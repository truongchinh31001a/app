import 'dart:async';
import 'package:app/screens/lock_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../screens/history_screen.dart';

class RightSheet extends StatefulWidget {
  const RightSheet({Key? key}) : super(key: key);

  @override
  _RightSheetState createState() => _RightSheetState();
}

class _RightSheetState extends State<RightSheet> {
  late Timer _timer;
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final securityProvider =
        Provider.of<SecurityProvider>(context, listen: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final expirationTime = securityProvider.expirationTime;

      if (expirationTime != null) {
        final remainingDuration = expirationTime.difference(DateTime.now());

        if (remainingDuration.isNegative) {
          securityProvider.lock();
          timer.cancel();
        } else {
          setState(() {
            _timeLeft = _formatDuration(remainingDuration);
          });
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white, // Đặt màu nền trắng
          title: const Text(
            'Confirm Logout',
            style: TextStyle(color: Colors.black), // Đặt màu chữ
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.black), // Đặt màu chữ
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Đóng dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng dialog
                final securityProvider =
                    Provider.of<SecurityProvider>(context, listen: false);
                await securityProvider.reset();
                Navigator.of(context).pop(); // Đóng RightSheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LockScreen(),
                    settings: const RouteSettings(arguments: 'logout'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    return FractionallySizedBox(
      widthFactor: 0.7,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(0)),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Thời gian còn lại
            ListTile(
              leading: Image.asset(
                'assets/icons/key.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Time Left'),
              subtitle: Text(_timeLeft.isNotEmpty ? _timeLeft : 'Loading...'),
            ),

            // Mở HistoryScreen
            ListTile(
              leading: Image.asset(
                'assets/icons/history.png',
                width: 24,
                height: 24,
              ),
              title: const Text('View History'),
              onTap: () {
                Navigator.of(context).pop(); // Đóng RightSheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),

            // Đăng xuất
            ListTile(
              leading: Image.asset(
                'assets/icons/send.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Logout'),
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}
