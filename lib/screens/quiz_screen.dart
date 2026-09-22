import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import 'result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<Flashcard> quizCards = [];
  int currentIndex = 0;
  bool isFlipped = false;
  bool isTransitioning = false;
  int correctAnswers = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      final cards = ref.read(flashcardProvider).toList();
      cards.shuffle();
      setState(() {
        quizCards = cards;
      });
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _flipCard() {
    if (isFlipped) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() => isFlipped = !isFlipped);
  }

  // Favorite kora ba bad dewar logic
  void _toggleFavorite() {
    final currentCard = quizCards[currentIndex];
    ref.read(flashcardProvider.notifier).toggleFavorite(currentCard);
    setState(() {});
  }

  // Next Button / Swipe Left er function
  void _nextCardManual() {
    if (isTransitioning || currentIndex >= quizCards.length - 1) return;
    setState(() => isTransitioning = true);
    if (isFlipped) _flipCard();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          currentIndex++;
          isTransitioning = false;
        });
      }
    });
  }

  // Previous Button / Swipe Right er function
  void _prevCardManual() {
    if (isTransitioning || currentIndex <= 0) return;
    setState(() => isTransitioning = true);
    if (isFlipped) _flipCard();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          currentIndex--;
          isTransitioning = false;
        });
      }
    });
  }

  // Swipe Detect korar function
  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity! < -300) {
      _nextCardManual();
    } else if (details.primaryVelocity! > 300) {
      _prevCardManual();
    }
  }

  void _handleAnswer(bool knewIt) {
    if (isTransitioning) return;
    if (knewIt) correctAnswers++;

    setState(() => isTransitioning = true);
    if (isFlipped) _flipCard();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (currentIndex < quizCards.length - 1) {
        if (mounted) {
          setState(() {
            currentIndex++;
            isTransitioning = false;
          });
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              totalCards: quizCards.length,
              correctAnswers: correctAnswers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCard = quizCards[currentIndex];
    final progress = (currentIndex + 1) / quizCards.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Quiz Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Question ${currentIndex + 1} of ${quizCards.length}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              currentCard.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: currentCard.isFavorite
                  ? Colors.amber
                  : (isDark ? Colors.white : Colors.grey),
              size: 28,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              color: primaryColor,
            ),
            const SizedBox(height: 30),

            // 3D Card with Swipe Gesture
            Expanded(
              flex: 3,
              child: GestureDetector(
                onHorizontalDragEnd: _onSwipe,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value * pi;
                    final isFrontVisible = angle <= pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isFrontVisible
                          ? _buildCardSide(
                              currentCard.question,
                              "QUESTION",
                              isDark ? Colors.grey.shade900 : Colors.white,
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: _buildCardSide(
                                currentCard.answer,
                                "ANSWER",
                                primaryColor,
                                textColor: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Navigation and Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: (currentIndex > 0 && !isTransitioning)
                      ? _prevCardManual
                      : null,
                  child: const Icon(Icons.arrow_back_rounded, size: 24),
                ),

                // Center Action Buttons (Show Answer OR Knew it/Forgot)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: !isFlipped
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isTransitioning ? null : _flipCard,
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text(
                              "Show Answer",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () => _handleAnswer(false),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "Forgot",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: const Color(
                                      0xFF10B981,
                                    ), // Emerald Green
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _handleAnswer(true),
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "Knew it",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Next Button
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed:
                      (currentIndex < quizCards.length - 1 && !isTransitioning)
                      ? _nextCardManual
                      : null,
                  child: const Icon(Icons.arrow_forward_rounded, size: 24),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(
    String text,
    String label,
    Color bgColor, {
    Color textColor = Colors.black87,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalTextColor = textColor == Colors.black87 && isDark
        ? Colors.white
        : textColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: finalTextColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: finalTextColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: finalTextColor.withOpacity(0.05),
                ),
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: finalTextColor.withOpacity(0.9),
                ),
                onPressed: () => _speak(text),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: finalTextColor,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
