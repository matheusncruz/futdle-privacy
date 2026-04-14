import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';

class TodayProgress {
  final bool played;
  final bool solved;
  final int attempts;
  final String? challengeId;

  const TodayProgress({
    required this.played,
    required this.solved,
    required this.attempts,
    this.challengeId,
  });
}

final todayProgressProvider = FutureProvider<TodayProgress>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return const TodayProgress(played: false, solved: false, attempts: 0);

  final today = DateTime.now().toIso8601String().substring(0, 10);

  // Busca o desafio de hoje
  final challenge = await supabase
      .from('daily_challenges')
      .select('id')
      .eq('date', today)
      .maybeSingle();

  if (challenge == null) return const TodayProgress(played: false, solved: false, attempts: 0);

  final challengeId = challenge['id'] as String;

  // Verifica se já jogou hoje
  final progress = await supabase
      .from('user_progress')
      .select('solved, attempts_count')
      .eq('user_id', userId)
      .eq('challenge_id', challengeId)
      .maybeSingle();

  if (progress == null) {
    return TodayProgress(played: false, solved: false, attempts: 0, challengeId: challengeId);
  }

  return TodayProgress(
    played: true,
    solved: progress['solved'] as bool,
    attempts: progress['attempts_count'] as int,
    challengeId: challengeId,
  );
});
