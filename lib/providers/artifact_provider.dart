import 'package:flutter/material.dart';
import '../models/artifact.dart';
import '../services/artifact_service.dart';

class ArtifactProvider with ChangeNotifier {
  final ArtifactService _artifactService = ArtifactService();

  Artifact? _currentArtifact;
  bool _isLoading = false;
  String? _errorMessage;
  final List<Artifact> _artifacts = []; // Danh sách Artifact

  Artifact? get currentArtifact => _currentArtifact;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Artifact> get artifacts => List.unmodifiable(_artifacts); // Đảm bảo chỉ đọc từ ngoài

  /// Fetch tất cả các Artifact từ API
  Future<void> fetchAllArtifacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedArtifacts = await _artifactService.fetchAllArtifacts(); // Lấy danh sách từ API
      _artifacts
        ..clear()
        ..addAll(fetchedArtifacts); // Cập nhật nội dung danh sách
      debugPrint('Fetched Artifacts: ${_artifacts.map((artifact) => artifact.artifactId).toList()}');
    } catch (e) {
      debugPrint('Error fetching artifacts: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Lấy Artifact từ danh sách theo ID
  Artifact? getArtifactById(int id) {
    try {
      return _artifacts.firstWhere((artifact) => artifact.artifactId == id);
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy phần tử
    }
  }

  /// Fetch Artifact bằng QR Code
  Future<void> fetchArtifactByQRCode(String qrCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final artifact = await _artifactService.fetchArtifactByQRCode(qrCode);
      if (artifact != null) {
        _currentArtifact = artifact;
        // Nếu Artifact được tải về không có trong danh sách, thêm nó vào
        if (!_artifacts.any((item) => item.artifactId == artifact.artifactId)) {
          _artifacts.add(artifact);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear Artifact hiện tại
  void clearCurrentArtifact() {
    _currentArtifact = null;
    notifyListeners();
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
