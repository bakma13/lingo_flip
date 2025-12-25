import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/a2_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class A1LevelScreen extends StatelessWidget {
  const A1LevelScreen({super.key});

  static const String routeName = '/a1_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'A1',
      levelTitle: 'A1 Seviyesi',
      wordLoader: () => WordService.getWordsFromOxfordList('A1'),
      nextLevelRouteName: A2LevelScreen.routeName,
      nextLevelDisplayName: 'A2',
      nextLevelIndex: 1,
    );
  }
}