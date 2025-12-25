import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/yds_level_screen.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class ToeflLevelScreen extends StatelessWidget {
  const ToeflLevelScreen({super.key});

  static const String routeName = '/toefl_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'TOEFL',
      levelTitle: 'TOEFL Seviyesi',
      wordLoader: () => WordService.getWordsForLevel('TOEFL'),
      nextLevelRouteName: YdsLevelScreen.routeName,
      nextLevelDisplayName: 'YDS',
      nextLevelIndex: 6,
    );
  }
}