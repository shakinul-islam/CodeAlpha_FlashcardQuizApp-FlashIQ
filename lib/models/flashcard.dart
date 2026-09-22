import 'package:isar/isar.dart';
part 'flashcard.g.dart';

@Collection()
class Flashcard {
  Id id = Isar.autoIncrement;
  
  late String question;
  late String answer;
  bool isFavorite = false; // Notun feature

  Flashcard({
    required this.question,
    required this.answer,
    this.isFavorite = false,
  });
}