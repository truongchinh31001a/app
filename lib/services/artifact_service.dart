import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artifact.dart';

class ArtifactService {
  final String baseUrl = 'http://192.168.1.4:3000/api/app';

  /// Lấy Artifact theo QR Code
  Future<Artifact?> fetchArtifactByQRCode(String qrCode) async {
    final response =
        await http.get(Uri.parse('$baseUrl/artifacts?qr_code=$qrCode'));

    if (response.statusCode == 200) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonData = decodedBody.startsWith('{')
            ? json.decode(decodedBody)
            : json.decode(json.decode(decodedBody));

        if (jsonData is Map<String, dynamic>) {
          return Artifact.fromJson(jsonData);
        } else {
          throw Exception(
              "Invalid response format: Expected Map but got ${jsonData.runtimeType}");
        }
      } catch (e) {
        throw Exception("Error decoding JSON: $e");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }

  /// Lấy danh sách Artifacts theo Area ID
  Future<List<dynamic>> fetchArtifactsByAreaId(int areaId) async {
    final url = Uri.parse('$baseUrl/artifacts/$areaId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        return data as List<dynamic>;
      } else {
        print('Error fetching artifacts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching artifacts: $e');
      return [];
    }
  }

  /// Lấy Artifact theo ID
  Future<Map<String, dynamic>> fetchArtifactById(int artifactId) async {
    final url = Uri.parse('$baseUrl/history/artifact/$artifactId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception(
              'Unexpected response format: Expected a Map but got ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to fetch artifact. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching artifact: $e');
      throw Exception('Error fetching artifact: $e');
    }
  }

  /// Lấy toàn bộ danh sách Artifacts
  Future<List<Artifact>> fetchAllArtifacts() async {
    final url =
        Uri.parse('$baseUrl/allartifact'); // URL API để lấy toàn bộ artifacts

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        if (data is List) {
          return data.map((item) => Artifact.fromJson(item)).toList();
        } else {
          throw Exception(
              'Unexpected response format: Expected a List but got ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to fetch all artifacts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all artifacts: $e');
      throw Exception('Error fetching all artifacts: $e');
    }
  }
}
