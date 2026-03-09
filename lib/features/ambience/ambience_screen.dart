import 'package:flutter/material.dart';

import '../../core/widgets/ambience_widgets.dart';
import '../../data/models/ambience.dart';
import '../journal/journal_controller.dart';
import '../player/player_controller.dart';
import '../player/player_screen.dart';
import '../journal/journal_screen.dart';
import 'ambience_controller.dart';

class AmbienceScreen extends StatelessWidget {
  const AmbienceScreen({
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
    return AnimatedBuilder(
      animation: Listenable.merge([ambienceController, playerController]),
      builder: (_, __) {
        final pending = playerController.consumePendingReflection();
        if (pending != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReflectionScreen(
                  ambience: pending,
                  journalController: journalController,
                  onSaved: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalScreen(
                          controller: journalController,
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

        final filtered = ambienceController.filtered;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ambience Library'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalScreen(
                        controller: journalController,
                        playerController: playerController,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_outlined),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search ambience',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ambienceController.setQuery,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final tag = ambienceController.tags[i];
                      return ChoiceChip(
                        selected: tag == ambienceController.tag,
                        label: Text(tag),
                        onSelected: (_) => ambienceController.setTag(tag),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: ambienceController.tags.length,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No ambiences found. Try another search or filter.'),
                        )
                      : ListView.separated(
                          itemBuilder: (_, index) {
                            final ambience = filtered[index];
                            return AmbienceCard(
                              ambience: ambience,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AmbienceDetailsScreen(
                                      ambience: ambience,
                                      playerController: playerController,
                                      journalController: journalController,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemCount: filtered.length,
                        ),
                ),
              ],
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
                            journalController: journalController,
                            onSaved: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalScreen(
                                    controller: journalController,
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

class AmbienceDetailsScreen extends StatelessWidget {
  const AmbienceDetailsScreen({
    super.key,
    required this.ambience,
    required this.playerController,
    required this.journalController,
  });

  final Ambience ambience;
  final PlayerController playerController;
  final JournalController journalController;

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
              journalController: journalController,
              onSaved: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalScreen(
                      controller: journalController,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalScreen(
                    controller: journalController,
                    playerController: playerController,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Hero(
              tag: 'ambience-${ambience.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 220,
                  child: AmbienceImage(imageKey: ambience.image),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ambience.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(ambience.tag)),
                const SizedBox(width: 8),
                Text('${ambience.durationMinutes} min'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ambience.description,
              style: const TextStyle(fontSize: 16, height: 1.45),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ambience.sensoryChips
                  .map((chip) => Chip(label: Text(chip)))
                  .toList(),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      controller: playerController,
                      initialAmbience: ambience,
                      onSessionEnded: (ended) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReflectionScreen(
                              ambience: ended,
                              journalController: journalController,
                              onSaved: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JournalScreen(
                                      controller: journalController,
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Start Session'),
              ),
            ),
          ],
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
                        journalController: journalController,
                        onSaved: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JournalScreen(
                                controller: journalController,
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
  }
}

