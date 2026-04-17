import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/energy_provider.dart';
import '../../../core/constants.dart';

class EnergyBar extends ConsumerWidget {
  const EnergyBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyProvider);
    return energyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (energy) {
        // 5 corações × 5 energia = 25 total
        const hearts = kMaxEnergy ~/ kEnergyPerHeart;
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: List.generate(hearts, (i) {
            final heartMin = i * kEnergyPerHeart;       // energia mínima deste coração
            final fill = ((energy.current - heartMin) / kEnergyPerHeart)
                .clamp(0.0, 1.0);
            return _HeartIcon(fill: fill);
          }),
        );
      },
    );
  }
}

/// Coração com preenchimento fracionário (0.0 = vazio, 1.0 = cheio).
class _HeartIcon extends StatelessWidget {
  final double fill;
  const _HeartIcon({required this.fill});

  @override
  Widget build(BuildContext context) {
    const size = 18.0;
    const color = Colors.red;

    if (fill >= 1.0) {
      return const Icon(Icons.favorite, color: color, size: size);
    }
    if (fill <= 0.0) {
      return const Icon(Icons.favorite_border, color: color, size: size);
    }

    // Coração parcial: preenchimento da esquerda para direita
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          const Icon(Icons.favorite_border, color: color, size: size),
          ClipRect(
            clipper: _HorizontalFillClipper(fill),
            child: const Icon(Icons.favorite, color: color, size: size),
          ),
        ],
      ),
    );
  }
}

class _HorizontalFillClipper extends CustomClipper<Rect> {
  final double fill; // 0.0 a 1.0
  const _HorizontalFillClipper(this.fill);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fill, size.height);

  @override
  bool shouldReclip(_HorizontalFillClipper old) => old.fill != fill;
}
