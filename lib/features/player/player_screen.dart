import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/widgets/ambience_widgets.dart';
import '../../core/widgets/formatters.dart';
import '../../data/models/ambience.dart';
import 'player_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.controller,
    required this.initialAmbience,
    required this.onSessionEnded,
  });

  final PlayerController controller;
  final Ambience? initialAmbience;
  final ValueChanged<Ambience> onSessionEnded;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.9,
      upperBound: 1.08,
    )..repeat(reverse: true);
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final target = widget.initialAmbience;
    if (target != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.controller.start(target);
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _pulse.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    final ended = widget.controller.consumePendingReflection();
    if (ended == null || !mounted) return;
    widget.onSessionEnded(ended);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final ambience = controller.current ?? widget.initialAmbience;
    if (ambience == null) {
      return const Scaffold(body: Center(child: Text('No active session found.')));
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final totalSeconds = controller.total.inSeconds.toDouble();
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Session Player',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: paletteFor(ambience.image)[0],elevation: 0,leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: paletteFor(ambience.image),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.27),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.self_improvement,
                            size: 90,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      ambience.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ambience.tag,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 26),
                    Slider(
                      value: controller.elapsed.inSeconds
                          .toDouble()
                          .clamp(0, totalSeconds > 0 ? totalSeconds : 1),
                      min: 0,
                      max: totalSeconds > 0 ? totalSeconds : 1,
                      onChanged: controller.seekTo,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(controller.elapsed),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          formatDuration(controller.total),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: FilledButton.icon(
                        onPressed: controller.togglePlayPause,
                        icon: Icon(
                          controller.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        label: Text(controller.isPlaying ? 'Pause' : 'Play'),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white54)
                      ),
                      onPressed: () async {
                        final shouldEnd = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('End session?'),
                            content: const Text(
                              'This will close your current session and open the journal.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('End Session'),
                              ),
                            ],
                          ),
                        );
                        if (shouldEnd != true) return;
                        await controller.endManually();
                        final ended = controller.consumePendingReflection();
                        if (ended != null) widget.onSessionEnded(ended);
                      },
                      child: const Text('End Session',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final PlayerController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasActiveSession || controller.current == null) {
      return const SizedBox.shrink();
    }

    final max = controller.total.inSeconds == 0
        ? 1.0
        : controller.total.inSeconds.toDouble();
    final value = controller.elapsed.inSeconds.toDouble().clamp(0, max);

    return Material(
      elevation: 12,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 12,
                  spreadRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ]
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.current!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.togglePlayPause,
                          icon: Icon(
                            controller.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(value: max == 0 ? 0 : (value / max)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

