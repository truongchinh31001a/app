import 'package:app/providers/artifact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtifactDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu Artifact từ ArtifactProvider
    final artifact = Provider.of<ArtifactProvider>(context).artifact;

    if (artifact == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Artifact Detail'),
        ),
        body: Center(child: Text('Artifact not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(artifact.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${artifact.name}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Description: ${artifact.description}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
