import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import thư viện intl
import '../providers/security_provider.dart';
import '../providers/artifact_provider.dart'; // Import ArtifactProvider
import '../services/artifact_log_service.dart';
import '../services/artifact_service.dart';
import 'detail_artifact_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ArtifactLogService artifactLogService = ArtifactLogService();
  final ArtifactService artifactService = ArtifactService();

  List<Map<String, dynamic>> artifactLogs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  /// Lấy lịch sử quét Artifact và thông tin chi tiết
  Future<void> fetchHistory() async {
    try {
      final securityProvider =
          Provider.of<SecurityProvider>(context, listen: false);

      // Lấy visitor_id và language từ SecurityProvider
      final visitorId = securityProvider.visitorId;
      final languageKey =
          (securityProvider.language ?? 'Vietnamese') == 'English'
              ? 'en'
              : 'vi';

      if (visitorId == null) {
        throw Exception(languageKey == 'en'
            ? 'Visitor ID is not available'
            : 'Không có Visitor ID');
      }

      // Lấy danh sách ArtifactScanLogs từ ArtifactLogService
      final logs = await artifactLogService.fetchLogsByVisitorId(visitorId);

      // Lấy chi tiết Artifact cho mỗi log
      final List<Map<String, dynamic>> detailedLogs = [];
      for (var log in logs) {
        final artifactId = log['artifact_id'];
        final scanTime = log['scan_time'];

        final artifact = await artifactService.fetchArtifactById(artifactId);
        detailedLogs.add({
          'artifact': artifact,
          'scan_time': scanTime,
          'languageKey': languageKey,
        });
      }

      if (!mounted) return; // Kiểm tra widget còn gắn vào widget tree
      setState(() {
        artifactLogs = detailedLogs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Kiểm tra widget còn gắn vào widget tree
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Định dạng thời gian quét
  String _formatScanTime(String scanTime) {
    try {
      final dateTime =
          DateTime.parse(scanTime).toLocal(); // Chuyển sang local time
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return scanTime; // Trả về chuỗi gốc nếu lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);
    final languageKey =
        (securityProvider.language ?? 'Vietnamese') == 'English' ? 'en' : 'vi';

    // Text hiển thị dựa trên ngôn ngữ
    final String titleText = languageKey == 'en' ? 'History' : 'Lịch sử';
    final String noHistoryText =
        languageKey == 'en' ? 'No history available.' : 'Không có lịch sử.';
    final String errorText = languageKey == 'en' ? 'Error' : 'Lỗi';
    final String scannedOnText =
        languageKey == 'en' ? 'Scanned on:' : 'Quét vào lúc:';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.white, // Đặt màu nền AppBar thành trắng
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Màu nút back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Nút quay lại
          },
        ),
      ),
      backgroundColor: Colors.white, // Màu nền toàn bộ màn hình
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('$errorText: $errorMessage'))
              : artifactLogs.isEmpty
                  ? Center(child: Text(noHistoryText))
                  : ListView.builder(
                      itemCount: artifactLogs.length,
                      itemBuilder: (context, index) {
                        final log = artifactLogs[index];
                        final artifact = log['artifact'];
                        final scanTime = log['scan_time'];

                        return ListTile(
                          leading: artifact['image_url'] != null
                              ? Image.network(
                                  'http://192.168.1.44:3000${artifact['image_url']}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                          title: Text(
                            artifact['name_${log['languageKey']}'] ??
                                artifact['name'] ??
                                (languageKey == 'en'
                                    ? 'Unknown Artifact'
                                    : 'Hiện vật không xác định'),
                          ),
                          subtitle: Text(
                              '$scannedOnText ${_formatScanTime(scanTime)}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Sử dụng ArtifactProvider để lưu artifact hiện tại
                            Provider.of<ArtifactProvider>(context,
                                    listen: false)
                                .setCurrentArtifact(artifact);

                            // Điều hướng sang ArtifactDetailScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ArtifactDetailScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
