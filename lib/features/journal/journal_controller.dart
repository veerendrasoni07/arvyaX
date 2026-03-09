import 'package:flutter/foundation.dart';

import '../../data/models/ambience.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

class JournalController extends ChangeNotifier {
  JournalController(this._repository);

  final JournalRepository _repository;

  ValueListenable get listenable => _repository.listenable();

  List<JournalEntry> get entries => _repository.allEntries();

  Future<void> saveReflection({
    required Ambience ambience,
    required String mood,
    required String text,
  }) {
    final entry = JournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      ambienceId: ambience.id,
      ambienceTitle: ambience.title,
      mood: mood,
      text: text.trim(),
    );
    return _repository.saveEntry(entry);
  }
}

