import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';

class ShieldTodayProgress {
  final bool played;
  final bool solved;
  final int wrongCount;
  final String? challengeId;

  const ShieldTodayProgress({
    required this.played,
    required this.solved,
    required this.wrongCount,
    this.challengeId,
  });
}

final shieldTodayProgressProvider = FutureProvider<ShieldTodayProgress>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    return const ShieldTodayProgress(played: false, solved: false, wrongCount: 0);
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);

  final challenge = await supabase
      .from('shield_daily_challenges')
      .select('id')
      .eq('date', today)
      .maybeSingle();

  if (challenge == null) {
    return const ShieldTodayProgress(played: false, solved: false, wrongCount: 0);
  }

  final challengeId = challenge['id'] as String;

  final progress = await supabase
      .from('shield_user_progress')
      .select('solved, wrong_count')
      .eq('user_id', userId)
      .eq('challenge_id', challengeId)
      .maybeSingle();

  if (progress == null) {
    return ShieldTodayProgress(
      played: false,
      solved: false,
      wrongCount: 0,
      challengeId: challengeId,
    );
  }

  return ShieldTodayProgress(
    played: true,
    solved: progress['solved'] as bool,
    wrongCount: progress['wrong_count'] as int,
    challengeId: challengeId,
  );
});
