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

  // Precisa ter ao menos 1 coração (kEnergyPerHeart unidades) para jogar
  bool get canPlay => current >= kEnergyPerHeart;

  bool get isFull => current >= kMaxEnergy;

  /// Tempo restante até a próxima recarga de 1 energia.
  Duration get nextRegenIn {
    if (isFull) return Duration.zero;
    final nextRegen = lastRegenAt.add(Duration(minutes: kEnergyRegenMinutes));
    final diff = nextRegen.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
