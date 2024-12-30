import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtifactLogService {
  final String baseUrl = 'http://192.168.1.88:3000/api/app';

  /// Lưu Artifact Scan Log
  Future<void> logArtifactScan({
    required int artifactId,
    required int visitorId,
  }) async {
    final url = Uri.parse('$baseUrl/artifact_log/$artifactId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'visitor_id': visitorId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Artifact scan log saved successfully');
      } else {
        throw Exception(
          'Failed to save artifact scan log. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error logging artifact scan: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLogsByVisitorId(int visitorId) async {
    final url = Uri.parse('$baseUrl/history/$visitorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode JSON thành danh sách
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((log) => log as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        return []; // Không có log nào
      } else {
        throw Exception('Failed to fetch logs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching logs: $e');
      throw Exception('Error fetching logs: $e');
    }
  }
}
