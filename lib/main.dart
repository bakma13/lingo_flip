import 'package:flutter/material.dart';
import 'package:lingo_flip/splash/splash_screen.dart';
import 'package:lingo_flip/screens/start_screen.dart';
import 'package:lingo_flip/screens/a1_level_screen.dart';
import 'package:lingo_flip/screens/a2_level_screen.dart';
import 'package:lingo_flip/screens/b1_level_screen.dart';
import 'package:lingo_flip/screens/b2_level_screen.dart';
import 'package:lingo_flip/screens/c1_level_screen.dart';
import 'package:lingo_flip/screens/toefl_level_screen.dart';
import 'package:lingo_flip/screens/yds_level_screen.dart';

void main() {
  // Pluginlerin (SharedPreferences vb.) uygulama başlamadan önce hazır olması için gereklidir.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoFlip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        StartScreen.routeName: (context) => const StartScreen(),
        A1LevelScreen.routeName: (context) => const A1LevelScreen(),
        A2LevelScreen.routeName: (context) => const A2LevelScreen(),
        B1LevelScreen.routeName: (context) => const B1LevelScreen(),
        B2LevelScreen.routeName: (context) => const B2LevelScreen(),
        C1LevelScreen.routeName: (context) => const C1LevelScreen(),
        ToeflLevelScreen.routeName: (context) => const ToeflLevelScreen(),
        YdsLevelScreen.routeName: (context) => const YdsLevelScreen(),
      },
    );
  }
}
