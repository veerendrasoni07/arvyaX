import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/journal_entry.dart';

class JournalRepository {
  static const _boxName = 'journal_entries';
  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> saveEntry(JournalEntry entry) {
    return _box.put(entry.id, entry.toMap());
  }

  ValueListenable<Box> listenable() => _box.listenable();

  List<JournalEntry> allEntries() {
    return _box.values
        .map((value) => JournalEntry.fromMap(value as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

