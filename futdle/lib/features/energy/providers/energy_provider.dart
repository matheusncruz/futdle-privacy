import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../../../core/constants.dart';
import '../models/energy_state.dart';

class EnergyNotifier extends AsyncNotifier<EnergyState> {
  @override
  Future<EnergyState> build() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return EnergyState(current: kMaxEnergy, lastRegenAt: DateTime.now());
    }

    final data = await supabase
        .from('user_energy')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      final now = DateTime.now();
      await supabase.from('user_energy').insert({
        'user_id': userId,
        'current_energy': kMaxEnergy,
        'last_regen_at': now.toIso8601String(),
      });
      return EnergyState(current: kMaxEnergy, lastRegenAt: now);
    }

    return EnergyState(
      current: data['current_energy'] as int,
      lastRegenAt: DateTime.parse(data['last_regen_at'] as String),
    ).withRegen();
  }

  /// Chamado pelo ticker da EnergyBar quando nextRegenIn chega a zero.
  Future<void> triggerRegen() async {
    final current = state.valueOrNull;
    if (current == null || current.isFull) return;

    final regenned = current.withRegen();
    if (regenned.current == current.current) return; // ainda não é hora

    state = AsyncData(regenned);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('user_energy').update({
        'current_energy': regenned.current,
        'last_regen_at': regenned.lastRegenAt.toIso8601String(),
      }).eq('user_id', userId);
    }
  }

  Future<void> addEnergy(int amount) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newState = EnergyState(
      current: (current.current + amount).clamp(0, kMaxEnergy),
      lastRegenAt: current.lastRegenAt,
    );
    state = AsyncData(newState);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('user_energy').update({
        'current_energy': newState.current,
      }).eq('user_id', userId);
    }
  }

  Future<bool> consume() async {
    final current = state.valueOrNull;
    if (current == null || !current.canPlay) return false;

    final newState = EnergyState(current: current.current - 1, lastRegenAt: current.lastRegenAt);
    state = AsyncData(newState);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('user_energy').update({
        'current_energy': newState.current,
        'last_regen_at': newState.lastRegenAt.toIso8601String(),
      }).eq('user_id', userId);
    }
    return true;
  }
}

final energyProvider = AsyncNotifierProvider<EnergyNotifier, EnergyState>(EnergyNotifier.new);
