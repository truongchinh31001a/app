import 'dart:convert';
import 'package:app/models/artifact.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Hàm gọi API để lấy dữ liệu Artifact
  static Future<Artifact> fetchArtifactFromApi(String qrCode) async {
    final response = await http.get(Uri.parse('https://example.com/api/artifacts/$qrCode'));

    if (response.statusCode == 200) {
      // Nếu thành công, trả về Artifact từ JSON
      return Artifact.fromJson(json.decode(response.body));
    } else {
      throw Exception('Không thể tải dữ liệu từ server');
    }
  }
}
