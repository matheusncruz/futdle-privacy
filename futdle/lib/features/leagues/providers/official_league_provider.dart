// futdle/lib/features/leagues/providers/official_league_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/league_score.dart';

String _currentMonthStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
}

/// Full ranking for the official league of a given mode ('classic' | 'shield').
final officialLeagueProvider =
    FutureProvider.family<List<OfficialLeagueRankEntry>, String>((ref, mode) async {
  final currentUserId = supabase.auth.currentUser?.id;
  final monthStr = _currentMonthStr();
  final badgeCol = mode == 'classic' ? 'classic_champion_until' : 'shield_champion_until';

  final scores = await supabase
      .from('league_scores')
      .select('user_id, total_points, current_streak')
      .eq('mode', mode)
      .eq('month', monthStr)
      .order('total_points', ascending: false)
      .limit(100);

  if ((scores as List).isEmpty) return [];

  final userIds = scores.map((s) => s['user_id'] as String).toList();
  final profiles = await supabase
      .from('user_profiles')
      .select('user_id, nickname, $badgeCol')
      .inFilter('user_id', userIds);

  final profileMap = {
    for (final p in profiles as List) p['user_id'] as String: p,
  };

  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);

  return scores.asMap().entries.map((e) {
    final s = e.value;
    final userId = s['user_id'] as String;
    final profile = profileMap[userId];
    final champStr = profile?[badgeCol] as String?;
    final hasChampionBadge = champStr != null &&
        !DateTime.parse(champStr).isBefore(todayMidnight);

    return OfficialLeagueRankEntry(
      userId:           userId,
      nickname:         profile?['nickname'] as String? ?? 'Anônimo',
      totalPoints:      s['total_points'] as int,
      rank:             e.key + 1,
      currentStreak:    s['current_streak'] as int,
      isCurrentUser:    userId == currentUserId,
      hasChampionBadge: hasChampionBadge,
    );
  }).toList();
});

/// Current user's position in the official league (for hub screen card).
final myLeaguePositionProvider =
    FutureProvider.family<MyLeaguePosition?, String>((ref, mode) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  final monthStr = _currentMonthStr();

  final myScore = await supabase
      .from('league_scores')
      .select('total_points, current_streak')
      .eq('user_id', userId)
      .eq('mode', mode)
      .eq('month', monthStr)
      .maybeSingle();

  if (myScore == null) return null;

  final myPoints = myScore['total_points'] as int;

  // Count users with strictly more points to determine rank
  final higher = await supabase
      .from('league_scores')
      .select('user_id')
      .eq('mode', mode)
      .eq('month', monthStr)
      .gt('total_points', myPoints);

  return MyLeaguePosition(
    points: myPoints,
    rank:   (higher as List).length + 1,
    streak: myScore['current_streak'] as int,
  );
});
