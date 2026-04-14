import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';

class PowerupsState {
  final int hintUses;
  final int revealUses;

  const PowerupsState({required this.hintUses, required this.revealUses});

  PowerupsState copyWith({int? hintUses, int? revealUses}) => PowerupsState(
        hintUses: hintUses ?? this.hintUses,
        revealUses: revealUses ?? this.revealUses,
      );
}

class PowerupsNotifier extends AsyncNotifier<PowerupsState> {
  @override
  Future<PowerupsState> build() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return const PowerupsState(hintUses: 3, revealUses: 3);

    final data = await supabase
        .from('user_profiles')
        .select('hint_uses, reveal_uses')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return const PowerupsState(hintUses: 3, revealUses: 3);

    return PowerupsState(
      hintUses: (data['hint_uses'] as int?) ?? 3,
      revealUses: (data['reveal_uses'] as int?) ?? 3,
    );
  }

  Future<bool> useHint() async => _consume('hint_uses', isHint: true);
  Future<bool> useReveal() async => _consume('reveal_uses', isHint: false);

  Future<bool> _consume(String column, {required bool isHint}) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    final uses = isHint ? current.hintUses : current.revealUses;
    if (uses <= 0) return false;

    final newState = isHint
        ? current.copyWith(hintUses: uses - 1)
        : current.copyWith(revealUses: uses - 1);

    state = AsyncData(newState);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase
          .from('user_profiles')
          .update({column: uses - 1})
          .eq('user_id', userId);
    }

    return true;
  }

  /// Adiciona +2 usos após anúncio premiado
  Future<void> rewardHint() async => _addUses('hint_uses', isHint: true, amount: 2);
  Future<void> rewardReveal() async => _addUses('reveal_uses', isHint: false, amount: 2);

  Future<void> _addUses(String column, {required bool isHint, required int amount}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final uses = isHint ? current.hintUses : current.revealUses;
    final newUses = uses + amount;

    final newState = isHint
        ? current.copyWith(hintUses: newUses)
        : current.copyWith(revealUses: newUses);

    state = AsyncData(newState);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase
          .from('user_profiles')
          .update({column: newUses})
          .eq('user_id', userId);
    }
  }
}

final powerupsProvider =
    AsyncNotifierProvider<PowerupsNotifier, PowerupsState>(PowerupsNotifier.new);
