import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_flip/screens/a1_level_screen.dart';
import 'package:lingo_flip/screens/a2_level_screen.dart';
import 'package:lingo_flip/screens/b1_level_screen.dart';
import 'package:lingo_flip/screens/b2_level_screen.dart';
import 'package:lingo_flip/screens/c1_level_screen.dart';
import 'package:lingo_flip/screens/toefl_level_screen.dart';
import 'package:lingo_flip/screens/yds_level_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  static const String routeName = '/start';

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _unlockedLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevelIndex = prefs.getInt('unlockedLevel') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> levels = [
      {
        'name': 'A1',
        'title': 'Başlangıç',
        'route': A1LevelScreen.routeName,
        'icon': Icons.flag_circle_outlined
      },
      {
        'name': 'A2',
        'title': 'Temel',
        'route': A2LevelScreen.routeName,
        'icon': Icons.explore_outlined
      },
      {
        'name': 'B1',
        'title': 'Orta',
        'route': B1LevelScreen.routeName,
        'icon': Icons.lightbulb_outline_rounded
      },
      {
        'name': 'B2',
        'title': 'Orta-İleri',
        'route': B2LevelScreen.routeName,
        'icon': Icons.school_outlined
      },
      {
        'name': 'C1',
        'title': 'İleri',
        'route': C1LevelScreen.routeName,
        'icon': Icons.workspace_premium_outlined
      },
      {
        'name': 'TOEFL',
        'title': 'Sınav',
        'route': ToeflLevelScreen.routeName,
        'icon': Icons.menu_book_outlined
      },
      {
        'name': 'YDS',
        'title': 'Sınav',
        'route': YdsLevelScreen.routeName,
        'icon': Icons.assignment_turned_in_outlined
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seviye Seçimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final wantsToReset = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('İlerlemeyi Sıfırla'),
                  content: const Text(
                      'Tüm ilerlemeni sıfırlamak istediğinden emin misin? Bu işlem geri alınamaz.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
              );
              if (wantsToReset == true) {
                final prefs = await SharedPreferences.getInstance();
                for (var level in levels) {
                  await prefs.remove('${level['name']}_remaining_words');
                  await prefs.remove('${level['name']}_repeat_words');
                  await prefs.remove('${level['name']}_is_reviewing');
                  await prefs.remove('${level['name']}_main_cache');
                }
                await prefs.setInt('unlockedLevel', 0);
                _loadProgress();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İlerleme sıfırlandı!')),
                );
              }
            },
            tooltip: 'İlerlemeyi Sıfırla',
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final bool isUnlocked = index <= _unlockedLevelIndex;
          final level = levels[index];
          return _LevelCard(
            levelName: level['name'],
            title: level['title'],
            icon: level['icon'],
            isUnlocked: isUnlocked,
            onTap: () async {
              if (isUnlocked) {
                await Navigator.pushNamed(context, level['route']);
                _loadProgress();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Önceki seviyeleri tamamlamalısın!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String levelName;
  final String title;
  final IconData icon;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.levelName,
    required this.title,
    required this.isUnlocked,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isUnlocked
        ? [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ]
        : [
            Colors.grey.shade600,
            Colors.grey.shade800,
          ];

    return Card(
      elevation: isUnlocked ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white.withOpacity(0.8), size: 40),
                    const Spacer(),
                    Text(
                      levelName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              if (!isUnlocked)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white70,
                      size: 50,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}