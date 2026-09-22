import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int totalCards;
  final int correctAnswers;

  const ResultScreen({
    Key? key,
    required this.totalCards,
    required this.correctAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (correctAnswers / totalCards) * 100;
    final isSuccess = percentage >= 50;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Result"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              size: 100,
              color: isSuccess ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              isSuccess ? "Awesome Job!" : "Keep Practicing!",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "You scored $correctAnswers out of $totalCards",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
