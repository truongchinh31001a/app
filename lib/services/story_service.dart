import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryService {
  final String baseUrl = 'http://192.168.1.88:3000';

  // Hàm call API để lấy danh sách stories
  Future<List<dynamic>> fetchStories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/system/stories'));

    if (response.statusCode == 200) {
      // Giải mã nội dung từ UTF-8 để đảm bảo không bị lỗi font chữ
      final utf8DecodedBody = utf8.decode(response.bodyBytes);

      // Trả về danh sách stories từ JSON
      return json.decode(utf8DecodedBody);
    } else {
      // Ném lỗi nếu API trả về lỗi
      throw Exception('Failed to load stories');
    }
  }
}
