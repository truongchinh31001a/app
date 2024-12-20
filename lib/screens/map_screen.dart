import 'dart:convert';

import 'package:app/providers/artifact_provider.dart';
import 'package:app/providers/security_provider.dart'; // Để lấy thông tin ngôn ngữ
import 'package:app/screens/detail_artifact_screen.dart';
import 'package:app/services/map_service.dart';
import 'package:app/services/artifact_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService mapService = MapService();
  final ArtifactService artifactService = ArtifactService();

  String? mapImageUrl;
  double imageWidth = 0;
  double imageHeight = 0;
  List<Map<String, dynamic>>? highlightPoints;
  bool isLoading = true;

  final double offsetX = 12.0;
  final double offsetY = 20.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final maps = await mapService.fetchMaps();
      final highlights = await mapService.fetchHighlightPoints();

      final mapData = maps.firstWhere((map) => map['map_id'] == 1);
      final imageUrl = 'http://192.168.1.86:3000${mapData['map_image']}';

      if (mounted) {
        setState(() {
          mapImageUrl = imageUrl;
          imageWidth = (mapData['image_width'] as num).toDouble();
          imageHeight = (mapData['image_height'] as num).toDouble();

          highlightPoints = highlights.map((area) {
            final points = json.decode(area['highlight_points'] ?? '[]');
            return {
              'area_id': area['area_id'],
              'name': area['name'] ?? 'Unknown Name',
              'description':
                  area['description_vi'] ?? 'No Description Available',
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
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Hiển thị danh sách artifacts theo `areaId`
  void _showBottomSheet(BuildContext context, int areaId, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return _ArtifactListBottomSheet(
          areaId: areaId,
          areaName: name,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          securityProvider.language == 'English'
              ? 'Museum Map'
              : 'Bản đồ bảo tàng',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (mapImageUrl != null && imageWidth > 0 && imageHeight > 0)
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final containerWidth = constraints.maxWidth;
                    final containerHeight =
                        containerWidth * (imageHeight / imageWidth);

                    return Center(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: containerWidth,
                            height: containerHeight,
                            child: Stack(
                              children: [
                                Image.network(
                                  mapImageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                        child: Text('Failed to load image'));
                                  },
                                ),
                                if (highlightPoints != null)
                                  ...highlightPoints!.expand((highlight) {
                                    final points =
                                        highlight['points'] as List<dynamic>;
                                    return points.map((point) {
                                      final x = point['x'] as double;
                                      final y = point['y'] as double;

                                      final adjustedX =
                                          ((x / imageWidth) * containerWidth) -
                                              offsetX;
                                      final adjustedY = ((y / imageHeight) *
                                              containerHeight) -
                                          offsetY;

                                      return Positioned(
                                        left: adjustedX,
                                        top: adjustedY,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showBottomSheet(
                                              context,
                                              highlight['area_id'],
                                              highlight['name'],
                                            );
                                          },
                                          child: Tooltip(
                                            message: highlight['name'],
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                            ),
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
              : const Center(
                  child: Text('Failed to load map: Invalid image dimensions'),
                ),
    );
  }
}

class _ArtifactListBottomSheet extends StatefulWidget {
  final int areaId;
  final String areaName;

  const _ArtifactListBottomSheet({
    Key? key,
    required this.areaId,
    required this.areaName,
  }) : super(key: key);

  @override
  __ArtifactListBottomSheetState createState() =>
      __ArtifactListBottomSheetState();
}

class __ArtifactListBottomSheetState extends State<_ArtifactListBottomSheet> {
  final ArtifactService artifactService = ArtifactService();
  List<dynamic> artifacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtifacts();
  }

  Future<void> _fetchArtifacts() async {
    try {
      final data = await artifactService.fetchArtifactsByAreaId(widget.areaId);
      if (mounted) {
        setState(() {
          artifacts = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching artifacts: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);
    final languageKey = securityProvider.language == 'English' ? 'en' : 'vi';

    return FractionallySizedBox(
      heightFactor: 0.7,
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
            const SizedBox(height: 20),
            Text(
              widget.areaName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : artifacts.isEmpty
                      ? Center(
                          child: Text(
                            securityProvider.language == 'English'
                                ? 'No artifacts available'
                                : 'Không có hiện vật nào',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: artifacts.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final artifact = artifacts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              child: ListTile(
                                leading: artifact['image_url'] != null
                                    ? Image.network(
                                        'http://192.168.1.86:3000${artifact['image_url']}',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported),
                                title: Text(
                                  artifact['name_$languageKey'] ??
                                      artifact['name'] ??
                                      'Unknown',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onTap: () {
                                  Provider.of<ArtifactProvider>(context,
                                          listen: false)
                                      .setCurrentArtifact(artifact);
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ArtifactDetailScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
