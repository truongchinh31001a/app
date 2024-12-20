import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  final String highlightPointsApiUrl =
      'http://192.168.1.86:3000/api/app/exhibit';
  final String mapsApiUrl = 'http://192.168.1.86:3000/api/app/map';

  /// Lấy các điểm nổi bật
  Future<List<Map<String, dynamic>>> fetchHighlightPoints() async {
    final response = await http.get(Uri.parse(highlightPointsApiUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(json.decode(decodedBody));
    } else {
      throw Exception('Failed to fetch highlight points');
    }
  }

  /// Lấy danh sách bản đồ
  Future<List<Map<String, dynamic>>> fetchMaps() async {
    final response = await http.get(Uri.parse(mapsApiUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(json.decode(decodedBody));
    } else {
      throw Exception('Failed to fetch maps');
    }
  }

  /// Lấy thông tin chi tiết của một khu vực theo `areaId`
  Future<List<dynamic>> fetchAreaDetails(int areaId) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.86:3000/api/app/artifacts/$areaId'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return json.decode(decodedBody);
    } else {
      throw Exception('Failed to fetch area details');
    }
  }
}
