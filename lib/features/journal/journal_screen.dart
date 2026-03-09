import 'package:flutter/material.dart';

import '../../core/widgets/formatters.dart';
import '../../data/models/ambience.dart';
import '../../data/models/journal_entry.dart';
import '../player/player_controller.dart';
import '../player/player_screen.dart';
import 'journal_controller.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.ambience,
    this.onSaved,
    this.journalController,
  });

  final Ambience ambience;
  final VoidCallback? onSaved;
  final JournalController? journalController;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _moods = const ['Calm', 'Grounded', 'Energized', 'Sleepy'];
  String _selectedMood = 'Calm';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journal = widget.journalController;

    return Scaffold(
      appBar: AppBar(title: const Text('Reflection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is gently present with you right now?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Write your reflection...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _moods
                  .map(
                    (mood) => ChoiceChip(
                      label: Text(mood),
                      selected: _selectedMood == mood,
                      onSelected: (_) => setState(() => _selectedMood = mood),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: journal == null
                  ? null
                  : () async {
                      await journal.saveReflection(
                        ambience: widget.ambience,
                        mood: _selectedMood,
                        text: _textController.text,
                      );
                      if (!context.mounted) return;
                      widget.onSaved?.call();
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({
    super.key,
    required this.controller,
    required this.playerController,
  });

  final JournalController controller;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final pending = playerController.consumePendingReflection();
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReflectionScreen(
              ambience: pending,
              journalController: controller,
              onSaved: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalScreen(
                      controller: controller,
                      playerController: playerController,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
          ),
        );
      });
    }

    return ValueListenableBuilder(
      valueListenable: controller.listenable,
      builder: (_, __, ___) {
        final entries = controller.entries;
        return Scaffold(
          appBar: AppBar(title: const Text('Journal History')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: entries.isEmpty
                ? const Center(child: Text('No reflections saved yet.'))
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final entry = entries[index];
                      final preview = entry.text.split('\n').firstWhere(
                            (line) => line.isNotEmpty,
                            orElse: () => '',
                          );
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(entry.ambienceTitle),
                        subtitle: Text(
                          '${formatDateTime(entry.createdAt)} • ${entry.mood}\n${preview.isEmpty ? '(No text)' : preview}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JournalEntryView(entry: entry),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          bottomNavigationBar: MiniPlayerBar(
            controller: playerController,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(
                    controller: playerController,
                    initialAmbience: playerController.current,
                    onSessionEnded: (ambience) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReflectionScreen(
                            ambience: ambience,
                            journalController: controller,
                            onSaved: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalScreen(
                                    controller: controller,
                                    playerController: playerController,
                                  ),
                                ),
                                (route) => route.isFirst,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class JournalEntryView extends StatelessWidget {
  const JournalEntryView({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflection Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              entry.ambienceTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${formatDateTime(entry.createdAt)} • ${entry.mood}'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Text(
                entry.text.trim().isEmpty ? '(No reflection text saved.)' : entry.text,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

