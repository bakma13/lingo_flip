import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lingo_flip/screens/repeat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class BaseLevelScreen extends StatefulWidget {
  final String levelKey;
  final String levelTitle;
  final Future<List<Map<String, String>>> Function() wordLoader;
  final String? nextLevelRouteName;
  final String? nextLevelDisplayName;
  final int nextLevelIndex;

  const BaseLevelScreen({
    super.key,
    required this.levelKey,
    required this.levelTitle,
    required this.wordLoader,
    this.nextLevelRouteName,
    this.nextLevelDisplayName,
    required this.nextLevelIndex,
  });

  @override
  State<BaseLevelScreen> createState() => _BaseLevelScreenState();
}

class _BaseLevelScreenState extends State<BaseLevelScreen> {
  List<Map<String, String>> _words = [];
  final List<Map<String, String>> _wordsToRepeat = [];
  int _currentPassTotal = 0;
  bool _isRevealed = false;
  final int _reviewThreshold = 50;
  bool _isLoading = true;
  bool _hasError = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _loadProgress();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final remainingWordsJson = _words.map((word) => json.encode(word)).toList();
    final repeatWordsJson =
        _wordsToRepeat.map((word) => json.encode(word)).toList();

    await prefs.setStringList('${widget.levelKey}_remaining_words', remainingWordsJson);
    await prefs.setStringList('${widget.levelKey}_repeat_words', repeatWordsJson);
  }

  Future<void> _clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.levelKey}_remaining_words');
    await prefs.remove('${widget.levelKey}_repeat_words');
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();

      final remainingWordsJson =
          prefs.getStringList('${widget.levelKey}_remaining_words');
      final repeatWordsJson =
          prefs.getStringList('${widget.levelKey}_repeat_words');

      List<Map<String, String>> loadedWords;
      List<Map<String, String>> loadedRepeatWords = [];

      if (remainingWordsJson != null &&
          repeatWordsJson != null &&
          remainingWordsJson.isNotEmpty) {
        loadedWords = remainingWordsJson
            .map((wordJson) => Map<String, String>.from(json.decode(wordJson)))
            .toList();
        loadedRepeatWords = repeatWordsJson
            .map((wordJson) => Map<String, String>.from(json.decode(wordJson)))
            .toList();
      } else {
        loadedWords = await widget.wordLoader();
        await _clearProgress(); // Start fresh, clear any old empty lists
      }

      if (mounted) {
        setState(() {
          _words = loadedWords;
          _wordsToRepeat.addAll(loadedRepeatWords);
          _currentPassTotal = loadedWords.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _unlockNextLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentLevel = prefs.getInt('unlockedLevel') ?? 0;
    if (currentLevel < widget.nextLevelIndex) {
      await prefs.setInt('unlockedLevel', widget.nextLevelIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : _words.isEmpty
                  ? _buildCompletionView()
                  : _buildWordCardView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Kelimeler yüklenemedi.'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadProgress,
            child: const Text('Tekrar Dene'),
          )
        ],
      ),
    );
  }

  Widget _buildWordCardView() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.levelTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Kalan: ${_words.length}',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: AspectRatio(
            aspectRatio: 3.5 / 4.5,
            child: Dismissible(
                key: ObjectKey(_words[0]),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) async {
                  final currentWord = _words.removeAt(0);

                  if (direction == DismissDirection.endToStart) {
                    _wordsToRepeat.add(currentWord);
                  }

                  if (_words.isEmpty) {
                    // Level finished
                    setState(() {}); // Tamamlanma ekranını göstermek için yeniden çiz
                    await _clearProgress();
                    _unlockNextLevel();
                    _confettiController.play();
                  } else {
                    // Normal swipe, just update the UI
                    setState(() {
                      _isRevealed = false;
                    });
                  }
                  await _saveProgress();
                },
                background: _buildSwipeActionContainer(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    icon: Icons.check_circle_outline,
                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    alignment: Alignment.centerLeft),
                secondaryBackground: _buildSwipeActionContainer(
                    color: Theme.of(context).colorScheme.errorContainer,
                    icon: Icons.refresh,
                    iconColor: Theme.of(context).colorScheme.onErrorContainer,
                    alignment: Alignment.centerRight),
                child: GestureDetector(
                  onTap: () => setState(() => _isRevealed = !_isRevealed),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _isRevealed
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _words[0]['en']!,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isRevealed
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (_isRevealed) ...[
                            const Divider(height: 40, thickness: 2),
                            Text(
                              _words[0]['tr']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (!_isRevealed)
                             Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text('(Anlamı için dokun)',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ),
        ),
        const Spacer(),
        _buildReviewBar(),
      ],
    ),);
  }

  Widget _buildCompletionView() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text('Tebrikler!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
               Text('Bu seviyedeki tüm kelimeleri tamamladın.',
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
                label: const Text('Seviye Listesine Dön'),
              ),
              const SizedBox(height: 10),
              if (widget.nextLevelRouteName != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, widget.nextLevelRouteName!),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  label: Text(
                      'Sonraki Seviye (${widget.nextLevelDisplayName ?? ''})'),
                )
              else
                 Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Tüm seviyeler bitti! 🎓',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
        ),
      ],
    );
  }

  Widget _buildSwipeActionContainer(
      {required Color color,
      required IconData icon,
      required Color iconColor,
      required Alignment alignment}) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: iconColor, size: 40),
    );
  }

  Future<void> _handleStartReview() async {
    if (_wordsToRepeat.length < _reviewThreshold) return;

    final wordsForSession = _wordsToRepeat.sublist(0, _reviewThreshold);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepeatScreen(words: wordsForSession),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _wordsToRepeat.removeRange(0, _reviewThreshold);
      });
      await _saveProgress();
    }
  }

  Widget _buildProgressBar() {
    final double progress = _currentPassTotal > 0
        ? (_currentPassTotal - _words.length) / _currentPassTotal
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tur İlerlemesi',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            minHeight: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBar() {
    final int reviewCount = _wordsToRepeat.length;
    final bool isReviewReady = reviewCount >= _reviewThreshold;
    final double progress =
        isReviewReady ? 1.0 : reviewCount / _reviewThreshold.toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tekrar için birikenler',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('$reviewCount / $_reviewThreshold',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: isReviewReady ? Colors.amber : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            minHeight: 12,
          ),
          if (isReviewReady) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _PulsingWidget(
                child: ElevatedButton.icon(
                  onPressed: _handleStartReview,
                  icon: const Icon(Icons.psychology_outlined),
                  label: Text('$_reviewThreshold Kelimeyi Tekrar Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _PulsingWidget extends StatefulWidget {
  final Widget child;

  const _PulsingWidget({
    required this.child,
  });

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}