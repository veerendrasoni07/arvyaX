

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/ambience_widgets.dart';
import '../../counter_provider.dart';
import '../../data/models/ambience.dart';
import '../journal/journal_controller.dart';
import '../player/player_controller.dart';
import '../player/player_screen.dart';
import '../journal/journal_screen.dart';
import 'ambience_controller.dart';

class AmbienceScreen extends ConsumerStatefulWidget {
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
  ConsumerState<AmbienceScreen> createState() => _AmbienceScreenState();
}

class _AmbienceScreenState extends ConsumerState<AmbienceScreen> {

  final FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocus.unfocus();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);
    return AnimatedBuilder(
      animation: Listenable.merge([widget.ambienceController, widget.playerController]),
      builder: (_, __) {
        final pending = widget.playerController.consumePendingReflection();
        if (pending != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReflectionScreen(
                  ambience: pending,
                  journalController: widget.journalController,
                  onSaved: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalScreen(
                          controller: widget.journalController,
                          playerController: widget.playerController,
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

        final filtered = widget.ambienceController.filtered;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            body: NotificationListener<UserScrollNotification>(
              onNotification: (_){
                searchFocus.unfocus();
                return false;
              },
              child: CustomScrollView(
                slivers: [

                  /// APP BAR
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                  expandedHeight: 180,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: const Text(
                      "Ambience Library",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.menu_book_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JournalScreen(
                                controller: widget.journalController,
                                playerController: widget.playerController,
                              ),
                            ),
                          );
                        },
                      )
                    ],

                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// SEARCH BAR
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                focusNode: searchFocus,
                                onChanged: widget.ambienceController.setQuery,
                                decoration: const InputDecoration(
                                  hintText: "Search ambience",
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// FILTER CHIPS
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.ambienceController.tags.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (_, i) {
                                  final tag = widget.ambienceController.tags[i];

                                  return ChoiceChip(
                                    selected: tag == widget.ambienceController.tag,
                                    label: Text(tag),
                                    onSelected: (_) =>
                                        widget.ambienceController.setTag(tag),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// LIST
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: filtered.isEmpty
                        ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "No ambiences found. Try another search or filter.",
                        ),
                      ),
                    )
                        : SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final ambience = filtered[index];

                        return AmbienceCard(
                          ambience: ambience,
                          onTap: () async{
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AmbienceDetailsScreen(
                                  ambience: ambience,
                                  playerController: widget.playerController,
                                  journalController: widget.journalController,
                                ),
                              ),
                            );
                            searchFocus.unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar: MiniPlayerBar(
              controller: widget.playerController,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      controller: widget.playerController,
                      initialAmbience: widget.playerController.current,
                      onSessionEnded: (ambience) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReflectionScreen(
                              ambience: ambience,
                              journalController: widget.journalController,
                              onSaved: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JournalScreen(
                                      controller: widget.journalController,
                                      playerController: widget.playerController,
                                    ),
                                  ),
                                      (route) => route.isFirst,
                                );
                                searchFocus.unfocus();
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
          ),
        );
      },
    );
  }
}

class AmbienceDetailsScreen extends ConsumerWidget {
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
  Widget build(BuildContext context,WidgetRef ref) {
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
        title:  Text('Details',style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back_ios)),
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
                ref.read(counterProvider.notifier).increaseCounter(ambience.id, ambience.title);
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

