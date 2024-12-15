// lib/screens/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> scannedItems = [
    {'name': 'Artifact 1', 'date': '2024-12-01'},
    {'name': 'Artifact 2', 'date': '2024-12-02'},
    {'name': 'Artifact 3', 'date': '2024-12-03'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: ListView.builder(
        itemCount: scannedItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.history, color: Colors.blue),
            title: Text(scannedItems[index]['name']!),
            subtitle: Text('Scanned on: ${scannedItems[index]['date']}'),
          );
        },
      ),
    );
  }
}
