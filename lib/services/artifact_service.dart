import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/artifact.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api-endpoint.com';

  // Hàm gọi API để lấy dữ liệu artifact từ QR code
  static Future<Artifact> fetchArtifactFromApi(String qrCode) async {
    final response = await http.get(Uri.parse('$_baseUrl/artifacts?qr_code=$qrCode'));

    if (response.statusCode == 200) {
      // Parse và trả về đối tượng Artifact
      return Artifact.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load artifact');
    }
  }
}
