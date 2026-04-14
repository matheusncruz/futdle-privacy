import '../../../core/constants.dart';

class EnergyState {
  final int current;
  final DateTime lastRegenAt;

  const EnergyState({required this.current, required this.lastRegenAt});

  EnergyState withRegen() {
    final now = DateTime.now();
    final elapsed = now.difference(lastRegenAt);
    final regenCount = elapsed.inMinutes ~/ kEnergyRegenMinutes;
    if (regenCount == 0) return this;
    final newEnergy = (current + regenCount).clamp(0, kMaxEnergy);
    final newLastRegen = lastRegenAt.add(Duration(minutes: regenCount * kEnergyRegenMinutes));
    return EnergyState(current: newEnergy, lastRegenAt: newLastRegen);
  }

  bool get canPlay => current > 0;
}
