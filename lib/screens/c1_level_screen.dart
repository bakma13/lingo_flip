import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/toefl_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class C1LevelScreen extends StatelessWidget {
  const C1LevelScreen({super.key});

  static const String routeName = '/c1_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'C1',
      levelTitle: 'C1 Seviyesi',
      wordLoader: () => WordService.getWordsFromOxfordList('C1'),
      nextLevelRouteName: ToeflLevelScreen.routeName,
      nextLevelDisplayName: 'TOEFL',
      nextLevelIndex: 5,
    );
  }
}