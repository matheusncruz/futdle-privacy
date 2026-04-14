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
      data: (energy) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(kMaxEnergy, (i) {
          return Icon(
            i < energy.current ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: 20,
          );
        }),
      ),
    );
  }
}
