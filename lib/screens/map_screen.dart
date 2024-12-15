// lib/screens/map_screen.dart
import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Museum Map')),
      body: Center(
        child: Image.asset(
          'assets/images/map.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
