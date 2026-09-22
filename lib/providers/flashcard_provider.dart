import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../services/isar_service.dart';

final isarServiceProvider = Provider((ref) => IsarService());

// Dark/Light Mode Provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final flashcardProvider =
    StateNotifierProvider<FlashcardNotifier, List<Flashcard>>((ref) {
      return FlashcardNotifier(ref.read(isarServiceProvider));
    });

class FlashcardNotifier extends StateNotifier<List<Flashcard>> {
  final IsarService db;

  FlashcardNotifier(this.db) : super([]) {
    loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    state = await db.getAllFlashcards();
  }

  Future<void> addOrUpdateFlashcard(Flashcard card) async {
    await db.saveFlashcard(card);
    await loadFlashcards();
  }

  Future<void> toggleFavorite(Flashcard card) async {
    card.isFavorite = !card.isFavorite;
    await db.saveFlashcard(card);
    await loadFlashcards();
  }

  Future<void> deleteFlashcard(int id) async {
    await db.deleteFlashcard(id);
    await loadFlashcards();
  }
}
