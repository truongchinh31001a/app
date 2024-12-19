import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  final String highlightPointsApiUrl = 'http://192.168.1.86:3000/api/app/exhibit';
  final String mapsApiUrl = 'http://192.168.1.86:3000/api/app/map';

  Future<List<Map<String, dynamic>>> fetchHighlightPoints() async {
    final response = await http.get(Uri.parse(highlightPointsApiUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch highlight points');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMaps() async {
    final response = await http.get(Uri.parse(mapsApiUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch maps');
    }
  }
}
