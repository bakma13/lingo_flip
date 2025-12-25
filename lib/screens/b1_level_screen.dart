import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/b2_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class B1LevelScreen extends StatelessWidget {
  const B1LevelScreen({super.key});

  static const String routeName = '/b1_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'B1',
      levelTitle: 'B1 Seviyesi',
      wordLoader: () => WordService.getWordsFromOxfordList('B1'),
      nextLevelRouteName: B2LevelScreen.routeName,
      nextLevelDisplayName: 'B2',
      nextLevelIndex: 3,
    );
  }
}