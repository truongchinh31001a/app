import 'package:app/screens/detail_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../providers/security_provider.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Gọi fetchStories sau khi widget được xây dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);

    // Chuyển đổi ngôn ngữ
    final language = securityProvider.language == 'English' ? 'en' : 'vi';

    // Tùy chỉnh text dựa trên ngôn ngữ
    final String searchHint =
        language == 'en' ? 'Search playlists...' : 'Tìm kiếm playlist...';
    final String audioTabText = language == 'en' ? 'Audio' : 'Âm thanh';
    final String videoTabText = language == 'en' ? 'Video' : 'Video';
    final String noStoriesText =
        language == 'en' ? 'No stories available' : 'Không có câu chuyện nào';

    // Lọc playlist theo từ khóa tìm kiếm
    final filteredPlaylists = storyProvider.playlists.entries
        .where((entry) => 'Playlist ${entry.key}'
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'en' ? 'Story Playlists' : 'Danh sách Playlist',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: const Icon(Icons.audiotrack), text: audioTabText),
            Tab(icon: const Icon(Icons.videocam), text: videoTabText),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Ô tìm kiếm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Cập nhật từ khóa tìm kiếm
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  hintText: searchHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            // Danh sách playlist trong tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Audio
                  _buildPlaylist(
                    storyProvider,
                    filteredPlaylists,
                    'audio',
                    language,
                    noStoriesText,
                  ),
                  // Tab Video
                  _buildPlaylist(
                    storyProvider,
                    filteredPlaylists,
                    'video',
                    language,
                    noStoriesText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist(
    StoryProvider storyProvider,
    List<MapEntry<dynamic, List>> filteredPlaylists,
    String type,
    String language,
    String noStoriesText,
  ) {
    return storyProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : storyProvider.error != null
            ? Center(
                child: Text(
                  'Error: ${storyProvider.error}',
                  style: const TextStyle(color: Colors.black),
                ),
              )
            : Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: filteredPlaylists.length,
                  itemBuilder: (context, index) {
                    final areaId = filteredPlaylists[index].key;
                    final playlistName = language == 'en'
                        ? 'Playlist $areaId'
                        : 'Danh sách $areaId';
                    final playlistStories = filteredPlaylists[index]
                        .value
                        .where((story) => _filterByType(story, type, language))
                        .toList();

                    return ExpansionTile(
                      title: Text(
                        playlistName,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        playlistStories.isEmpty
                            ? noStoriesText
                            : '${playlistStories.length} ${language == 'en' ? 'stories available' : 'câu chuyện có sẵn'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      children: playlistStories.map((story) {
                        return ListTile(
                          title: Text(
                            story.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                          leading: story.imageUrl.isNotEmpty
                              ? Image.network(
                                  'http://192.168.1.44:3000${story.imageUrl}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported,
                                  color: Colors.black),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsStoryScreen(story: story),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              );
  }

  bool _filterByType(dynamic story, String type, String language) {
    if (type == 'audio') {
      return story.audioUrl[language] != null &&
          story.audioUrl[language]!.isNotEmpty;
    } else if (type == 'video') {
      return story.videoUrl[language] != null &&
          story.videoUrl[language]!.isNotEmpty;
    }
    return false;
  }
}
