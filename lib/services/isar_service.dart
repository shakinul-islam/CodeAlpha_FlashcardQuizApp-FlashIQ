import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [FlashcardSchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Add or Update Flashcard
  Future<void> saveFlashcard(Flashcard card) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.flashcards.putSync(card));
  }

  // Get All Flashcards
  Future<List<Flashcard>> getAllFlashcards() async {
    final isar = await db;
    return await isar.flashcards.where().findAll();
  }

  // Delete Flashcard
  Future<void> deleteFlashcard(int id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.flashcards.deleteSync(id));
  }
}