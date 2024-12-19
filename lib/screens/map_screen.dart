import 'dart:convert';

import 'package:app/services/map_service.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService mapService = MapService();

  String? mapImageUrl;
  double imageWidth = 0;
  double imageHeight = 0;
  List<Map<String, dynamic>>? highlightPoints;
  bool isLoading = true;

  // Độ lệch (offset) cho các điểm nổi bật
  final double offsetX = 12.0; // Lệch sang trái
  final double offsetY = 20.0; // Lệch lên trên

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final maps = await mapService.fetchMaps();
      final highlights = await mapService.fetchHighlightPoints();

      // Lấy bản đồ đầu tiên
      final mapData = maps.firstWhere((map) => map['map_id'] == 1);
      final imageUrl = 'http://192.168.1.86:3000${mapData['map_image']}';

      setState(() {
        mapImageUrl = imageUrl;
        imageWidth = (mapData['image_width'] as num).toDouble();
        imageHeight = (mapData['image_height'] as num).toDouble();

        // Chuyển đổi highlight_points từ chuỗi JSON sang List
        highlightPoints = highlights.map((area) {
          final points = json.decode(area['highlight_points'] ?? '[]');
          return {
            'name': area['name'] ?? 'Unknown Name',
            'description': area['description_vi'] ?? 'No Description Available',
            'points': points.map((point) {
              return {
                'x': (point['x'] as num).toDouble(),
                'y': (point['y'] as num).toDouble(),
              };
            }).toList(),
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showBottomSheet(BuildContext context, String name, String description) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Chiếm 1/2 màn hình
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Museum Map', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (mapImageUrl != null && imageWidth > 0 && imageHeight > 0)
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // Kích thước thực tế của khung chứa ảnh
                    final containerWidth = constraints.maxWidth;
                    final containerHeight =
                        containerWidth * (imageHeight / imageWidth);

                    return Center(
                      child: InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: containerWidth,
                            height: containerHeight,
                            child: Stack(
                              children: [
                                // Hiển thị hình ảnh
                                Image.network(
                                  mapImageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                        child: Text('Failed to load image'));
                                  },
                                ),
                                // Hiển thị các điểm nổi bật
                                if (highlightPoints != null)
                                  ...highlightPoints!.expand((highlight) {
                                    final points =
                                        highlight['points'] as List<dynamic>;
                                    return points.map((point) {
                                      final x = point['x'] as double;
                                      final y = point['y'] as double;

                                      // Tính toán tọa độ hiển thị và áp dụng độ lệch
                                      final adjustedX =
                                          ((x / imageWidth) * containerWidth) -
                                              offsetX;
                                      final adjustedY =
                                          ((y / imageHeight) *
                                              containerHeight) -
                                              offsetY;

                                      return Positioned(
                                        left: adjustedX,
                                        top: adjustedY,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showBottomSheet(
                                              context,
                                              highlight['name'],
                                              highlight['description'],
                                            );
                                          },
                                          child: Tooltip(
                                            message: highlight['name'],
                                            child: Icon(Icons.location_on,
                                                color: Colors.red),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('Failed to load map: Invalid image dimensions'),
                ),
    );
  }
}
