import 'package:flutter/material.dart';

import '../../data/models/ambience.dart';

class AmbienceImage extends StatelessWidget {
  const AmbienceImage({super.key, required this.imageKey});

  final String imageKey;

  @override
  Widget build(BuildContext context) {
    final palette = paletteFor(imageKey);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -22,
            left: -24,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AmbienceCard extends StatelessWidget {
  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  final Ambience ambience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
            ),
          ],
          gradient: LinearGradient(
            colors: paletteFor(ambience.image),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Row(
          children: [
            Hero(
              tag: 'ambience-${ambience.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                child: SizedBox(
                  width: 112,
                  height: 96,
                  child: AmbienceImage(imageKey: ambience.image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ambience.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(
                          label: Text(ambience.tag),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Text('${ambience.durationMinutes} min',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Color> paletteFor(String key) {
  switch (key) {
    case 'rain':
      return const [Color(0xFF3E6A86), Color(0xFF1D3A53)];
    case 'forest':
      return const [Color(0xFF4C8A66), Color(0xFF2A513B)];
    case 'ocean':
      return const [Color(0xFF5B79A3), Color(0xFF2D3E66)];
    case 'mist':
      return const [Color(0xFF97AAB3), Color(0xFF5E6E75)];
    case 'fire':
      return const [Color(0xFFB56A3D), Color(0xFF6A3C25)];
    case 'dawn':
      return const [Color(0xFFC68B68), Color(0xFF815C51)];
    default:
      return const [Color(0xFF4D687A), Color(0xFF2C3E4D)];
  }
}

