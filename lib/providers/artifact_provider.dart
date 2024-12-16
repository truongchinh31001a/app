import 'package:app/models/artifact.dart';
import 'package:app/services/artifact_service.dart';
import 'package:flutter/material.dart';

class ArtifactProvider with ChangeNotifier {
  Artifact? _artifact;

  Artifact? get artifact => _artifact;

  // Hàm gọi API lấy dữ liệu Artifact dựa trên QR Code
  Future<void> fetchArtifactByQRCode(String qrCode) async {
    final response = await ArtifactService.fetchArtifactByQRCode(qrCode);
    if (response != null) {
      _artifact = Artifact.fromJson(response);
      notifyListeners();  // Cập nhật UI
    }
  }

  // Phương thức set trực tiếp Artifact
  void setArtifact(Artifact artifact) {
    _artifact = artifact;
    notifyListeners();  // Cập nhật UI
  }
}
