import 'package:flutter/material.dart';

class SharedState {
  static final SharedState _instance = SharedState._internal();
  factory SharedState() => _instance;

  SharedState._internal();

  final ValueNotifier<String?> activeMediaNotifier =
      ValueNotifier<String?>(null);

  void setActiveMedia(String? mediaType) {
    activeMediaNotifier.value = mediaType;
  }

  String? get activeMedia => activeMediaNotifier.value;
}
