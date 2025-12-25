import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/c1_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class B2LevelScreen extends StatelessWidget {
  const B2LevelScreen({super.key});

  static const String routeName = '/b2_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'B2',
      levelTitle: 'B2 Seviyesi',
      wordLoader: () => WordService.getWordsFromOxfordList('B2'),
      nextLevelRouteName: C1LevelScreen.routeName,
      nextLevelDisplayName: 'C1',
      nextLevelIndex: 4,
    );
  }
}