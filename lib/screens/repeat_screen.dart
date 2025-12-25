import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class RepeatScreen extends StatefulWidget {
  final List<Map<String, String>> words;

  const RepeatScreen({super.key, required this.words});

  @override
  State<RepeatScreen> createState() => _RepeatScreenState();
}

class _RepeatScreenState extends State<RepeatScreen> {
  late List<Map<String, String>> _reviewWords;
  int _initialWordCount = 0;
  bool _isRevealed = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _reviewWords = List.from(widget.words);
    _reviewWords.shuffle();
    _initialWordCount = _reviewWords.length;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tekrar Oturumu'),
        automaticallyImplyLeading: false, // Don't show back button
      ),
      body:
          _reviewWords.isEmpty ? _buildCompletionView() : _buildWordCardView(),
    );
  }

  Widget _buildWordCardView() {
    final currentWord = _reviewWords[0];
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
                  'Tekrar Oturumu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Kalan: ${_reviewWords.length}',
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
                key: ObjectKey(currentWord),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  final word = _reviewWords.removeAt(0);
                  setState(() {
                    _isRevealed = false;
                    if (direction == DismissDirection.endToStart) {
                      // Add back to the end of the list to repeat
                      _reviewWords.add(word);
                    }
                  });
                  if (_reviewWords.isEmpty) {
                    _confettiController.play();
                  }
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
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                            currentWord['en']!,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isRevealed
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                      : Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (_isRevealed) ...[
                            const Divider(height: 40, thickness: 2),
                            Text(
                              currentWord['tr']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (!_isRevealed)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text('(Anlamı için dokun)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
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
          _buildProgressBar(),
        ],
      ),
    );
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
              const Text('Harika!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Tekrar oturumunu tamamladın.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () =>
                    Navigator.pop(context, true), // Return true on success
                label: const Text('Derse Geri Dön'),
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

  Widget _buildProgressBar() {
    final double progress = _initialWordCount > 0
        ? (_initialWordCount - _reviewWords.length) / _initialWordCount
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
                'Tekrar İlerlemesi',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
}