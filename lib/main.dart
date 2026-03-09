import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/ambience_repository.dart';
import 'data/repositories/journal_repository.dart';
import 'features/ambience/ambience_controller.dart';
import 'features/ambience/ambience_screen.dart';
import 'features/journal/journal_controller.dart';
import 'features/player/player_controller.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final journalRepository = JournalRepository();
  await journalRepository.init();

  final ambienceRepository = AmbienceRepository();

  final ambienceController = AmbienceController(ambienceRepository);
  await ambienceController.load();

  final playerController = PlayerController(
    audioService: AudioService(),
    storageService: storageService,
  );
  await playerController.restore(ambienceController.all);

  final journalController = JournalController(journalRepository);

  runApp(
    MyApp(
      ambienceController: ambienceController,
      playerController: playerController,
      journalController: journalController,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.ambienceController,
    required this.playerController,
    required this.journalController,
  });

  final AmbienceController ambienceController;
  final PlayerController playerController;
  final JournalController journalController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambience Sessions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AmbienceScreen(
        ambienceController: ambienceController,
        playerController: playerController,
        journalController: journalController,
      ),
    );
  }
}

