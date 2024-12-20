import 'package:flutter/material.dart';
import '../models/artifact.dart';
import '../services/artifact_service.dart';

class ArtifactProvider with ChangeNotifier {
  final ArtifactService _artifactService = ArtifactService();

  Artifact? _currentArtifact;
  bool _isLoading = false;
  String? _errorMessage;

  Artifact? get currentArtifact => _currentArtifact;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> fetchArtifactByQRCode(String qrCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentArtifact = await _artifactService.fetchArtifactByQRCode(qrCode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentArtifact() {
    _currentArtifact = null;
    notifyListeners();
  }
}
