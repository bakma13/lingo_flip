import 'package:flutter/material.dart';
import 'package:lingo_flip/services/word_service.dart';
import 'package:lingo_flip/screens/base_level_screen.dart';

class YdsLevelScreen extends StatelessWidget {
  const YdsLevelScreen({super.key});

  static const String routeName = '/yds_level';

  @override
  Widget build(BuildContext context) {
    return BaseLevelScreen(
      levelKey: 'YDS',
      levelTitle: 'YDS Seviyesi',
      wordLoader: () => WordService.getWordsForLevel('YDS'),
      nextLevelIndex: 7, // Son seviye olduğu için bir sonraki seviye index'i 7
    );
  }
}