
import 'package:app/providers/mini_control_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/security_provider.dart';
import 'providers/story_provider.dart';
import 'providers/artifact_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/video_provider.dart';
import 'services/story_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giới hạn app ở chế độ dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Tạo instance của SecurityProvider và khôi phục trạng thái
  final securityProvider = SecurityProvider();
  await securityProvider.restoreState(); // Khôi phục trạng thái mở khóa

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => securityProvider), // Security Provider
        ChangeNotifierProvider(
          create: (_) => StoryProvider(
            storyService: StoryService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ArtifactProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => MiniControlProvider())
      ],
      child: MuseumApp(),
    ),
  );
}

class MuseumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Museum App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      initialRoute: '/', // Route mặc định là SplashScreen
      routes: {
        '/': (context) => SplashScreen(),
        '/main': (context) => MainScreen(),
        '/lock': (context) => LockScreen(),
        
      },
    );
  }
}
