import 'dart:convert';
import 'package:http/http.dart' as http;

class QRTicketService {
  static const String baseUrl = 'http://192.168.1.4:3000/api/system/tickets';

  // Gọi API để quét vé
  static Future<Map<String, dynamic>> scanTicket(String qrCode) async {
    final url = Uri.parse('$baseUrl/$qrCode');
    print('Request URL: $url');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Invalid ticket';
        return {'success': false, 'message': message};
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Error connecting to server: $error'
      };
    }
  }
}
