import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';

class LeaderboardEntry {
  final String nickname;
  final int attemptsCount;
  final int timeSeconds;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.nickname,
    required this.attemptsCount,
    required this.timeSeconds,
    required this.isCurrentUser,
  });

  String get formattedTime {
    if (timeSeconds >= 60) {
      final m = timeSeconds ~/ 60;
      final s = timeSeconds % 60;
      return '${m}m ${s}s';
    }
    return '${timeSeconds}s';
  }
}

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, challengeId) async {
  final currentUserId = supabase.auth.currentUser?.id;

  // 1. Top 10 do desafio (solved = true)
  final progress = await supabase
      .from('user_progress')
      .select('user_id, attempts_count, time_seconds')
      .eq('challenge_id', challengeId)
      .eq('solved', true)
      .order('attempts_count', ascending: true)
      .order('time_seconds', ascending: true)
      .limit(10);

  if ((progress as List).isEmpty) return [];

  // 2. Busca nicknames dos jogadores do ranking
  final userIds = progress.map((r) => r['user_id'] as String).toList();
  final profiles = await supabase
      .from('user_profiles')
      .select('user_id, nickname')
      .inFilter('user_id', userIds);

  final profileMap = {
    for (final p in profiles as List) p['user_id'] as String: p['nickname'] as String
  };

  // 3. Monta a lista final
  return progress.map((row) {
    final userId = row['user_id'] as String;
    return LeaderboardEntry(
      nickname: profileMap[userId] ?? 'Anônimo',
      attemptsCount: row['attempts_count'] as int,
      timeSeconds: row['time_seconds'] as int,
      isCurrentUser: userId == currentUserId,
    );
  }).toList();
});
