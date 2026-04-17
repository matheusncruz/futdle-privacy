import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../../game/models/club.dart';

/// Desafio diário EXCLUSIVO do modo escudo.
/// Usa a tabela `shield_daily_challenges` — separada da `daily_challenges`
/// do modo clássico, garantindo times diferentes no mesmo dia.
class ShieldDailyChallenge {
  final String id;
  final Club club;
  final String date;

  const ShieldDailyChallenge({
    required this.id,
    required this.club,
    required this.date,
  });
}

final shieldDailyChallengeProvider =
    FutureProvider<ShieldDailyChallenge>((ref) async {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final data = await supabase
      .from('shield_daily_challenges')
      .select('id, date, clubs(*, leagues(name))')
      .eq('date', today)
      .single();

  return ShieldDailyChallenge(
    id: data['id'] as String,
    club: Club.fromJson(data['clubs'] as Map<String, dynamic>),
    date: data['date'] as String,
  );
});
