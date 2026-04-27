import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';

class ShieldLeaderboardEntry {
  final String nickname;
  final int wrongCount;
  final int timeSeconds;
  final bool isCurrentUser;

  const ShieldLeaderboardEntry({
    required this.nickname,
    required this.wrongCount,
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

final shieldLeaderboardProvider =
    FutureProvider.family<List<ShieldLeaderboardEntry>, String>((ref, challengeId) async {
  final currentUserId = supabase.auth.currentUser?.id;

  final progress = await supabase
      .from('shield_user_progress')
      .select('user_id, wrong_count, time_seconds')
      .eq('challenge_id', challengeId)
      .eq('solved', true)
      .order('wrong_count', ascending: true)
      .order('time_seconds', ascending: true)
      .limit(10);

  if ((progress as List).isEmpty) return [];

  final userIds = progress.map((r) => r['user_id'] as String).toList();
  final profiles = await supabase
      .from('user_profiles')
      .select('user_id, nickname')
      .inFilter('user_id', userIds);

  final profileMap = {
    for (final p in profiles as List) p['user_id'] as String: p['nickname'] as String
  };

  return progress.map((row) {
    final userId = row['user_id'] as String;
    return ShieldLeaderboardEntry(
      nickname: profileMap[userId] ?? 'Anônimo',
      wrongCount: row['wrong_count'] as int,
      timeSeconds: row['time_seconds'] as int,
      isCurrentUser: userId == currentUserId,
    );
  }).toList();
});
