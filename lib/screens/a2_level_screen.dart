import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/b1_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class A2LevelScreen extends StatelessWidget {
  const A2LevelScreen({super.key});

  static const String routeName = '/a2_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'A2',
      levelTitle: 'A2 Seviyesi',
      wordLoader: () => WordService.getWordsFromOxfordList('A2'),
      nextLevelRouteName: B1LevelScreen.routeName,
      nextLevelDisplayName: 'B1',
      nextLevelIndex: 2,
    );
  }
}