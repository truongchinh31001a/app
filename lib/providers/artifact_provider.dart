import 'package:flutter/material.dart';
import '../models/artifact.dart';
import '../services/artifact_service.dart';

class ArtifactProvider with ChangeNotifier {
  final ArtifactService _artifactService = ArtifactService();

  Artifact? _currentArtifact;
  String? _currentQrCode;
  bool _isLoading = false;
  String? _errorMessage;
  final List<Artifact> _artifacts = []; // Danh sách Artifact

  /// Getter
  Artifact? get currentArtifact => _currentArtifact;
  String? get currentQrCode => _currentQrCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Artifact> get artifacts => List.unmodifiable(_artifacts);

  /// Lưu QR Code hiện tại
  void setCurrentQrCode(String qrCode) {
    _currentQrCode = qrCode;
    notifyListeners();
  }

  /// Đặt Artifact hiện tại
  void setCurrentArtifact(dynamic artifact) {
    if (artifact is Map<String, dynamic>) {
      _currentArtifact = Artifact.fromJson(artifact);
    } else if (artifact is Artifact) {
      _currentArtifact = artifact;
    } else {
      throw ArgumentError('Invalid artifact type');
    }
    notifyListeners();
  }

  /// Xóa dữ liệu hiện tại
  void clearCurrentData() {
    _currentArtifact = null;
    _currentQrCode = null;
    notifyListeners();
  }

  /// Fetch tất cả các Artifact từ API
  Future<void> fetchAllArtifacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedArtifacts = await _artifactService.fetchAllArtifacts();
      _artifacts
        ..clear()
        ..addAll(fetchedArtifacts); // Cập nhật nội dung danh sách
      debugPrint(
          'Fetched Artifacts: ${_artifacts.map((artifact) => artifact.artifactId).toList()}');
    } catch (e) {
      debugPrint('Error fetching artifacts: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Artifact bằng QR Code
  Future<void> fetchArtifactByQRCode(String qrCode) async {
    _errorMessage = null;
    try {
      final artifact = await _artifactService.fetchArtifactByQRCode(qrCode);
      if (artifact != null) {
        _currentArtifact = artifact;

        // Nếu Artifact chưa tồn tại, thêm nó vào danh sách
        if (!_artifacts.any((item) => item.artifactId == artifact.artifactId)) {
          _artifacts.add(artifact);
        }
      } else {
        _errorMessage = 'Artifact not found for the given QR Code.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching artifact: $e';
    }
    notifyListeners();
  }

  /// Lấy Artifact từ danh sách theo ID
  Artifact? getArtifactById(int id) {
    try {
      return _artifacts.firstWhere((artifact) => artifact.artifactId == id);
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy phần tử
    }
  }

  /// Lấy Artifact từ danh sách theo tên
  Artifact? getArtifactByName(String name) {
    try {
      return _artifacts.firstWhere(
        (artifact) => artifact.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy phần tử
    }
  }
}
