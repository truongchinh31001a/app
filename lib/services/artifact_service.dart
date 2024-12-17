import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artifact.dart';

class ArtifactService {
  final String baseUrl = 'http://192.168.1.86:3000/api/app';

  Future<Artifact?> fetchArtifactByQRCode(String qrCode) async {
    final response = await http.get(Uri.parse('$baseUrl/artifacts?qr_code=$qrCode'));

    if (response.statusCode == 200) {
      try {

        // Trường hợp chuỗi JSON bị lồng vào dạng String
        final jsonData = response.body.startsWith('{')
            ? json.decode(response.body) // JSON hợp lệ
            : json.decode(json.decode(response.body)); // JSON lồng String

        // Kiểm tra dữ liệu có đúng dạng Map không
        if (jsonData is Map<String, dynamic>) {
          return Artifact.fromJson(jsonData);
        } else {
          throw Exception("Invalid response format: Expected Map but got ${jsonData.runtimeType}");
        }
      } catch (e) {
        throw Exception("Error decoding JSON: $e");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }
}
